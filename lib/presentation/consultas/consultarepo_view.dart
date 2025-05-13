import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/consultasrepo_controller.dart'; // Importar el nuevo controller
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class ConsultasRepoView extends StatelessWidget {
  const ConsultasRepoView({Key? key}) : super(key: key);

  // --- Funciones auxiliares (similares a consultaalta_view) ---

  // Método para compartir por WhatsApp
  Future<void> _shareViaWhatsApp(String fichaUrl) async {
    final String mensaje = Uri.encodeComponent('Consulta la ficha de esta reposición: $fichaUrl');
    final String whatsappUrl = "https://wa.me/?text=$mensaje";
    try {
      final Uri url = Uri.parse(whatsappUrl);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo compartir: $e');
    }
  }

  // Método para mostrar PDF como imagen o abrir en app externa
  void _mostrarPDF(BuildContext context, String pdfUrl) {
      // Esta función puede ser idéntica a la de consultaalta_view
      // o adaptada si se necesita un comportamiento diferente
      showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Vista previa de ficha', style: TextStyle(fontSize: 16)),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () async {
                    try {
                      final Uri url = Uri.parse(pdfUrl);
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      Get.snackbar('Error', 'No se pudo abrir PDF: $e');
                    }
                    Navigator.pop(context);
                  },
                  tooltip: 'Abrir en navegador',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Mostrar PDF como imagen (o usar un visor de PDF si prefieres)
                  Image.network(
                    // Puedes usar el mismo método con Google Docs Viewer o un servicio similar
                    "https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(pdfUrl)}",
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Cargando vista previa...'),
                          ],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.picture_as_pdf, size: 72, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text(
                            'No se pudo cargar la vista previa',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('Abrir en el navegador'),
                            onPressed: () async {
                              try {
                                final Uri url = Uri.parse(pdfUrl);
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              } catch (e) {
                                Get.snackbar('Error', 'No se pudo abrir PDF: $e');
                              }
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ConsultasRepoController controller = Get.find(); // Usar el nuevo controller
    final appConfigBox = Hive.box<AppConfig>('appConfig');
    final config = appConfigBox.get('config');
    final token = config?.imei ?? '';
    final codhabilitado = config?.codHabilitado ?? '';
    final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm'); // Para mostrar fechas

    // Función para obtener estado y color (adaptada para reposiciones según JSON)
    Map<String, dynamic> getEstadoInfo(String? estado) {
      String estadoTexto;
      Color estadoColor;
      switch (estado) { // Ya viene como String desde la API
        case '1': // Procesado/Enviado
          estadoTexto = 'Procesado';
          estadoColor = Colors.green;
          break;
        case '2': // Rechazado
          estadoTexto = 'Rechazado';
          estadoColor = Colors.red;
          break;
        case '0': // Pendiente
        default:
          estadoTexto = 'Pendiente';
          estadoColor = Colors.orange;
      }
      return {'texto': estadoTexto, 'color': estadoColor};
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Reposiciones'), // Título actualizado
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
                // 1. Filtros (pueden ser los mismos)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: isLandscape && controller.filteredResultados.isNotEmpty ? 50 : null,
                  child: isLandscape && controller.filteredResultados.isNotEmpty 
                      ? Row(/* ... Controles de filtro para landscape ... */
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

                // 2. Contenido principal
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value && controller.resultados.isEmpty) {
                       return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.error.value != null) {
                      return Center(child: Text('Error: ${controller.error.value}', style: const TextStyle(color: Colors.red)));
                    }
                    if (controller.filteredResultados.isEmpty && !controller.isLoading.value) {
                      return const Center(child: Text('No hay reposiciones para mostrar con los filtros seleccionados.'));
                    }
                    // Usar las funciones de construcción de vista, adaptando los datos
                    return controller.isCardView.value
                        ? _buildCardView(controller, getEstadoInfo, context, _dateFormat)
                        : _buildTableView(context, controller, getEstadoInfo, isLandscape, _dateFormat);
                  }),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  // --- Widgets de construcción (adaptados de consultaalta_view) ---

  Widget _buildFilterControls(BuildContext context, ConsultasRepoController controller, String token, String codhabilitado) {
    // Este widget puede ser muy similar, solo cambia la función de consulta llamada
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
                  Text('Consultando reposiciones, por favor espere...'), // Texto actualizado
                ],
              ))
            : ElevatedButton(
                onPressed: () {
                  // Llamar a la función de consulta de reposiciones
                  controller.consultarRepos(
                    token: token,
                    codhabilitado: codhabilitado,
                  );
                },
                child: const Text('Consultar'), // Texto actualizado
              )),
        const SizedBox(height: 16),
        Obx(() => Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                // Ajustar los estados según la lógica de getEstadoInfo
                'Todos', 'Procesado', 'Rechazado', 'Pendiente' 
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

  // --- Vista de Tarjetas (Adaptada para Reposiciones) ---
  Widget _buildCardView(ConsultasRepoController controller, Function getEstadoInfo, BuildContext context, DateFormat dateFormat) {
    return ListView.builder(
      itemCount: controller.filteredResultados.length,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        final item = controller.filteredResultados[index];
        // *** Campos ajustados según JSON ***
        final String idRepo = item['idRepo']?.toString() ?? 'N/A'; 
        final String entregaOrigen = item['entregaIdOrigen']?.toString() ?? 'N/A';
        final String cupa = item['cupa']?.toString() ?? 'N/A';
        final String cue = item['cue']?.toString() ?? 'N/A';
        final String fechaRepoStr = item['fechaRepo']?.toString() ?? ''; 
        final String estado = item['estadoproceso']?.toString() ?? '0'; // Campo de estado
        final String motivoRechazo = item['motivorechazo']?.toString() ?? ''; 
        final String? fichaUrl = item['pdfEvidencia'] as String?; // Usar pdfEvidencia para la ficha
        final List<dynamic> detalleBovinos = item['detalleBovinos'] ?? [];

        final estadoInfo = getEstadoInfo(estado);
        final estadoTexto = estadoInfo['texto'];
        final estadoColor = estadoInfo['color'];
        final bool estaProcesado = estado == '1'; // Estado 1 es procesado/enviado
        
        DateTime? fechaRepoDate;
        try {
           if(fechaRepoStr.isNotEmpty) fechaRepoDate = DateTime.parse(fechaRepoStr);
        } catch(e) { /* Ignorar error de parseo */ }

        // Construcción de la tarjeta usando los campos correctos
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
                          'ID Repo: $idRepo',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text('Origen: $entregaOrigen', style: const TextStyle(fontSize: 14)),
                        Row(
                          children: [
                            Expanded(child: Text('CUPA: $cupa', style: const TextStyle(fontSize: 14))),
                            Expanded(child: Text('CUE: $cue', style: const TextStyle(fontSize: 14))),
                          ],
                        ),
                        if (fechaRepoDate != null)
                          Text('Fecha: ${dateFormat.format(fechaRepoDate)}', style: const TextStyle(fontSize: 14)),
                        // Cantidad de aretes en una línea
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Cantidad de aretes: ${detalleBovinos.length}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (motivoRechazo.isNotEmpty && motivoRechazo != "0000-00-00 00:00:00")
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Motivo rechazo: $motivoRechazo', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                  // Chip de estado igual que en consultaalta_view.dart
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

  // --- Vista de Tabla (Adaptada para Reposiciones) ---
  Widget _buildTableView(BuildContext context, ConsultasRepoController controller, Function getEstadoInfo, bool isLandscape, DateFormat dateFormat) {
    final theme = Theme.of(context);
    final double tableMinWidth = isLandscape ? 1300 : 1300; // Ajustar ancho

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableMinWidth,
          child: Column(
            children: [
              // Encabezados (Ajustar si es necesario)
              Container(
                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                 decoration: BoxDecoration(
                   color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                   borderRadius: BorderRadius.circular(4),
                 ),
                child: Row(
                  children: [
                    _buildTableHeader('ID Repo', width: 120),
                    _buildTableHeader('Origen', width: 120),
                    _buildTableHeader('CUPA', width: 130),
                    _buildTableHeader('CUE', width: 120),
                    _buildTableHeader('Aretes', width: 60),
                    _buildTableHeader('Fecha', width: 150),
                    _buildTableHeader('Estado', width: 100),
                    _buildTableHeader('Motivo Rechazo', width: 200),
                    _buildTableHeader('Acciones', width: 110), 
                  ],
                ),
              ),
              
              // Filas
              ...controller.filteredResultados.map((item) {
                 // *** Campos ajustados según JSON ***
                 final String idRepo = item['idRepo']?.toString() ?? 'N/A';
                 final String entregaOrigen = item['entregaIdOrigen']?.toString() ?? 'N/A';
                 final String cupa = item['cupa']?.toString() ?? 'N/A';
                 final String cue = item['cue']?.toString() ?? 'N/A';
                 final String fechaRepoStr = item['fechaRepo']?.toString() ?? '';
                 final String estado = item['estadoproceso']?.toString() ?? '0'; // Campo de estado
                 final String motivoRechazo = item['motivorechazo']?.toString() ?? ''; 
                 final String? fichaUrl = item['pdfEvidencia'] as String?; // Usar pdfEvidencia
                 final List<dynamic> detalleBovinos = item['detalleBovinos'] ?? [];

                 final estadoInfo = getEstadoInfo(estado);
                 final bool estaProcesado = estado == '1';
                 
                 DateTime? fechaRepoDate;
                 try {
                   if(fechaRepoStr.isNotEmpty) fechaRepoDate = DateTime.parse(fechaRepoStr);
                 } catch(e) { /* Ignorar error de parseo */ }

                // Construcción de la fila
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTableCell(idRepo, width: 120),
                        _buildTableCell(entregaOrigen, width: 120),
                        _buildTableCell(cupa, width: 130),
                        _buildTableCell(cue, width: 120),
                        _buildTableCell(detalleBovinos.length.toString(), width: 60), // Cantidad bovinos
                        _buildTableCell(fechaRepoDate != null ? dateFormat.format(fechaRepoDate) : 'N/A', width: 150),
                        // Celda de estado con color
                        Container(
                          width: 100,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
                        _buildTableCell(
                          (motivoRechazo.isNotEmpty && motivoRechazo != "0000-00-00 00:00:00") ? motivoRechazo : '' ,
                           width: 200, maxLines: 2
                        ),
                        // Celda de acciones eliminada, solo mostrar un espacio vacío
                        Container(
                          width: 110,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          alignment: Alignment.center,
                          child: const SizedBox.shrink(),
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

  // --- Widgets auxiliares de tabla (pueden ser los mismos) ---
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