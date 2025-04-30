import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/consultasaltas_controller.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ConsultasView extends StatelessWidget {
  const ConsultasView({Key? key}) : super(key: key);

  // Método para compartir por WhatsApp
  Future<void> _shareViaWhatsApp(String fichaUrl) async {
    final String mensaje =
        Uri.encodeComponent('Consulta la ficha de esta alta: $fichaUrl');
    final String whatsappUrl = "https://wa.me/?text=$mensaje";
    try {
      final Uri url = Uri.parse(whatsappUrl);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo compartir: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ConsultasController controller = Get.find();
    final appConfigBox = Hive.box<AppConfig>('appConfig');
    final config = appConfigBox.get('config');
    final token = config?.imei ?? '';
    final codhabilitado = config?.codHabilitado ?? '';

    String formatArete(String? arete) {
      if (arete == null) return '';
      final s = arete.padLeft(10, '0');
      return '558$s';
    }

    Map<String, dynamic> getEstadoInfo(String? estado) {
      String estadoTexto;
      Color estadoColor;
      switch (estado) {
        case '1':
          estadoTexto = 'Procesado';
          estadoColor = Colors.green;
          break;
        case '2':
          estadoTexto = 'Rechazado';
          estadoColor = Colors.red;
          break;
        default:
          estadoTexto = 'Pendiente';
          estadoColor = Colors.orange;
      }
      return {'texto': estadoTexto, 'color': estadoColor};
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Altas Enviadas'),
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
        child: OrientationBuilder(builder: (context, orientation) {
          final bool isLandscape = orientation == Orientation.landscape;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Filtros colapsables
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                height: isLandscape && controller.filteredResultados.isNotEmpty
                    ? 50
                    : null,
                child: isLandscape && controller.filteredResultados.isNotEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mostrando ${controller.filteredResultados.length} de ${controller.resultados.length} resultados',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.filter_list, size: 16),
                            label: const Text('Filtros'),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (ctx) => SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: _buildFilterControls(
                                        ctx, controller, token, codhabilitado),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : _buildFilterControls(
                        context, controller, token, codhabilitado),
              ),

              // 2. Contenido principal
              Expanded(
                child: Obx(() {
                  if (controller.isGeneratingPdf.value) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Generando ficha...'),
                        ],
                      ),
                    );
                  }
                  if (controller.error.value != null) {
                    return Center(
                        child: Text('Error: ${controller.error.value}',
                            style: const TextStyle(color: Colors.red)));
                  }
                  if (controller.filteredResultados.isEmpty &&
                      !controller.isLoading.value) {
                    return const Center(
                        child: Text(
                            'No hay resultados para mostrar con los filtros seleccionados.'));
                  }
                  return controller.isCardView.value
                      ? _buildCardView(
                          controller, getEstadoInfo, formatArete, context)
                      : _buildTableView(context, controller, getEstadoInfo,
                          formatArete, isLandscape);
                }),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFilterControls(BuildContext context,
      ConsultasController controller, String token, String codhabilitado) {
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
                          if (picked != null)
                            controller.fechaInicio.value = picked;
                        },
                        child: Text('${controller.fechaInicio.value.toLocal()}'
                            .split(' ')[0]),
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
                          if (picked != null)
                            controller.fechaFin.value = picked;
                        },
                        child: Text('${controller.fechaFin.value.toLocal()}'
                            .split(' ')[0]),
                      )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => controller.isLoading.value
            ? const Center(
                child: Column(
                children: [
                  SizedBox(height: 16),
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Consultando, por favor espere...'),
                ],
              ))
            : ElevatedButton(
                onPressed: () {
                  controller.consultarAltas(
                    token: token,
                    codhabilitado: codhabilitado,
                  );
                },
                child: const Text('Consultar'),
              )),
        const SizedBox(height: 16),
        Obx(() => Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: ['Todos', 'Procesado', 'Rechazado', 'Pendiente']
                  .map((status) {
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

  Widget _buildCardView(ConsultasController controller, Function getEstadoInfo,
      Function formatArete, BuildContext context) {
    return ListView.builder(
      itemCount: controller.filteredResultados.length,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        final item = controller.filteredResultados[index];
        final estadoInfo = getEstadoInfo(item['estadoproceso']?.toString());
        final estadoTexto = estadoInfo['texto'];
        final estadoColor = estadoInfo['color'];

        // Determinar si está procesado
        final bool estaProcesado = item['estadoproceso']?.toString() == '1';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          'ID Alta: ${item['idAlta'] ?? ''}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                            'Rango: ${formatArete(item['rangoInicial'])} - ${formatArete(item['rangoFinal'])} ',
                            style: const TextStyle(fontSize: 14)),
                        Row(
                          children: [
                            Expanded(
                                child: Text('CUPA: ${item['cupa'] ?? ''}',
                                    style: const TextStyle(fontSize: 14))),
                            Expanded(
                                child: Text(
                                    'Productor: ${item['NombreProductor'] ?? ''}',
                                    style: const TextStyle(fontSize: 14))),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text('CUE: ${item['cue'] ?? ''}',
                                    style: const TextStyle(fontSize: 14))),
                            Expanded(
                                child: Text('Finca: ${item['Finca'] ?? ''}',
                                    style: const TextStyle(fontSize: 14))),
                          ],
                        ),
                        if (item['motivorechazo'] != null &&
                            item['motivorechazo'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                                'Motivo rechazo: ${item['motivorechazo']}',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 1,
                    right: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
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
              if (estaProcesado)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        tooltip: 'Generar y Ver Ficha',
                        onPressed: () => controller.generarYMostrarFicha(item),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      if (item['FichaUrl'] != null && (item['FichaUrl'] as String).isNotEmpty)
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.whatsapp),
                          tooltip: 'Compartir Ficha (URL Original) por WhatsApp',
                          onPressed: () => _shareViaWhatsApp(item['FichaUrl'] as String),
                          color: Colors.green,
                        ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Tabla con scroll horizontal y vertical
  Widget _buildTableView(BuildContext context, ConsultasController controller,
      Function getEstadoInfo, Function formatArete, bool isLandscape) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Definir el ancho mínimo para la tabla
    final double tableMinWidth = isLandscape ? 1300 : 1300;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableMinWidth,
          child: Column(
            children: [
              // Encabezados
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    _buildTableHeader('ID', width: 70),
                    _buildTableHeader('Rango Inicial', width: 140),
                    _buildTableHeader('Rango Final', width: 140),
                    _buildTableHeader('CUPA', width: 100),
                    _buildTableHeader('Productor', width: 150),
                    _buildTableHeader('CUE', width: 80),
                    _buildTableHeader('Finca', width: 140),
                    _buildTableHeader('Estado', width: 100),
                    _buildTableHeader('Motivo Rechazo', width: 180),
                    _buildTableHeader('Acciones', width: 100),
                  ],
                ),
              ),

              // Filas
              ...controller.filteredResultados.map((item) {
                final estadoInfo =
                    getEstadoInfo(item['estadoproceso']?.toString());
                final bool estaProcesado =
                    item['estadoproceso']?.toString() == '1';

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: Colors.grey.shade300, width: 1)),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTableCell(item['idAlta'] ?? '', width: 70),
                        _buildTableCell(formatArete(item['rangoInicial']),
                            width: 140),
                        _buildTableCell(formatArete(item['rangoFinal']),
                            width: 140),
                        _buildTableCell(item['cupa'] ?? '', width: 100),
                        _buildTableCell(item['NombreProductor'] ?? '',
                            width: 150),
                        _buildTableCell(item['cue'] ?? '', width: 80),
                        _buildTableCell(item['Finca'] ?? '', width: 140),
                        Container(
                          width: 100,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 4),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 8),
                            decoration: BoxDecoration(
                              color: estadoInfo['color'].withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              estadoInfo['texto'],
                              style: TextStyle(
                                color: estadoInfo['color'],
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        _buildTableCell(item['motivorechazo']?.toString() ?? '',
                            width: 180, maxLines: 2),
                        Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          alignment: Alignment.center,
                          child: estaProcesado
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.picture_as_pdf_outlined),
                                      tooltip: 'Generar y Ver Ficha',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () =>
                                          controller.generarYMostrarFicha(item),
                                      color: theme.colorScheme.primary,
                                      iconSize: 20,
                                    ),
                                    if (item['FichaUrl'] != null && (item['FichaUrl'] as String).isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12.0),
                                        child: IconButton(
                                          icon:
                                              const Icon(FontAwesomeIcons.whatsapp),
                                          tooltip: 'Compartir Ficha (URL Original) por WhatsApp',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () =>
                                              _shareViaWhatsApp(item['FichaUrl'] as String),
                                          color: Colors.green,
                                          iconSize: 18,
                                        ),
                                      ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
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

  // Widget para encabezados de tabla con ancho específico
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

  // Widget para celdas de tabla con ancho específico
  Widget _buildTableCell(String text,
      {required double width, int maxLines = 1}) {
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
