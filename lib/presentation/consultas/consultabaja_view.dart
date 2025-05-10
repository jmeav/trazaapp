import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/consultasbajas_controller.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/models/motivosbajabovino/motivosbajabovino.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ConsultaBajaView extends StatelessWidget {
  const ConsultaBajaView({Key? key}) : super(key: key);

  Future<List<MotivoBajaBovino>> _fetchMotivosBaja() async {
    try {
      if (Hive.isBoxOpen('motivosBaja')) {
        final box = Hive.box<MotivoBajaBovino>('motivosBaja');
        return box.values.toList();
      } else {
        final box = await Hive.openBox<MotivoBajaBovino>('motivosBaja');
        return box.values.toList();
      }
    } catch (e) {
      print('Error al obtener motivos para la vista de consulta de bajas: $e');
      return []; // Retornar lista vacía en caso de error
    }
  }

  @override
  Widget build(BuildContext context) {
    final ConsultasBajasController controller = Get.find();
    final appConfigBox = Hive.box<AppConfig>('appConfig');
    final config = appConfigBox.get('config');
    final token = config?.imei ?? '';
    final codhabilitado = config?.codHabilitado ?? '';
    final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    Map<String, dynamic> getEstadoInfo(String? estado) {
      String estadoTexto;
      Color estadoColor;
      switch (estado) {
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

    String calcularDiasPendientes(String fechaRegistroStr) {
      try {
        final fechaRegistro = DateTime.parse(fechaRegistroStr);
        final now = DateTime.now();
        final diferencia = now.difference(fechaRegistro);
        return '${diferencia.inDays} días';
      } catch (e) {
        return 'N/A';
      }
    }

    void mostrarDetalleAretes(BuildContext context, List<dynamic> aretes) {
      // Función asíncrona para obtener los motivos del catálogo
      Future<List<MotivoBajaBovino>> obtenerMotivos() async {
        try {
          // Si la caja ya está abierta
          if (Hive.isBoxOpen('motivosBaja')) {
            final box = Hive.box<MotivoBajaBovino>('motivosBaja');
            return box.values.toList();
          } else {
            // Intentar abrir la caja
            final box = await Hive.openBox<MotivoBajaBovino>('motivosBaja');
            return box.values.toList();
          }
        } catch (e) {
          print('Error al obtener motivos: $e');
          return []; // Retornar lista vacía en caso de error
        }
      }

      // Mostrar un diálogo de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Obtener los motivos y actualizar el diálogo
      obtenerMotivos().then((motivos) {
        // Cerrar el diálogo de carga
        Navigator.pop(context);

        // Mostrar el diálogo con los detalles de aretes
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: const Text('Detalle de Aretes', style: TextStyle(fontSize: 16)),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: aretes.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final arete = aretes[index];
                      final String areteId = arete['arete']?.toString() ?? 'N/A';
                      final String motivoId = arete['motivoId']?.toString() ?? 'N/A';
                      
                      // Texto a mostrar por defecto si no se encuentra el nombre
                      String displayedMotivoText = 'ID: $motivoId';
                      
                      try {
                        // Intentar buscar el motivo en el catálogo cargado
                        if (motivos.isNotEmpty) {
                          final int motivoIdInt = int.parse(motivoId);
                          // Busca el motivo por ID. Si no lo encuentra o el nombre es vacío, usa el fallback
                          final motivo = motivos.firstWhere(
                            (m) => m.id == motivoIdInt && m.nombre.isNotEmpty,
                            orElse: () => MotivoBajaBovino(id: 0, nombre: '') // Devuelve un motivo dummy si no cumple la condición
                          );
                          
                          // Si se encontró un motivo con nombre válido, usarlo
                          if (motivo.nombre.isNotEmpty) {
                             displayedMotivoText = motivo.nombre; 
                          }
                        } else {
                           // Si la lista de motivos está vacía, informar por consola
                           print('Catálogo de motivos de baja vacío en Hive.');
                        }
                      } catch (e) {
                        // Si hay un error (ej: parseo de ID), mantener el texto por defecto
                        print('Error al buscar el motivo en el catálogo: $e');
                      }
                      
                      return ListTile(
                        title: Text('Arete: $areteId', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('$displayedMotivoText'),
                        leading: const Icon(Icons.bookmark, color: Colors.blue),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }).catchError((error) {
        // Cerrar el diálogo de carga en caso de error
        Navigator.pop(context);
        
        // Mostrar error
        Get.snackbar(
          'Error al cargar catálogo',
          'No se pudo cargar el catálogo de motivos de baja desde el almacenamiento local. Los motivos se mostrarán por ID.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.2),
          colorText: Colors.red,
          duration: const Duration(seconds: 5)
        );
        
        // Mostrar el diálogo sin motivos, solo con IDs
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: const Text('Detalle de Aretes', style: TextStyle(fontSize: 16)),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: aretes.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final arete = aretes[index];
                      final String areteId = arete['arete']?.toString() ?? 'N/A';
                      final String motivoId = arete['motivoId']?.toString() ?? 'N/A';
                      
                      // Si no se pudo cargar el catálogo, mostrar solo el ID
                      return ListTile(
                        title: Text('Arete: $areteId', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('ID: $motivoId'),
                        leading: const Icon(Icons.bookmark, color: Colors.blue),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Bajas'),
        actions: [
          GetBuilder<ConsultasBajasController>(
            builder: (controller) => IconButton(
              icon: Icon(
                controller.isCardView.value
                    ? Icons.table_rows_outlined
                    : Icons.view_agenda_outlined
              ),
              tooltip: controller.isCardView.value
                  ? 'Ver como tabla'
                  : 'Ver como tarjetas',
              onPressed: () => controller.toggleViewMode(),
            ),
          ),
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
                    // Usar FutureBuilder para cargar los motivos antes de construir las vistas
                    return FutureBuilder<List<MotivoBajaBovino>>(
                      future: _fetchMotivosBaja(),
                      builder: (context, snapshotMotivos) {
                        // Aunque los motivos estén cargando o fallen, construimos la vista.
                        // Las funciones _buildCardView y _buildTableView manejarán una lista de motivos vacía o nula.
                        final List<MotivoBajaBovino> motivos = snapshotMotivos.data ?? [];
                        
                        // Pequeño indicador si los motivos aún no están listos pero hay resultados.
                        if (snapshotMotivos.connectionState == ConnectionState.waiting && controller.filteredResultados.isNotEmpty) {
                            // Podríamos mostrar un indicador sutil aquí, o simplemente dejar que la vista se construya
                            // y los motivos se resuelvan a IDs/texto original temporalmente.
                            // Por simplicidad, dejaremos que se construya directamente.
                        }

                        if (snapshotMotivos.hasError) {
                          print("Error cargando motivos en FutureBuilder: ${snapshotMotivos.error}");
                          // Proceder con motivos vacíos si hay error
                        }
                        
                        return controller.isCardView.value
                            ? _buildCardView(controller, getEstadoInfo, context, _dateFormat, calcularDiasPendientes, mostrarDetalleAretes, motivos)
                            : _buildTableView(context, controller, getEstadoInfo, isLandscape, _dateFormat, calcularDiasPendientes, mostrarDetalleAretes, motivos);
                      }
                    );
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

  Widget _buildCardView(
    ConsultasBajasController controller, 
    Function getEstadoInfo, 
    BuildContext context, 
    DateFormat dateFormat, 
    Function calcularDiasPendientes,
    Function mostrarDetalleAretes,
    List<MotivoBajaBovino> motivos
  ) {
    return ListView.builder(
      itemCount: controller.filteredResultados.length,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        final item = controller.filteredResultados[index];
        final estado = item['estadoproceso']?.toString() ?? '0';
        final motivoRechazoOriginal = item['motivorechazo']?.toString() ?? '';
        final estadoInfo = getEstadoInfo(estado);
        final estadoTexto = estadoInfo['texto'];
        final estadoColor = estadoInfo['color'];
        final String idBaja = item['idBaja']?.toString() ?? 'N/A';
        final String cupa = item['cupa']?.toString() ?? 'N/A';
        final String cue = item['cue']?.toString() ?? 'N/A';
        final String fechaRegistroStr = item['fecharegistro']?.toString() ?? '';
        final String fechaBajaStr = item['fechabaja']?.toString() ?? '';
        final List<dynamic> detalleBovinos = item['detallearetes'] ?? [];
        
        DateTime? fechaRegistroDate;
        try {
          if (fechaRegistroStr.isNotEmpty) fechaRegistroDate = DateTime.parse(fechaRegistroStr);
        } catch (e) {}
        
        DateTime? fechaBajaDate;
        try {
          if (fechaBajaStr.isNotEmpty) fechaBajaDate = DateTime.parse(fechaBajaStr);
        } catch (e) {}
        
        final bool estaPendiente = estado == '0';
        final String diasPendientes = estaPendiente && fechaRegistroDate != null 
            ? calcularDiasPendientes(fechaRegistroStr)
            : '';

        String motivoRechazoDisplay = '';
        if (motivoRechazoOriginal.isNotEmpty && motivoRechazoOriginal != "0000-00-00 00:00:00") {
          try {
            final int motivoId = int.parse(motivoRechazoOriginal);
            if (motivos.isNotEmpty) {
              final motivoEncontrado = motivos.firstWhere(
                (m) => m.id == motivoId && m.nombre.isNotEmpty,
                orElse: () => MotivoBajaBovino(id: 0, nombre: '') // Dummy si no se encuentra o nombre vacío
              );
              if (motivoEncontrado.nombre.isNotEmpty) {
                motivoRechazoDisplay = motivoEncontrado.nombre;
              } else {
                // Si se parsea a int pero no se encuentra en catálogo o el nombre es vacío, mostrar ID.
                motivoRechazoDisplay = 'ID Motivo: $motivoId'; 
              }
            } else {
              // Si el catálogo de motivos está vacío, pero el motivo original es un ID numérico
              motivoRechazoDisplay = 'ID Motivo: $motivoId';
            }
          } catch (e) {
            // No es un ID numérico, o error de parseo, usar el string original.
            motivoRechazoDisplay = motivoRechazoOriginal;
          }
        }
        // No mostramos nada si el motivo original era la fecha/hora nula "0000-00-00 00:00:00"

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
                        if (fechaRegistroDate != null)
                          Text('Fecha Registro: ${dateFormat.format(fechaRegistroDate)}', style: const TextStyle(fontSize: 14)),
                        if (fechaBajaDate != null)
                          Text('Fecha Baja: ${dateFormat.format(fechaBajaDate)}', style: const TextStyle(fontSize: 14)),
                        if (estaPendiente && diasPendientes.isNotEmpty)
                          Text(
                            'Pendiente desde hace: $diasPendientes', 
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)
                          ),
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
                        if (motivoRechazoDisplay.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Motivo rechazo: $motivoRechazoDisplay', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
                  Positioned(
                    bottom: 0,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.blue),
                      onPressed: () => mostrarDetalleAretes(context, detalleBovinos),
                      tooltip: 'Ver detalle de aretes',
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

  Widget _buildTableView(
    BuildContext context, 
    ConsultasBajasController controller, 
    Function getEstadoInfo, 
    bool isLandscape, 
    DateFormat dateFormat, 
    Function calcularDiasPendientes,
    Function mostrarDetalleAretes,
    List<MotivoBajaBovino> motivos
  ) {
    final theme = Theme.of(context);
    final double tableMinWidth = isLandscape ? 1200 : 1200;
    
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
                    _buildTableHeader('Fecha Registro', width: 150),
                    _buildTableHeader('Fecha Baja', width: 150),
                    _buildTableHeader('Aretes', width: 60),
                    _buildTableHeader('Estado', width: 100),
                    _buildTableHeader('Días Pendiente', width: 100),
                    _buildTableHeader('Motivo Rechazo', width: 200),
                  ],
                ),
              ),
              ...controller.filteredResultados.map((item) {
                final estado = item['estadoproceso']?.toString() ?? '0';
                final estadoInfo = getEstadoInfo(estado);
                final String idBaja = item['idBaja']?.toString() ?? 'N/A';
                final String cupa = item['cupa']?.toString() ?? 'N/A';
                final String cue = item['cue']?.toString() ?? 'N/A';
                final String fechaRegistroStr = item['fecharegistro']?.toString() ?? '';
                final String fechaBajaStr = item['fechabaja']?.toString() ?? '';
                final motivoRechazoOriginal = item['motivorechazo']?.toString() ?? '';
                final List<dynamic> detalleBovinos = item['detallearetes'] ?? [];
                
                DateTime? fechaRegistroDate;
                try {
                  if (fechaRegistroStr.isNotEmpty) fechaRegistroDate = DateTime.parse(fechaRegistroStr);
                } catch (e) {}
                
                DateTime? fechaBajaDate;
                try {
                  if (fechaBajaStr.isNotEmpty) fechaBajaDate = DateTime.parse(fechaBajaStr);
                } catch (e) {}
                
                final bool estaPendiente = estado == '0';
                final String diasPendientes = estaPendiente && fechaRegistroDate != null 
                    ? calcularDiasPendientes(fechaRegistroStr)
                    : 'N/A';

                String motivoRechazoDisplay = '';
                if (motivoRechazoOriginal.isNotEmpty && motivoRechazoOriginal != "0000-00-00 00:00:00") {
                  try {
                    final int motivoId = int.parse(motivoRechazoOriginal);
                     if (motivos.isNotEmpty) {
                        final motivoEncontrado = motivos.firstWhere(
                          (m) => m.id == motivoId && m.nombre.isNotEmpty,
                          orElse: () => MotivoBajaBovino(id: 0, nombre: '') // Dummy
                        );
                        if (motivoEncontrado.nombre.isNotEmpty) {
                          motivoRechazoDisplay = motivoEncontrado.nombre;
                        } else {
                          motivoRechazoDisplay = 'ID Motivo: $motivoId';
                        }
                    } else {
                        motivoRechazoDisplay = 'ID Motivo: $motivoId';
                    }
                  } catch (e) {
                    motivoRechazoDisplay = motivoRechazoOriginal;
                  }
                }
                // No mostramos nada si el motivo original era la fecha/hora nula "0000-00-00 00:00:00"

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
                        _buildTableCell(fechaRegistroDate != null ? dateFormat.format(fechaRegistroDate) : 'N/A', width: 150),
                        _buildTableCell(fechaBajaDate != null ? dateFormat.format(fechaBajaDate) : 'N/A', width: 150),
                        _buildTableCell(detalleBovinos.length.toString(), width: 60),
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
                          estaPendiente ? diasPendientes : 'N/A', 
                          width: 100
                        ),
                        _buildTableCell(
                          motivoRechazoDisplay, 
                          width: 200, 
                          maxLines: 2
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