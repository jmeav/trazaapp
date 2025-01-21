import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/presentation/pending_ent/rev_view.dart';

class EnviarView extends StatelessWidget {
  final EntregaController controller = Get.find<EntregaController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión Altas'),
      ),
      body: Obx(() {
        // Filtrar entregas listas para enviar
        final entregasListas = controller.entregasListas;

        if (entregasListas.isEmpty) {
          return const Center(
            child: Text(
              'No tienes entregas listas para enviar.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        } else {
          return RefreshIndicator(
            onRefresh: controller.refreshData,
            child: ListView.builder(
              itemCount: entregasListas.length,
              itemBuilder: (context, index) {
                final entrega = entregasListas[index];

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cue: ${entrega.cue}'),
                        Text('Fecha Entrega: ${entrega.fechaEntrega}'),
                        Text(
                          'Estado: ${entrega.estado}',
                          style: TextStyle(
                            color: entrega.estado == 'Lista'
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                        Text('Cantidad: ${entrega.cantidad}'),
                        Text('Rango: ${entrega.rangoFinal}'),
                        Text('Distancia: ${entrega.distanciaCalculada}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Botón Revisar
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              onPressed: () {
                                // Navegar a la pantalla de revisión con los datos de la entrega
                                Get.to(() => RevisionView(), arguments: {
                                  'entregaId': entrega.entregaId,
                                });
                              },
                              child: const Text(
                                'Revisar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Botón Eliminar
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                // Confirmación para eliminar
                                final confirm = await Get.dialog(
                                  AlertDialog(
                                    title: const Text('Confirmar eliminación'),
                                    content: const Text(
                                        '¿Estás seguro de eliminar esta entrega? Se perderá toda la información asociada.'),
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
                                  // Eliminar la información asociada a la entrega
                                  await controller
                                      .deleteEntregaYBovinos(entrega.entregaId);

                                  // Mostrar mensaje de éxito
                                  Get.snackbar(
                                    'Éxito',
                                    'La entrega ${entrega.entregaId} ha sido eliminada.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              child: const Text(
                                'Eliminar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Botón Enviar
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () async {
                                // Actualizamos el estado de la entrega a "Enviado"
                                await controller.updateEntregaEstado(
                                  entrega.entregaId,
                                  'Enviado',
                                );

                                // Mostramos mensaje de éxito
                                Get.snackbar(
                                  'Éxito',
                                  'La entrega ${entrega.entregaId} ha sido enviada con éxito.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );

                                // Volvemos al home
                                Get.offAllNamed('/home');
                              },
                              child: const Text(
                                'Enviar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      }),
    );
  }
}
