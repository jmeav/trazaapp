import 'dart:convert'; // Para JsonEncoder
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para Clipboard
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Importar para formatear fecha
import 'package:collection/collection.dart'; // Importar para firstWhereOrNull
import 'package:trazaapp/controller/baja_controller.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/data/local/models/baja/baja_model.dart'; // Importar Baja
import 'package:trazaapp/data/local/models/motivosbajabovino/motivosbajabovino.dart';
import 'package:trazaapp/data/local/models/bajasinorigen/baja_sin_origen.dart';
import 'package:hive/hive.dart';

class BajaSendView extends StatefulWidget {
  const BajaSendView({super.key});

  @override
  State<BajaSendView> createState() => _BajaSendViewState();
}

class _BajaSendViewState extends State<BajaSendView> {
  final BajaController controller = Get.find<BajaController>();
  final CatalogosController catalogsController = Get.find<CatalogosController>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm'); // Formato de fecha
  final JsonEncoder _encoder = const JsonEncoder.withIndent('  '); // Para formatear JSON

  @override
  void initState() {
    super.initState();
    // Cargar bajas al iniciar la vista si no están cargando ya
    if (!controller.isLoading.value) {
      Future.microtask(() => controller.cargarBajasPendientes());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Bajas'),
        actions: [
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.cargarBajasPendientes,
                  tooltip: 'Actualizar lista',
                ))
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.bajasPendientes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando bajas pendientes...'),
              ],
            ),
          );
        }

        // Obtener bajas sin origen
        final boxBajasSinOrigen = Hive.box<BajaSinOrigen>('bajassinorigen');
        final bajasSinOrigen = boxBajasSinOrigen.values.where((b) => b.estado == 'pendiente').toList();
        
        // Combinar ambas listas
        final totalBajas = controller.bajasPendientes.length + bajasSinOrigen.length;
        
        if (totalBajas == 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No hay bajas pendientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Registra nuevas bajas para enviar', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 24),             
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bajas pendientes',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (controller.bajasPendientes.isNotEmpty)
                            Chip(
                              label: Text('${controller.bajasPendientes.length} Bovinos'),
                              backgroundColor: theme.colorScheme.primaryContainer,
                            ),
                          if (controller.bajasPendientes.isNotEmpty && bajasSinOrigen.isNotEmpty)
                            const SizedBox(width: 8),
                          if (bajasSinOrigen.isNotEmpty)
                            Chip(
                              label: Text('${bajasSinOrigen.length} Sin Origen'),
                              backgroundColor: Colors.orange.withOpacity(0.2),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: totalBajas,
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                itemBuilder: (context, index) {
                  // Determinar si es una baja regular o sin origen
                  if (index < controller.bajasPendientes.length) {
                    final baja = controller.bajasPendientes[index];
                    return _buildBajaRegularCard(context, baja, theme);
                  } else {
                    final bajaSinOrigen = bajasSinOrigen[index - controller.bajasPendientes.length];
                    return _buildBajaSinOrigenCard(context, bajaSinOrigen, theme);
                  }
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBajaRegularCard(BuildContext context, Baja baja, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('CUE: ${baja.cue}', style: theme.textTheme.bodyLarge),
                    const SizedBox(width: 10),
                    Chip(
                      avatar: Icon(Icons.tag, size: 14, color: theme.colorScheme.secondary),
                      label: Text('${baja.cantidad} Aretes'),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                      labelPadding: const EdgeInsets.only(left: 2),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Fecha Baja: ${_dateFormat.format(baja.fechaBaja)}', style: theme.textTheme.bodySmall),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context: context,
                  icon: Icons.info_outline,
                  label: 'Detalles',
                  color: theme.colorScheme.secondary,
                  onPressed: () => _showBajaDetailsDialog(context, baja, catalogsController)
                ),
                _buildActionButton(
                  context: context,
                  icon: Icons.delete_outline,
                  label: 'Eliminar',
                  color: theme.colorScheme.error,
                  onPressed: () => _confirmDeleteBaja(context, baja.bajaId)
                ),
                _buildActionButton(
                  context: context,
                  icon: Icons.send,
                  label: 'Enviar',
                  color: Colors.green,
                  onPressed: () async {
                    try {
                      await controller.enviarBaja(baja.bajaId);
                      Get.snackbar(
                        'Éxito',
                        'Baja enviada correctamente',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    } catch (e) {
                      String mensajeError = 'Error al enviar la baja';
                      String tituloError = 'Error';
                      
                      if (e.toString().contains('DUPLICATE_ENTRY')) {
                        tituloError = 'Error de Duplicado';
                        mensajeError = 'Esta baja ya fue enviada anteriormente';
                      } else if (e.toString().contains('CONNECTION_ERROR')) {
                        tituloError = 'Error de Conexión';
                        mensajeError = 'No hay conexión a internet. Por favor, verifica tu conexión e intenta nuevamente';
                      } else if (e.toString().contains('SERVER_ERROR')) {
                        tituloError = 'Error del Servidor';
                        mensajeError = 'El servidor ha rechazado la solicitud. Por favor, contacta al administrador';
                      }               
                      // Get.snackbar(
                      //   tituloError,
                      //   mensajeError,
                      //   backgroundColor: Colors.red,
                      //   colorText: Colors.white,
                      //   duration: const Duration(seconds: 5),
                      // );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBajaSinOrigenCard(BuildContext context, BajaSinOrigen baja, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                     
                     Chip(
                      label: Text('Sin Origen', style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.bold
                      )),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                      labelPadding: const EdgeInsets.only(left: 2),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                    )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Fecha: ${_dateFormat.format(baja.fecha)}', style: theme.textTheme.bodySmall),
              Text('Arete: ${baja.arete}', style: theme.textTheme.bodySmall),
              if (baja.observaciones != null && baja.observaciones!.isNotEmpty)
                Text('Obs: ${baja.observaciones}', style: theme.textTheme.bodySmall),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    context: context,
                    icon: Icons.delete_outline,
                    label: 'Eliminar',
                    color: theme.colorScheme.error,
                    onPressed: () => _confirmDeleteBajaSinOrigen(context, baja.id)
                  ),
                  _buildActionButton(
                    context: context,
                    icon: Icons.send,
                    label: 'Enviar',
                    color: Colors.green,
                    onPressed: () async {
                      try {
                        await controller.enviarBajaSinOrigen(baja.id);
                        Get.snackbar(
                          'Éxito',
                          'Baja sin origen enviada correctamente',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } catch (e) {
                        String mensajeError = 'Error al enviar la baja sin origen';
                        String tituloError = 'Error';
                        
                        if (e.toString().contains('DUPLICATE_ENTRY')) {
                          tituloError = 'Error de Duplicado';
                          mensajeError = 'Esta baja ya fue enviada anteriormente';
                        } else if (e.toString().contains('CONNECTION_ERROR')) {
                          tituloError = 'Error de Conexión';
                          mensajeError = 'No hay conexión a internet. Por favor, verifica tu conexión e intenta nuevamente';
                        } else if (e.toString().contains('SERVER_ERROR')) {
                          tituloError = 'Error del Servidor';
                          mensajeError = 'El servidor ha rechazado la solicitud. Por favor, contacta al administrador';
                        }
                        
                        // Get.snackbar(
                        //   tituloError,
                        //   mensajeError,
                        //   backgroundColor: Colors.red,
                        //   colorText: Colors.white,
                        //   duration: const Duration(seconds: 5),
                        // );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Botón de acción reutilizable --- 
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0)
      ),
      onPressed: onPressed,
    );
  }

  // --- Dialog para confirmar eliminación --- 
  Future<void> _confirmDeleteBaja(BuildContext context, String bajaId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('¿Estás seguro de eliminar esta baja?'),
                const SizedBox(height: 8),
                Text('ID: $bajaId', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Esta acción no se puede deshacer.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                controller.eliminarBaja(bajaId);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  // --- Dialog para mostrar detalles de la baja --- 
  Future<void> _showBajaDetailsDialog(BuildContext context, Baja baja, CatalogosController catalogsController) async {
    final theme = Theme.of(context);
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalles de la Baja'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow(theme, 'ID Baja', baja.bajaId),
                _buildDetailRow(theme, 'CUE', baja.cue),
                _buildDetailRow(theme, 'CUPA', baja.cupa),
                _buildDetailRow(theme, 'Fecha Baja', _dateFormat.format(baja.fechaBaja)),
                _buildDetailRow(theme, 'Fecha Registro', _dateFormat.format(baja.fechaRegistro)),
                _buildDetailRow(theme, 'Evidencia', '${baja.tipoEvidencia.toUpperCase()} (${baja.evidencia.isNotEmpty ? "Adjunta" : "No adjunta"})'),
                const SizedBox(height: 10),
                Text('Aretes (${baja.detalleAretes.length}):', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Divider(),
                ...baja.detalleAretes.map((arete) {
                  final motivoNombre = _getNombreMotivo(int.tryParse(arete.motivoId) ?? 0, catalogsController, includeId: false);
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, left: 8.0),
                    child: Text('- ${arete.arete}: $motivoNombre'),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- Helper para fila de detalle en diálogo --- 
  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
         text: TextSpan(
           style: theme.textTheme.bodyMedium,
           children: [
             TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
             TextSpan(text: value),
           ]
         )
      )
    );
  }

  // --- Función para obtener nombre del motivo --- 
  String _getNombreMotivo(int motivoId, CatalogosController catalogsCtlr, {bool includeId = true}) {
    MotivoBajaBovino? motivo;
    // Intentar buscar en el controlador primero
    if (catalogsCtlr.motivosBajaBovino.isNotEmpty) {
       motivo = catalogsCtlr.motivosBajaBovino.firstWhereOrNull((m) => m.id == motivoId);
    }
    // Si no se encontró en el controlador, intentar buscar en la caja local
    if (motivo == null) {
       var box = Hive.box<MotivoBajaBovino>('motivosbajabovino');
       motivo = box.values.firstWhereOrNull((m) => m.id == motivoId);
    }
    // Log para depuración
    if (motivo == null) {
      print('[BAJA] Motivo de baja NO encontrado para ID: $motivoId');
      print('[BAJA] Motivos en controlador: ' + catalogsCtlr.motivosBajaBovino.map((m) => m.id).join(', '));
      var box = Hive.box<MotivoBajaBovino>('motivosbajabovino');
      print('[BAJA] Motivos en Hive: ' + box.values.map((m) => m.id).join(', '));
    }
    // Devolver el formato según includeId
    if (motivo != null) {
      return includeId ? "[${motivo.id}] ${motivo.nombre}" : motivo.nombre;
    } else {
      return "ID: $motivoId (Desconocido - revisa catálogo)";
    }
  }

  Future<void> _confirmDeleteBajaSinOrigen(BuildContext context, String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('¿Estás seguro de eliminar esta baja sin origen?'),
                const SizedBox(height: 8),
                Text('ID: $id', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Esta acción no se puede deshacer.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                controller.eliminarBajaSinOrigen(id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

} 