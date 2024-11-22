import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/entrega_controller.dart';

class EntregasView extends StatelessWidget {
  final EntregaController controller = Get.find<EntregaController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entregas Pendientes'),
      ),
      body: Obx(() {
        if (controller.entregas.isEmpty) {
          return const Center(
            child: Text(
              'No tienes entregas pendientes.',
            ),
          );
        } else {
          return RefreshIndicator(
            displacement: 1,
            onRefresh: controller.refreshData,
            child: ListView.builder(
              itemCount: controller.entregas.length,
              itemBuilder: (context, index) {
                final entrega = controller.entregas[index];
                final distanciaCalculadaStr =
                    entrega.distanciaCalculada?.replaceAll('KM', '').trim();
                final distanciaCalculadaDouble =
                    double.tryParse(distanciaCalculadaStr!) ?? 0.0;
                final isInRange = distanciaCalculadaDouble <= 0.15;
                final isMidRange = distanciaCalculadaDouble > 0.15 &&
                    distanciaCalculadaDouble <= 0.3;

                Color buttonColor;
                if (isInRange) {
                  buttonColor = Colors.green.shade600; // Suave verde
                } else if (isMidRange) {
                  buttonColor = Colors.blue.shade300; // Suave azul
                } else {
                  buttonColor = Colors.red.shade300; // Suave rojo
                }

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cue: ${entrega.cue}'),
                        Text('Fecha Entrega: ${entrega.fechaEntrega}'),
                        Text('Estado: ${entrega.estado}',
                            style: TextStyle(
                                color: entrega.estado == 'Vigente'
                                    ? Colors.green
                                    : Colors.red)),
                        Text('Cantidad: ${entrega.cantidad}'),
                        Text('Rango: ${entrega.rangoFinal}'),
                        Text('Distancia: ${entrega.distanciaCalculada}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                              ),
                              onPressed: () {
                                Get.toNamed('/formbovinos', arguments: {
                                  'cue': entrega.cue,
                                  'rango': entrega.rangoFinal,
                                  'cantidad': entrega.cantidad,
                                });
                              },
                              child: const Text(
                                'Realizar',
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
