import 'package:flutter/material.dart';
import 'package:trazaapp/data/local/models/altaentrega/altaentrega.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/presentation/widgets/edit_bovino_dialog.dart';

class ResumenAltaView extends StatelessWidget {
  final AltaEntrega alta;
  final EntregaController _entregaController = Get.find<EntregaController>();

  ResumenAltaView({super.key, required this.alta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumen de Alta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEncabezado(),
              const SizedBox(height: 16),
              
              // Información de bovinos en formato tabla
              Text(
                'Detalle de Bovinos (${alta.detalleBovinos.length})', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 10),
              
              // Tabla de bovinos
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('N°')),
                    DataColumn(label: Text('Arete')),
                    DataColumn(label: Text('Edad')),
                    DataColumn(label: Text('Sexo')),
                    DataColumn(label: Text('Raza')),
                    DataColumn(label: Text('Traza')),
                    DataColumn(label: Text('Estado')),
                    DataColumn(label: Text('F. Nacimiento')),
                    DataColumn(label: Text('Editar')),
                  ],
                  rows: _buildDataRows(context),
                ),
              ),
              
            
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEncabezado() {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID Alta: ${alta.idAlta}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Rango: ${alta.rangoInicial} - ${alta.rangoFinal}'),
            Text('CUPA: ${alta.cupa}'),
            Text('CUE: ${alta.cue}'),
            Text('Fecha Alta: ${DateFormat('dd/MM/yyyy HH:mm').format(alta.fechaAlta)}'),
            Text('Cantidad Bovinos: ${alta.detalleBovinos.length}'),
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildDataRows(BuildContext context) {
    int totalBuenos = alta.detalleBovinos.where((b) => b.estadoArete.toLowerCase() == 'bueno').length;
    int totalDanados = alta.detalleBovinos.where((b) => b.estadoArete.toLowerCase() == 'dañado').length;
    int totalNoUtilizados = alta.detalleBovinos.where((b) => b.estadoArete.toLowerCase() == 'no utilizado').length;

    final rows = <DataRow>[];
    rows.addAll(alta.detalleBovinos.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final b = entry.value;
      return DataRow(cells: [
        DataCell(Text('$index')),
        DataCell(Text(b.arete)),
        DataCell(Text('${b.edad}')),
        DataCell(Text(b.sexo)),
        DataCell(Text(b.raza)),
        DataCell(Text(b.traza)),
        DataCell(Text(b.estadoArete)),
        DataCell(Text(DateFormat('dd/MM/yyyy').format(b.fechaNacimiento))),
        DataCell(
          b.estadoArete.toLowerCase() == 'bueno'
            ? IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                onPressed: () => _mostrarDialogoEdicion(context, b),
                tooltip: 'Editar edad y sexo',
              )
            : const Text('--')
        ),
      ]);
    }));
    
    // Fila de resumen
    rows.add(DataRow(
      cells: [
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        DataCell(Text('Buenos: $totalBuenos Dañados: $totalDanados No Util.: $totalNoUtilizados', 
          style: const TextStyle(fontWeight: FontWeight.bold))),
        const DataCell(Text('')),
        const DataCell(Text('')),
      ],
    ));
    
    return rows;
  }

  
  Widget _buildResumenItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
  
  // Método para mostrar el diálogo de edición
  void _mostrarDialogoEdicion(BuildContext context, BovinoResumen bovino) {
    showDialog(
      context: context,
      builder: (context) => EditBovinoDialog(
        arete: bovino.arete,
        sexo: bovino.sexo,
        edad: bovino.edad,
        onSave: (sexo, edad) {
          _entregaController.actualizarBovinoAlta(alta.idAlta, bovino.arete, sexo, edad).then((_) {
            // Recargar la página para mostrar los cambios
            Get.off(() => ResumenAltaView(alta: alta));
          });
        },
      ),
    );
  }
}
