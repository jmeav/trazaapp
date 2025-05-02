import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/consultasbajas_controller.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ConsultaBajaView extends StatelessWidget {
  const ConsultaBajaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConsultasBajasController controller = Get.find();
    final appConfigBox = Hive.box<AppConfig>('appConfig');
    final config = appConfigBox.get('config');
    final token = config?.imei ?? '';
    final codhabilitado = config?.codHabilitado ?? '';
    final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    Map<String, dynamic> getEstadoInfo(String? motivo) {
      if (motivo == null || motivo.isEmpty) {
        return {'texto': 'Pendiente', 'color': Colors.orange};
      } else {
        return {'texto': 'Rechazado', 'color': Colors.red};
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Bajas'),
        actions: [
          Obx(() => IconButton(
                icon: Icon(controller.isCardView.value
                    ? Icons.table_rows_outlined
                    : Icons.view_agenda_outlined),
                tooltip: controller.isCardView.value
                    ? 'Ver como tabla'
                    : 'Ver como tarjetas',
                onPressed: () => controller.toggleViewMode(),
              )),
        ],
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final bool isLandscape = orientation == Orientation.landscape;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: isLandscape && controller.filteredResultados.isNotEmpty ? 50 : null,
                  child: isLandscape && controller.filteredResultados.isNotEmpty
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() => Text(
                                  'Mostrando ${controller.filteredResultados.length} de ${controller.resultados.length} resultados',
                                  style: Theme.of(context).textTheme.bodySmall,
                                )),
                            TextButton.icon(
                              icon: const Icon(Icons.filter_list, size: 16),
                              label: const Text('Filtros'),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (ctx) => SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: _buildFilterControls(ctx, controller, token, codhabilitado),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : _buildFilterControls(context, controller, token, codhabilitado),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value && controller.resultados.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.error.value != null) {
                      return Center(child: Text('Error: ${controller.error.value}', style: const TextStyle(color: Colors.red)));
                    }
                    if (controller.filteredResultados.isEmpty && !controller.isLoading.value) {
                      return const Center(child: Text('No hay bajas para mostrar con los filtros seleccionados.'));
                    }
                    return controller.isCardView.value
                        ? _buildCardView(controller, getEstadoInfo, context, _dateFormat)
                        : _buildTableView(context, controller, getEstadoInfo, isLandscape, _dateFormat);
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterControls(BuildContext context, ConsultasBajasController controller, String token, String codhabilitado) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fecha inicio'),
                  Obx(() => TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: controller.fechaInicio.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) controller.fechaInicio.value = picked;
                        },
                        child: Text('${controller.fechaInicio.value.toLocal()}'.split(' ')[0]),
                      )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fecha fin'),
                  Obx(() => TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: controller.fechaFin.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) controller.fechaFin.value = picked;
                        },
                        child: Text('${controller.fechaFin.value.toLocal()}'.split(' ')[0]),
                      )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => controller.isLoading.value
            ? const Center(child: Column(
                children: [
                  SizedBox(height: 16),
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Consultando bajas, por favor espere...'),
                ],
              ))
            : ElevatedButton(
                onPressed: () {
                  controller.consultarBajas(
                    token: token,
                    codhabilitado: codhabilitado,
                  );
                },
                child: const Text('Consultar Bajas'),
              )),
        const SizedBox(height: 16),
        Obx(() => Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                'Todos', 'Pendiente', 'Rechazado'
              ].map((status) {
                return ChoiceChip(
                  label: Text(status),
                  selected: controller.filterStatus.value == status,
                  onSelected: (selected) {
                    if (selected) {
                      controller.setFilter(status);
                    }
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                );
              }).toList(),
            )),
        Obx(() => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Mostrando ${controller.filteredResultados.length} de ${controller.resultados.length} resultados',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )),
      ],
    );
  }

  Widget _buildCardView(ConsultasBajasController controller, Function getEstadoInfo, BuildContext context, DateFormat dateFormat) {
    return ListView.builder(
      itemCount: controller.filteredResultados.length,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        final item = controller.filteredResultados[index];
        final motivo = item['motivorechazo']?.toString() ?? '';
        final estadoInfo = getEstadoInfo(motivo);
        final estadoTexto = estadoInfo['texto'];
        final estadoColor = estadoInfo['color'];
        final String idBaja = item['idBaja']?.toString() ?? 'N/A';
        final String cupa = item['cupa']?.toString() ?? 'N/A';
        final String cue = item['cue']?.toString() ?? 'N/A';
        final String fechaBajaStr = item['fechaBaja']?.toString() ?? '';
        DateTime? fechaBajaDate;
        try {
          if (fechaBajaStr.isNotEmpty) fechaBajaDate = DateTime.parse(fechaBajaStr);
        } catch (e) {}
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID Baja: $idBaja',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Text('CUPA: $cupa', style: const TextStyle(fontSize: 14))),
                            Expanded(child: Text('CUE: $cue', style: const TextStyle(fontSize: 14))),
                          ],
                        ),
                        if (fechaBajaDate != null)
                          Text('Fecha: ${dateFormat.format(fechaBajaDate)}', style: const TextStyle(fontSize: 14)),
                        if (estadoTexto == 'Rechazado' && motivo.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Motivo rechazo: $motivo', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 1,
                    right: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: estadoColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: estadoColor.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        estadoTexto,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableView(BuildContext context, ConsultasBajasController controller, Function getEstadoInfo, bool isLandscape, DateFormat dateFormat) {
    final theme = Theme.of(context);
    final double tableMinWidth = isLandscape ? 900 : 900;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableMinWidth,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    _buildTableHeader('ID Baja', width: 100),
                    _buildTableHeader('CUPA', width: 130),
                    _buildTableHeader('CUE', width: 120),
                    _buildTableHeader('Fecha', width: 150),
                    _buildTableHeader('Estado', width: 100),
                    _buildTableHeader('Motivo Rechazo', width: 200),
                  ],
                ),
              ),
              ...controller.filteredResultados.map((item) {
                final motivo = item['motivorechazo']?.toString() ?? '';
                final estadoInfo = getEstadoInfo(motivo);
                final estadoTexto = estadoInfo['texto'];
                final estadoColor = estadoInfo['color'];
                final String idBaja = item['idBaja']?.toString() ?? 'N/A';
                final String cupa = item['cupa']?.toString() ?? 'N/A';
                final String cue = item['cue']?.toString() ?? 'N/A';
                final String fechaBajaStr = item['fechaBaja']?.toString() ?? '';
                DateTime? fechaBajaDate;
                try {
                  if (fechaBajaStr.isNotEmpty) fechaBajaDate = DateTime.parse(fechaBajaStr);
                } catch (e) {}
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTableCell(idBaja, width: 100),
                        _buildTableCell(cupa, width: 130),
                        _buildTableCell(cue, width: 120),
                        _buildTableCell(fechaBajaDate != null ? dateFormat.format(fechaBajaDate) : 'N/A', width: 150),
                        Container(
                          width: 100,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            decoration: BoxDecoration(
                              color: estadoColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              estadoTexto,
                              style: TextStyle(
                                color: estadoColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        _buildTableCell(motivo, width: 200, maxLines: 2),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String title, {required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTableCell(String text, {required double width, int maxLines = 1}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: maxLines,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
} 