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

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID Alta: ${alta.idAlta}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text('CUPA: ${alta.cupa}'),
                        Text('CUE: ${alta.cue}'),
                        Text('Fecha Alta: ${alta.fechaAlta}'),
                        Text('Cantidad Bovinos: ${alta.detalleBovinos.length}'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () async {
                                await controller.enviarAlta(alta.idAlta);
                              },
                              child: const Text(
                                'Enviar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () {
                                Get.to(() => ResumenAltaView(alta: alta));
                              },
                              child: const Text(
                                'Revisar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
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
                              child: const Text(
                                'Eliminar',
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
