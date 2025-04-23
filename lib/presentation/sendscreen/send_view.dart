import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/presentation/sendscreen/resumen_view.dart';

class EnviarView extends StatelessWidget {
  final EntregaController controller = Get.put(EntregaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Altas Pendientes')),
      body: Obx(() {
        if (controller.altasListas.isEmpty) {
          return const Center(
            child: Text(
              'No tienes altas listas para enviar.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        } else {
          return RefreshIndicator(
            onRefresh: controller.refreshData,
            child: ListView.builder(
              itemCount: controller.altasListas.length,
              itemBuilder: (context, index) {
                final alta = controller.altasListas[index];
                
                // Verificar si es una alta de reposición
                final esReposicion = alta.reposicion;

                return Stack(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID Alta: ${alta.idAlta}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('CUPA: ${alta.cupa}'),
                                      Text('CUE: ${alta.cue}'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Fecha: ${alta.fechaAlta}'),
                                      Text('Bovinos: ${alta.detalleBovinos.length}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.cloud_upload, size: 18),
                                  label: const Text('Enviar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  onPressed: () async {
                                    await controller.enviarAlta(alta.idAlta);
                                  },
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.preview, size: 18),
                                  label: const Text('Revisar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                  ),
                                  onPressed: () {
                                    Get.to(() => ResumenAltaView(alta: alta));
                                  },
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Eliminar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                    foregroundColor: Theme.of(context).colorScheme.onError,
                                  ),
                                  onPressed: () async {
                                    final confirm = await Get.dialog(
                                      AlertDialog(
                                        title: const Text('Confirmar eliminación'),
                                        content: const Text(
                                            '¿Estás seguro de eliminar esta alta? Se perderá toda la información asociada.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Get.back(result: false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () => Get.back(result: true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await controller.eliminarAlta(alta.idAlta);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Etiqueta de reposición
                    if (esReposicion)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            'REPOSICIÓN',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        }
      }),
    );
  }
}
