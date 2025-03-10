import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Importa intl para formatear la fecha
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/controller/entrega_controller.dart';

class EntregasView extends StatelessWidget {
  final EntregaController controller = Get.find<EntregaController>();
    final CatalogosController controller2 = Get.put(CatalogosController()); // ⬅️ Agregar esto


  @override
  Widget build(BuildContext context) {
    // 🔹 Forzar actualización de datos al entrar a la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshData();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión Pendientes'),
      ),
      body: Obx(() {
        if (controller.entregasPendientes.isEmpty) {
          return const Center(
            child: Text(
              'No tienes entregas pendientes.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        } else {
          return RefreshIndicator(
            onRefresh: controller.refreshData,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.entregasPendientes.length,
              itemBuilder: (context, index) {
                final entrega = controller.entregasPendientes[index];

                // 🔹 Formateo de fecha de entrega a dd/MM/yyyy
                String formattedDate = formatFecha(entrega.fechaEntrega);

                // 🔹 Validación segura de distancia
                final distanciaCalculadaStr =
                    entrega.distanciaCalculada?.replaceAll('KM', '').trim();
                final distanciaCalculadaDouble =
                    double.tryParse(distanciaCalculadaStr ?? '0') ?? 0.0;

                final isInRange = distanciaCalculadaDouble <= 150;
                final isMidRange = distanciaCalculadaDouble > 150 &&
                    distanciaCalculadaDouble <= 300;

                Color buttonColor;
                if (isInRange) {
                  buttonColor = Colors.green.shade600;
                } else if (isMidRange) {
                  buttonColor = Colors.blue.shade300;
                } else {
                  buttonColor = Colors.red.shade300;
                }

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 CUE y Nombre del Establecimiento
                        Text(
                          '📌 CUE: ${entrega.cue} - ${entrega.nombreEstablecimiento}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),

                        // 🔹 CUPA y Nombre del Productor
                        Text(
                          '👤 CUPA: ${entrega.cupa} - ${entrega.nombreProductor}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),

                        // 🔹 Fecha de entrega
                        Text(
                          '📅 Fecha de Entrega: $formattedDate',
                          style: const TextStyle(fontSize: 14),
                        ),

                        // 🔹 Estado de la entrega
                        Text(
                          '📍 Estado: ${entrega.estado}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: entrega.estado == 'Vigente'
                                  ? Colors.green
                                  : Colors.red),
                        ),

                        // 🔹 Rango de aretes y cantidad
                        Text(
                          '🔢 Rango: ${entrega.rangoInicial} - ${entrega.rangoFinal}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          '📦 Cantidad: ${entrega.cantidad}',
                          style: const TextStyle(fontSize: 14),
                        ),

                        // 🔹 Distancia en metros
                        Text(
                          '📏 Distancia: ${entrega.distanciaCalculada}',
                          style: const TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 10),

                        // 🔹 Botón para iniciar la entrega
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                            ),
                            onPressed: () {
                              Get.toNamed('/formbovinos', arguments: {
                                'entregaId': entrega.entregaId,
                                'cue': entrega.cue,
                                'rangoInicial': entrega.rangoInicial,
                                'rangoFinal': entrega.rangoFinal,
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

  /// 🔹 Función para formatear la fecha en `dd/MM/yyyy`

/// 🔹 Formatea la fecha `DateTime` a `dd/MM/yyyy`
String formatFecha(DateTime fecha) {
  return DateFormat('dd/MM/yyyy').format(fecha);
}

}
