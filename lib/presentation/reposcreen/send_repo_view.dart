import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/controller/formrepo_controller.dart';
import 'package:trazaapp/data/models/repo/repoentrega.dart';
import 'package:trazaapp/presentation/reposcreen/resumen_repo_view.dart'; // Importar vista de resumen

class SendRepoView extends StatelessWidget {
  final EntregaController controller = Get.find<EntregaController>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

  SendRepoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args = Get.arguments;
    // if (args != null && args['showSuccess'] == true) {
    //   Future.microtask(() {
    //     Get.snackbar(
    //       'Guardado',
    //       'Reposición guardada y lista para enviar.',
    //       backgroundColor: Colors.green,
    //       colorText: Colors.white,
    //     );
    //   });
    // }
    // // Cargar reposiciones listas al construir la vista, si no están cargando ya
    // // Esto asegura que se muestren si vienes directo del formulario
    // if (!controller.isLoading.value) {
    //   Future.microtask(() => controller.cargarReposListas());
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Reposiciones'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.reposListas.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando reposiciones listas...'),
              ],
            ),
          );
        }

        if (controller.reposListas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No hay reposiciones listas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Completa formularios de reposición para que aparezcan aquí.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
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
                  Text(
                    '${controller.reposListas.length} Reposiciones listas',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),            
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.reposListas.length,
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                itemBuilder: (context, index) {
                  final repo = controller.reposListas[index];
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
                                   Icon(Icons.build_circle_outlined, size: 18, color: Colors.grey[600]),
                                   const SizedBox(width: 4),
                                   // Mostrar ID corto
                                   Text('ID: ${repo.idRepo.length > 5 ? repo.idRepo.substring(0, 5) : repo.idRepo}...', style: theme.textTheme.bodyLarge),
                                   const SizedBox(width: 10),
                                   Chip(
                                     avatar: Icon(Icons.tag, size: 14, color: theme.colorScheme.secondary),
                                     label: Text('${repo.detalleBovinos.length} Aretes'),
                                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                     labelPadding: const EdgeInsets.only(left: 2),
                                     visualDensity: VisualDensity.compact,
                                     backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                                    )
                                 ],
                               ),
                               Chip(
                                  label: Text(repo.estadoRepo, style: TextStyle(color: Colors.white)), 
                                  backgroundColor: Colors.orange, // Color para estado 'Lista'
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                  labelPadding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                               ),
                             ],
                           ),
                          const SizedBox(height: 4),
                          Text('Origen: ${repo.entregaIdOrigen}', style: theme.textTheme.bodySmall),
                          Text('Fecha Repo: ${_dateFormat.format(repo.fechaRepo)}', style: theme.textTheme.bodySmall),
                          const Divider(height: 16),
                          // Fila de Botones
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildActionButton(
                                context: context,
                                icon: Icons.preview_outlined,
                                label: 'Revisar/Editar',
                                color: theme.colorScheme.secondary,
                                onPressed: () => Get.to(() => ResumenRepoView(repo: repo)),
                              ),
                               _buildActionButton(
                                context: context,
                                icon: Icons.delete_outline,
                                label: 'Eliminar',
                                color: theme.colorScheme.error,
                                onPressed: () => _confirmDeleteRepo(context, repo.idRepo),
                              ),
                              _buildActionButton(
                                context: context,
                                icon: Icons.send,
                                label: 'Enviar',
                                color: Colors.green,
                                onPressed: () => controller.enviarReposicion(repo.idRepo),
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
  

  // --- Diálogo de confirmación para eliminar Repo --- 
  Future<void> _confirmDeleteRepo(BuildContext context, String repoId) async {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
              '¿Estás seguro de eliminar esta reposición lista? Esta acción no se puede deshacer.'),
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
        await controller.eliminarRepoLista(repoId); // Llama al método en el controller
      }
  }
} 