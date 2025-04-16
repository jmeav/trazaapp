import 'package:flutter/material.dart';
import 'package:trazaapp/data/models/altaentrega/altaentrega.dart';
import 'package:intl/intl.dart';

class ResumenAltaView extends StatelessWidget {
  final AltaEntrega alta;

  const ResumenAltaView({super.key, required this.alta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumen de Alta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEncabezado(),
            const SizedBox(height: 16),
            Expanded(child: _buildDataTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ID Alta: ${alta.idAlta}', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('Rango: ${alta.rangoInicial} - ${alta.rangoFinal}'),
        Text('CUPA: ${alta.cupa}'),
        Text('CUE: ${alta.cue}'),
        Text('Fecha Alta: ${DateFormat('dd/MM/yyyy HH:mm').format(alta.fechaAlta)}'),
        Text('Cantidad Bovinos: ${alta.detalleBovinos.length}'),
      ],
    );
  }

  Widget _buildDataTable() {
    int totalBuenos = alta.detalleBovinos.where((b) => b.estadoArete.toLowerCase() == 'bueno').length;
    int totalDanados = alta.detalleBovinos.where((b) => b.estadoArete.toLowerCase() == 'dañado').length;

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('N°')),
            DataColumn(label: Text('Arete')),
            DataColumn(label: Text('Edad')),
            DataColumn(label: Text('Sexo')),
            DataColumn(label: Text('Raza')),
            DataColumn(label: Text('Traza')),
            DataColumn(label: Text('Estado Arete')),
            DataColumn(label: Text('F. Nacimiento')),
          ],
          rows: [
            ...alta.detalleBovinos.asMap().entries.map((entry) {
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
              ]);
            }).toList(),
            DataRow(
              cells: [
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                DataCell(Text('Total Buenos: $totalBuenos', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text('Total Dañados: $totalDanados', style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
