import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/entregas/controller/entrega_controller.dart';

class EntregasView extends StatelessWidget {
  final EntregaController controller = Get.find<EntregaController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entregas Pendientes'),
      ),
      body: Obx(() {
        if (controller.entregas.isEmpty) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: controller.entregas.length,
            itemBuilder: (context, index) {
              final entrega = controller.entregas[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cue: ${entrega.cue}'),
                      Text('Fecha Entrega: ${entrega.fechaEntrega}'),
                      Text('Estado: ${entrega.estado}', style: TextStyle(color: entrega.estado == 'Vigente' ? Colors.green : Colors.red)),
                      Text('Cantidad: ${entrega.cantidad}'),
                      Text('Rango: ${entrega.rango}'),
                      Text('Distancia: ${entrega.distanciaCalculada}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Aquí manejaremos la interacción con las coordenadas
                              print('Latitud: ${entrega.coordenadas.latitud}, Longitud: ${entrega.coordenadas.longitud}');
                            },
                            child: Text('Realizar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }
}
