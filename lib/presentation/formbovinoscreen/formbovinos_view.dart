import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/formbovinos_controller.dart';

class FormBovinosView extends StatelessWidget {
  final FormBovinosController controller = Get.put(FormBovinosController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Información individual'),
      ),
      body: Obx(() {
        // Mostrar spinner mientras los datos se cargan
        if (controller.rangos.isEmpty || controller.bovinoInfo.isEmpty) {
          return const Center(
            child: SpinKitCircle(
              color: Color.fromARGB(255, 3, 136, 244),
              size: 50.0,
            ),
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cue: ${controller.bovinoInfo.values.first.cue}'),
                      const SizedBox(height: 8),
                      Text(
                          'Rango: ${controller.rangos.first} - ${controller.rangos.last}'),
                      const SizedBox(height: 8),
                      Text('Cantidad: ${controller.rangos.length}'),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Aplicar llenado rápido'),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0, left: 10),
                      child: FloatingActionButton.small(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return _buildQuickFillDialog(context);
                            },
                          );
                        },
                        child: const Icon(Icons.flash_on),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Divider(
                    color: Color.fromARGB(255, 213, 197, 197),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: (index) {
                      controller.currentPage.value = index;
                      controller
                          .update(); // Actualiza la vista cuando se cambia de página
                    },
                    itemCount: controller.rangos.length,
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        child: _buildFormPage(controller.rangos[index]),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: controller.currentPage.value > 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: controller.previousPage,
                          child: const Row(
                            children: [
                              Icon(Icons.arrow_back),
                              SizedBox(width: 8),
                              Text('Anterior'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Obx(() {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: controller.currentPage.value ==
                                  controller.rangos.length - 1
                              ? () async {
                                  // Validar datos antes de guardar
                                  bool hasErrors = false;

                                  controller.bovinoInfo
                                      .forEach((arete, bovino) {
                                    if (bovino.edad <= 0 ||
                                        bovino.sexo.isEmpty ||
                                        bovino.raza.isEmpty) {
                                      hasErrors = true;
                                      print(
                                          'Error: Faltan datos en el bovino con arete $arete.');
                                    }
                                  });

                                  if (hasErrors) {
                                    Get.snackbar('Error',
                                        'Faltan datos en algunos bovinos.');
                                    return;
                                  }
                                  // Si no hay errores, imprimir información y guardar
                                  print(
                                      "Información recopilada de los bovinos:");
                                  controller.bovinoInfo
                                      .forEach((arete, bovino) {
                                    print("Arete: $arete");
                                    print("Cue: ${bovino.cue}");
                                    print("Cupa: ${bovino.cupa}");
                                    print("Edad: ${bovino.edad}");
                                    print("Sexo: ${bovino.sexo}");
                                    print("Raza: ${bovino.raza}");
                                    print(
                                        "Estado Arete: ${bovino.estadoArete}");
                                    print("-------------------");
                                  });

                                  // Continuar con el guardado
                                  controller.sendingData.value = true;
                                  controller.saveBovinos();
                                  controller.sendingData.value = false;
                                  Get.offNamed('/home');
                                }
                              : controller.nextPage,
                          child: Row(
                            children: [
                              Text(controller.currentPage.value ==
                                      controller.rangos.length - 1
                                  ? 'Guardar'
                                  : 'Siguiente'),
                              const SizedBox(width: 8),
                              Icon(controller.currentPage.value ==
                                      controller.rangos.length - 1
                                  ? Icons.save
                                  : Icons.arrow_forward),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
            if (controller.sendingData.value)
              const Center(
                child: SpinKitCircle(
                  color: Color.fromARGB(255, 3, 136, 244),
                  size: 100.0,
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildQuickFillDialog(BuildContext context) {
    final controller = Get.find<FormBovinosController>();
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Llenado Rápido',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 50,
                  width: 80,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Edad'),
                    onChanged: (value) =>
                        controller.quickFillEdad.value = value,
                  ),
                ),
                Container(
                  height: 65,
                  width: 90,
                  child: Obx(() {
                    return DropdownButton<String>(
                      value: controller.quickFillSexo.value.isEmpty
                          ? null
                          : controller.quickFillSexo.value,
                      hint: const Text('Sexo'),
                      onChanged: (String? newValue) {
                        controller.quickFillSexo.value = newValue ?? '';
                      },
                      items: const <String>['Macho', 'Hembra']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    );
                  }),
                ),
                Container(
                  height: 65,
                  width: 120,
                  child: Obx(() {
                    return DropdownButton<String>(
                      value: controller.quickFillRaza.value.isEmpty
                          ? null
                          : controller.quickFillRaza.value,
                      hint: const Text('Raza'),
                      onChanged: (String? newValue) {
                        controller.quickFillRaza.value = newValue ?? '';
                      },
                      items: const <String>[
                        'Angus',
                        'Hereford',
                        'Holstein',
                        'Charolais'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    );
                  }),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                Row(
                  children: [
                    Tooltip(
                      message: 'Borrar Llenado Rápido',
                      child: IconButton(
                        icon: Icon(Icons.clear, color: Colors.red[400]),
                        onPressed: () {
                          controller.clearQuickFill();
                          Navigator.of(context).pop();
                          Get.snackbar('Llenado Rápido',
                              'Datos borrados correctamente.');
                        },
                      ),
                    ),
                    Tooltip(
                      message: 'Aplicar Llenado Rápido',
                      child: IconButton(
                        icon: Icon(
                          Icons.check,
                          color: Colors.green[600],
                        ),
                        onPressed: () {
                          controller.applyQuickFill();
                          Navigator.of(context).pop();
                          Get.snackbar('Llenado Rápido',
                              'Datos aplicados correctamente.');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormPage(String bovinoID) {
    final bovinoData = controller.bovinoInfo[bovinoID]!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Arete: ${bovinoData.arete}'),
          const SizedBox(height: 16),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Edad (en meses)'),
            controller: TextEditingController(
              text: bovinoData.edad > 0 ? bovinoData.edad.toString() : '',
            ),
            onChanged: (value) {
              final updatedEdad = int.tryParse(value) ?? 0;
              final updatedBovino = bovinoData.copyWith(edad: updatedEdad);
              controller.bovinoInfo[bovinoID] = updatedBovino;
              controller.update(); // Notificar cambios
            },
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: bovinoData.sexo.isEmpty ? null : bovinoData.sexo,
            hint: const Text('Sexo'),
            isExpanded: true,
            onChanged: (String? newValue) {
              bovinoData.sexo = newValue ?? '';
              controller.bovinoInfo[bovinoID] = bovinoData;
            },
            items: const <String>['Macho', 'Hembra']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: bovinoData.raza.isEmpty ? null : bovinoData.raza,
            hint: const Text('Raza'),
            isExpanded: true,
            onChanged: (String? newValue) {
              bovinoData.raza = newValue ?? '';
              controller.bovinoInfo[bovinoID] = bovinoData;
            },
            items: const <String>['Angus', 'Hereford', 'Holstein', 'Charolais']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estado: ${bovinoData.estadoArete}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: bovinoData.estadoArete == 'Bueno'
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              IconButton(
                icon: Icon(
                  bovinoData.estadoArete == 'Bueno'
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: bovinoData.estadoArete == 'Bueno'
                      ? Colors.green
                      : Colors.red,
                ),
                onPressed: () {
                  final updatedEstado =
                      bovinoData.estadoArete == 'Bueno' ? 'Dañado' : 'Bueno';
                  final updatedBovino = bovinoData.copyWith(
                    estadoArete: updatedEstado,
                  );
                  controller.bovinoInfo[bovinoID] = updatedBovino;
                  controller.update(); // Notificar cambios
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
