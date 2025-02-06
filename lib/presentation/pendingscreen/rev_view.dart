import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/bovinos/bovino.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';

class RevisionView extends StatefulWidget {
  @override
  _RevisionViewState createState() => _RevisionViewState();
}

class _RevisionViewState extends State<RevisionView> {
  late String entregaId;
  late Entregas entrega;
  List<Bovino> bovinos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    entregaId = args['entregaId'];
    _loadEntregaData();
  }

  Future<void> _loadEntregaData() async {
    try {
      final entregasBox = await Hive.openBox<Entregas>('entregas');
      final bovinoBox = await Hive.openBox<Bovino>('bovinos');

      entrega = entregasBox.values
          .firstWhere((e) => e.entregaId == entregaId, orElse: () => throw 'Entrega no encontrada');
      bovinos = bovinoBox.values
          .where((bovino) => bovino.cue == entrega.cue)
          .toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      Get.snackbar('Error', 'Error al cargar los datos: $e');
    }
  }

  Future<void> _updateBovinos() async {
    try {
      final bovinoBox = await Hive.openBox<Bovino>('bovinos');

      for (var bovino in bovinos) {
        await bovinoBox.put(bovino.arete, bovino);
      }

      Get.snackbar(
        'Éxito',
        'Los datos de los bovinos han sido actualizados.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar los bovinos: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Revisión de Bovinos')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisión de Bovinos'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CUPA: ${entrega.cupa}', style: const TextStyle(fontSize: 18)),
                  Text('CUE: ${entrega.cue}', style: const TextStyle(fontSize: 18)),
                  Text(
                    'Rango de Entrega: ${entrega.rangoInicial} - ${entrega.rangoFinal}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const Divider(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Arete')),
                  DataColumn(label: Text('Edad')),
                  DataColumn(label: Text('Sexo')),
                  DataColumn(label: Text('Raza')),
                ],
                rows: bovinos.map((bovino) {
                  return DataRow(
                    cells: [
                      DataCell(Text(bovino.arete)),
                      DataCell(
                        TextFormField(
                          initialValue: bovino.edad.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              bovino.edad = int.tryParse(value) ?? bovino.edad;
                            });
                          },
                        ),
                      ),
                      DataCell(
                        TextFormField(
                          initialValue: bovino.sexo,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              bovino.sexo = value;
                            });
                          },
                        ),
                      ),
                      DataCell(
                        TextFormField(
                          initialValue: bovino.raza,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              bovino.raza = value;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _updateBovinos,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text(
                  'Guardar Cambios',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
