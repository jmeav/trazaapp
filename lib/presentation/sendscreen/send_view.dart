import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/presentation/sendscreen/resumen_view.dart';
import 'package:trazaapp/data/local/models/altaentrega/altaentrega.dart';

class EnviarView extends StatefulWidget {
  EnviarView({Key? key}) : super(key: key);

  @override
  State<EnviarView> createState() => _EnviarViewState();
}

class _EnviarViewState extends State<EnviarView> {
  final EntregaController controller = Get.put(EntregaController());
  final JsonEncoder _encoder = const JsonEncoder.withIndent('  ');
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Enviar Altas')),
      body: Obx(() {
        if (controller.altasListas.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No tienes altas listas para enviar.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          if (isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Enviando alta, por favor espera...'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: controller.refreshData,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${controller.altasListas.length} Altas listas',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.altasListas.length,
                    itemBuilder: (context, index) {
                      final alta = controller.altasListas[index];
                      
                      // Filtrar para mostrar solo altas normales (no reposiciones)
                      if (alta.reposicion) {
                        return const SizedBox.shrink(); // No mostrar reposiciones
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
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
                                  Text(
                                    'ID: ${alta.idAlta}',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Chip(
                                    avatar: Icon(Icons.tag, size: 14, color: theme.colorScheme.primary),
                                    label: Text('${alta.detalleBovinos.length} Bovinos'),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                    labelPadding: const EdgeInsets.only(left: 2),
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('CUE: ${alta.cue}', style: theme.textTheme.bodyMedium),
                              Text('Fecha: ${alta.fechaAlta}', style: theme.textTheme.bodySmall),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildActionButton(
                                    context: context,
                                    icon: Icons.cloud_upload,
                                    label: 'Enviar',
                                    color: theme.colorScheme.primary,
                                    onPressed: isLoading
                                        ? () {}
                                        : () => _enviarAltaAsync(alta.idAlta),
                                  ),
                                  
                                  _buildActionButton(
                                    context: context,
                                    icon: Icons.preview_outlined,
                                    label: 'Revisar',
                                    color: theme.colorScheme.secondary,
                                    onPressed: () {
                                      Get.to(() => ResumenAltaView(alta: alta));
                                    },
                                  ),
                                  
                                  _buildActionButton(
                                    context: context,
                                    icon: Icons.delete_outline,
                                    label: 'Eliminar',
                                    color: theme.colorScheme.error,
                                    onPressed: () => _confirmDeleteAlta(context, alta.idAlta),
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
            ),
          );
        }
      }),
    );
  }

  Widget _buildActionButton({required BuildContext context, required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
     final theme = Theme.of(context);
     return TextButton.icon(
        icon: Icon(icon, size: 18, color: color), 
        label: Text(label, style: TextStyle(color: color)), 
        style: TextButton.styleFrom(
           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed,
     );
  }

  Future<void> _confirmDeleteAlta(BuildContext context, String altaId) async {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
              '¿Estás seguro de eliminar esta alta pendiente? Se perderá toda la información asociada.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Get.back(result: true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );

      if (confirm == true) {
         try {
            await controller.eliminarAlta(altaId); 
            Get.back();
         } catch(e) {
            Get.back();
         }
      }
  }

  void _enviarAltaAsync(String idAlta) async {
    setState(() {
      isLoading = true;
    });
    try {
      await controller.enviarAlta(idAlta);
    } catch (e) {
      String mensajeError = 'Error al enviar la alta';
      String tituloError = 'Error';
      
      if (e.toString().contains('DUPLICATE_ENTRY')) {
        tituloError = 'Error de Duplicado';
        mensajeError = 'Esta alta ya fue enviada anteriormente';
      } else if (e.toString().contains('CONNECTION_ERROR')) {
        tituloError = 'Error de Conexión';
        mensajeError = 'No hay conexión a internet. Por favor, verifica tu conexión e intenta nuevamente';
      } else if (e.toString().contains('SERVER_ERROR')) {
        tituloError = 'Error del Servidor';
        mensajeError = 'El servidor ha rechazado la solicitud. Por favor, contacta al administrador';
      }
      
      Get.snackbar(
        tituloError,
        mensajeError,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }
}
