import 'dart:convert'; // Para JsonEncoder
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para Clipboard
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Importar para formatear fecha
import 'package:collection/collection.dart'; // Importar para firstWhereOrNull
import 'package:trazaapp/controller/baja_controller.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/data/models/baja/baja_model.dart'; // Importar Baja
import 'package:trazaapp/data/models/motivosbajabovino/motivosbajabovino.dart';
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
      controller.cargarBajasPendientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bajas Pendientes'), // Título actualizado
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
        // Mostrar indicador de carga mientras isLoading es true
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
        
        // Si no hay bajas pendientes, mostrar mensaje
        if (controller.bajasPendientes.isEmpty) {
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
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/baja/form'),
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar Baja'),
                  style: ElevatedButton.styleFrom(
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                  ),
                ),
              ],
            ),
          );
        }
        
        // Mostrar la lista de bajas pendientes
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.bajasPendientes.length} Bajas pendientes',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.bajasPendientes.length,
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                itemBuilder: (context, index) {
                  final baja = controller.bajasPendientes[index];
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
                               Row( // Grupo CUE y Cantidad
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
                          // Fila de Botones
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
                                onPressed: () => controller.enviarBaja(baja.bajaId),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
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

    // Devolver el formato según includeId
    if (motivo != null) {
      return includeId ? "[${motivo.id}] ${motivo.nombre}" : motivo.nombre;
    } else {
      return "ID: $motivoId (Desconocido)";
    }
  }

} 