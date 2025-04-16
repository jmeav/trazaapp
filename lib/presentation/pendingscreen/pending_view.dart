import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';

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
                return _buildEntregaCard(entrega);
              },
            ),
          );
        }
      }),
    );
  }

  Widget _buildEntregaCard(Entregas entrega) {
    // Calcular rangos y cantidades
    final cantidadTotal = entrega.cantidad;
    final cantidadReposicion = entrega.cantidadReposicion ?? 0;
    final cantidadNormal = cantidadTotal - cantidadReposicion;
    
    // Calcular rangos
    final rangoInicialNormal = entrega.rangoInicial;
    final rangoFinalNormal = entrega.rangoInicial + cantidadNormal - 1;
    final rangoInicialRepo = rangoFinalNormal + 1;
    final rangoFinalRepo = entrega.rangoFinal;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información general de la entrega
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Entrega #${entrega.entregaId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('📅 ${formatFecha(entrega.fechaEntrega)}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('📍 ${entrega.departamento}, ${entrega.municipio}'),
                if (entrega.distanciaCalculada != null)
                  Text('🚗 ${entrega.distanciaCalculada}'),
              ],
            ),
            Text('🏢 ${entrega.nombreEstablecimiento} (CUE: ${entrega.cue})'),
            Text('👨‍🌾 ${entrega.nombreProductor} (CUPA: ${entrega.cupa})'),
            Text('🔢 Rango: ${entrega.rangoInicial} - ${entrega.rangoFinal} (${entrega.cantidad} aretes)'),

            if (entrega.reposicion) ...[
              const Divider(height: 16),
              // Parte 1: Entrega Normal
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.blue[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Parte 1: Entrega Normal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('📦 $cantidadNormal'),
                      ],
                    ),
                    Text(
                      '🔢 $rangoInicialNormal - $rangoFinalNormal',
                      style: const TextStyle(fontSize: 13),
                    ),
                    if (entrega.estado != 'completada')
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _mostrarDialogoEntregaNormal(entrega, cantidadNormal, rangoInicialNormal, rangoFinalNormal),
                            child: const Text('Realizar Entrega Normal'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Parte 2: Reposición
              Container(
                padding: const EdgeInsets.all(8.0),
                color: entrega.estadoReposicion == 'completada'
                    ? Colors.green[50]
                    : Colors.grey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              entrega.estadoReposicion == 'completada'
                                  ? Icons.check_circle
                                  : Icons.pending,
                              color: entrega.estadoReposicion == 'completada'
                                  ? Colors.green
                                  : Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Parte 2: Reposición',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text('📦 $cantidadReposicion'),
                      ],
                    ),
                    Text(
                      '🔢 $rangoInicialRepo - $rangoFinalRepo',
                      style: const TextStyle(fontSize: 13),
                    ),
                    if (entrega.estadoReposicion != 'completada')
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _mostrarDialogoReposicion(entrega, cantidadReposicion, rangoInicialRepo, rangoFinalRepo),
                            child: const Text('Realizar Reposición'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              if (entrega.idAlta == null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _mostrarDialogoTipoEntrega(entrega),
                    child: const Text('Realizar Entrega'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoEntregaNormal(Entregas entrega, int cantidadNormal, int rangoInicial, int rangoFinal) {
    Get.dialog(
      AlertDialog(
        title: const Text('Realizar Entrega Normal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Desea realizar la entrega normal ahora?'),
            const SizedBox(height: 8),
            Text('Cantidad: $cantidadNormal'),
            Text('Rango: $rangoInicial - $rangoFinal'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/formbovinos', arguments: {
                'entregaId': entrega.entregaId,
                'cue': entrega.cue,
                'rangoInicial': rangoInicial,
                'rangoFinal': rangoFinal,
                'cantidad': cantidadNormal,
                'esReposicion': false,
              });
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoReposicion(Entregas entrega, int cantidadReposicion, int rangoInicial, int rangoFinal) {
    Get.dialog(
      AlertDialog(
        title: const Text('Realizar Reposición'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Desea realizar la reposición ahora?'),
            const SizedBox(height: 8),
            Text('Cantidad: $cantidadReposicion'),
            Text('Rango: $rangoInicial - $rangoFinal'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/formrepo', arguments: {
                'entregaId': entrega.entregaId,
                'rangoInicial': rangoInicial,
                'rangoFinal': rangoFinal,
                'cantidad': cantidadReposicion,
              });
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoTipoEntrega(Entregas entrega) {
    // Si es una reposición pendiente, mostrar diálogo específico
    if (entrega.reposicion && entrega.estadoReposicion == 'pendiente') {
      Get.dialog(
        AlertDialog(
          title: const Text('Completar Reposición'),
          content: const Text('¿Desea realizar la reposición ahora?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                // Ir al formulario de reposición
                Get.toNamed('/formrepo', arguments: {
                  'entregaId': entrega.entregaId,
                });
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
      return;
    }

    // Diálogo normal para entregas sin reposición
    Get.dialog(
      AlertDialog(
        title: const Text('Tipo de Entrega'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Cómo desea usar los aretes?'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.toNamed('/formbovinos', arguments: {
                  'entregaId': entrega.entregaId,
                  'cue': entrega.cue,
                  'rangoInicial': entrega.rangoInicial,
                  'rangoFinal': entrega.rangoFinal,
                  'cantidad': entrega.cantidad,
                  'esReposicion': false,
                });
              },
              child: Text('Uso Normal (${entrega.cantidad} aretes)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _mostrarDialogoCantidadParcial(entrega),
              child: const Text('Uso Parcial con Reposición'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoCantidadParcial(Entregas entrega) {
    final cantidadController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Configurar Reposición'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cantidad total disponible: ${entrega.cantidad}'),
            const SizedBox(height: 16),
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '¿Cuántas reposiciones necesita?',
                hintText: 'Ingrese cantidad de reposiciones',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final cantReposicion = int.tryParse(cantidadController.text);
              if (cantReposicion != null &&
                  cantReposicion > 0 &&
                  cantReposicion < entrega.cantidad) {
                Get.back();
                
                // Configurar la reposición usando el controlador
                await controller.configurarReposicion(entrega.entregaId, cantReposicion);
                
                // Refrescar la vista para mostrar la entrega dividida
                controller.refreshData();
              } else {
                Get.snackbar(
                  'Error',
                  'Ingrese una cantidad válida menor al total',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  String formatFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }

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
        Get.back();
      },
      onCancel: () {
        Get.back();
      },
    );
  }
}
