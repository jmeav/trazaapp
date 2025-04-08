import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/controller/entrega_controller.dart';

class EntregasView extends StatelessWidget {
  final EntregaController controller =
      Get.put(EntregaController(), permanent: true);
  final CatalogosController controller2 = Get.put(CatalogosController());

  @override
  Widget build(BuildContext context) {
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
                String formattedDate = formatFecha(entrega.fechaEntrega);

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 🔹 CUE y Nombre del Establecimiento
                            Expanded(
                              child: Text(
                                '📌 CUE: ${entrega.cue} - ${entrega.nombreEstablecimiento}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),

                            // 🔹 Botón de eliminar (solo si es manual)
                            if (entrega.tipo == "manual")
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                tooltip: "Eliminar entrega manual",
                                onPressed: () {
                                  _confirmarEliminarEntrega(
                                      context, entrega.entregaId);
                                },
                              ),
                          ],
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
                        Text(
                          '🔢 Rango: ${entrega.rangoInicial} - ${entrega.rangoFinal}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          '📦 Cantidad: ${entrega.cantidad}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          '📏 Ubicación: ${entrega.departamento}/${entrega.municipio}.',
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
                          child: // pending_view.dart
                              ElevatedButton(
                            onPressed: () {
                              // Aquí la entrega que estamos procesando
                              final entrega =
                                  controller.entregasPendientes[index];

                              // Mostramos un diálogo que pregunte cómo manejar los aretes
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Atención'),
                                  content: const Text(
                                    '¿Deseas usar todos los aretes para esta entrega '
                                    'o separar algunos para reposición?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        // Caso 1: usar TODOS
                                        Get.back(); // Cierra el diálogo

                                        // Lógica actual: ir al form de bovinos normal
                                        Get.toNamed('/formbovinos', arguments: {
                                          'entregaId': entrega.entregaId,
                                          'cue': entrega.cue,
                                          'rangoInicial': entrega.rangoInicial,
                                          'rangoFinal': entrega.rangoFinal,
                                          'cantidad': entrega.cantidad,
                                        });
                                      },
                                      child: const Text('Usar TODOS'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        // Caso 2: PARCIAL => mostrar un segundo diálogo pidiendo cuántos son para el uso normal
                                        final parcialSeleccion =
                                            await Get.dialog<int?>(
                                          AlertDialog(
                                            title: const Text(
                                                '¿Cuántos aretes usarás?'),
                                            content: TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText:
                                                    'Cantidad para uso normal',
                                              ),
                                              onSubmitted: (value) {
                                                final qty =
                                                    int.tryParse(value) ?? 0;
                                                // Cerrar el diálogo y devolver ese valor
                                                Get.back(result: qty);
                                              },
                                            ),
                                          ),
                                        );

                                        // Validar la cantidad ingresada
                                        if (parcialSeleccion == null ||
                                            parcialSeleccion <= 0 ||
                                            parcialSeleccion >=
                                                entrega.cantidad) {
                                          // Cancelado o inválido
                                          Get.back(); // cierra el primer diálogo
                                          return;
                                        }

                                        // 1) Sub-rango para el uso normal
                                        final cantNormal =
                                            parcialSeleccion; // p.ej: 7
                                        final rangoInicialNormal =
                                            entrega.rangoInicial;
                                        final rangoFinalNormal =
                                            rangoInicialNormal + cantNormal - 1;

                                        // 2) Sub-rango para reposición
                                        final cantRepos = entrega.cantidad -
                                            cantNormal; // p.ej: 3
                                        final rangoInicialRepos =
                                            rangoFinalNormal + 1;
                                        final rangoFinalRepos =
                                            rangoInicialRepos + cantRepos - 1;

                                        // Cerrar el primer diálogo
                                        Get.back();

                                        // (A) Ir a FormBovinos “normal” con 7 aretes
                                        Get.toNamed('/formbovinos', arguments: {
                                          'entregaId': entrega
                                              .entregaId, // la misma o ID distinto
                                          'cue': entrega.cue,
                                          'rangoInicial': rangoInicialNormal,
                                          'rangoFinal': rangoFinalNormal,
                                          'cantidad': cantNormal,
                                        });

                                        // (B) Luego, para los 3 de reposición, podemos crear
                                        // un nuevo modelo "RepoEntrega" y una nueva pantalla "FormReposicionView",
                                        // o reusar la misma vista con una bandera "reposicion = true".
                                        // Por ejemplo:
                                        Get.toNamed('/formreposicion',
                                            arguments: {
                                              'entregaId': entrega.entregaId,
                                              'cue': entrega.cue,
                                              'rangoInicial': rangoInicialRepos,
                                              'rangoFinal': rangoFinalRepos,
                                              'cantidad': cantRepos,
                                            });
                                      },
                                      child: const Text('Separar PARCIAL'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('Realizar'),
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
  String formatFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }

  /// 🔹 Función para confirmar eliminación de una entrega manual
  void _confirmarEliminarEntrega(BuildContext context, String entregaId) {
    Get.defaultDialog(
      title: "Eliminar Entrega",
      middleText: "¿Estás seguro de que deseas eliminar esta entrega manual?",
      textConfirm: "Eliminar",
      textCancel: "Cancelar",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteEntregaYBovinos(entregaId);
        Get.back(); // Cerrar el diálogo
      },
      onCancel: () {
        Get.back(); // Cerrar el diálogo sin hacer nada
      },
    );
  }
}
