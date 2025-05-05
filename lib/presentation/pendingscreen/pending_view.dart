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
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con ID, distancia y acciones
            Row(
              children: [
                Expanded(
                  child: Text(
                  'Entrega #${entrega.entregaId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ),
                if (entrega.distanciaCalculada != null)
                  Text(
                    entrega.distanciaCalculada!,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _mostrarDetallesEntrega(entrega),
                  tooltip: 'Ver detalles',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                if (entrega.tipo == 'manual')
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () => _confirmarEliminarEntrega(Get.context!, entrega.entregaId),
                    tooltip: 'Eliminar entrega',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            
            const Divider(height: 16),
            
            // Información principal en formato horizontal
            Row(
              children: [
                // Columna izquierda: Establecimiento y CUE
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entrega.nombreEstablecimiento,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'CUE: ${entrega.cue}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(Get.context!).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Columna derecha: Productor y CUPA
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entrega.nombreProductor,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'CUPA: ${entrega.cupa}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(Get.context!).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Columna cantidad de aretes
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(Get.context!).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${entrega.cantidad} aretes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Fecha y botón
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatFecha(entrega.fechaEntrega),
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(Get.context!).textTheme.bodySmall?.color,
                  ),
                ),
                
                if (entrega.estado.trim().toLowerCase() == 'pendiente')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.assignment_turned_in, size: 18),
                    label: const Text('Realizar'),
                    onPressed: () => _mostrarDialogoTipoEntrega(entrega),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size(100, 36),
                    ),
                  ),
              ],
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoTipoEntrega(Entregas entrega) {
    // Verificar si ya existe una reposición para esta entrega
    final bool tieneReposicion = controller.entregasBox.values.any(
      (e) => e.entregaId.startsWith('${entrega.entregaId}_repo')
    );

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

                List<String> aretesParaForm = [];

                if (entrega.tipo == 'manual') {
                  aretesParaForm = (entrega.aretesAsignados ?? []).map((e) => e.toString()).toList();
                  if (aretesParaForm.isEmpty) {
                    Get.snackbar('Error', 'La entrega manual no tiene aretes asignados registrados.');
                    return;
                  }
                } else {
                  if (entrega.rangoInicial != null && entrega.cantidad > 0) {
                    aretesParaForm = List.generate(
                       entrega.cantidad, 
                       (i) => (entrega.rangoInicial! + i).toString()
                    );
                  } else {
                     Get.snackbar('Error', 'La entrega de sistema no tiene un rango válido para generar aretes.');
                     return;
                  }
                }
                    
                Get.toNamed('/formbovinos', arguments: {
                  'aretes': aretesParaForm,
                  'entrega': entrega,
                });
              },
              child: Text('Uso Normal (${entrega.cantidad} aretes)'),
            ),
            if (!tieneReposicion) ...[
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  _handleReposicion(entrega);
                },
                child: const Text('Uso Parcial con Reposición'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleReposicion(Entregas entrega) {
    final cantidadController = TextEditingController();
    bool isDialogOpen = true;

    void handleAccept() {
      if (!isDialogOpen) return;
      final cantidad = int.tryParse(cantidadController.text);
      if (cantidad != null && cantidad > 0 && cantidad <= entrega.cantidad) {
        isDialogOpen = false;
        Get.back();
        controller.configurarReposicion(entrega.entregaId, cantidad);
        // No mostramos mensaje de éxito aquí ya que el controller lo manejará
      } else {
        Get.snackbar(
          'Error',
          'Por favor ingrese una cantidad válida (entre 1 y ${entrega.cantidad})',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

    void handleCancel() {
      if (!isDialogOpen) return;
      isDialogOpen = false;
      Get.back();
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Cantidad para reposición'),
        content: TextField(
          controller: cantidadController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Ingrese la cantidad para reposición',
            hintText: 'Máximo: ${entrega.cantidad}',
          ),
          onChanged: (value) {
            final cantidad = int.tryParse(value);
            if (cantidad != null && (cantidad <= 0 || cantidad > entrega.cantidad)) {
              Get.snackbar(
                'Error',
                'La cantidad debe estar entre 1 y ${entrega.cantidad}',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (isDialogOpen) {
                isDialogOpen = false;
                Navigator.of(Get.context!).pop();
              }
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: handleAccept,
            child: const Text('Aceptar'),
          ),
        ],
      ),
    ).then((_) {
      if (isDialogOpen) {
        isDialogOpen = false;
        cantidadController.dispose();
      }
    });
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

  void _mostrarDetallesEntrega(Entregas entrega) {
    Get.dialog(
      AlertDialog(
        title: Text('Detalles de Entrega'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', entrega.entregaId),
              _buildDetailRow('Fecha', formatFecha(entrega.fechaEntrega)),
              _buildDetailRow('Tipo', entrega.tipo),
              _buildDetailRow('Estado', entrega.estado),
              _buildDetailRow('Departamento', entrega.departamento),
              _buildDetailRow('Municipio', entrega.municipio),
              _buildDetailRow('Establecimiento', entrega.nombreEstablecimiento),
              _buildDetailRow('CUE', entrega.cue),
              _buildDetailRow('Productor', entrega.nombreProductor),
              _buildDetailRow('CUPA', entrega.cupa),
              _buildDetailRow('Cantidad', '${entrega.cantidad} aretes'),
              _buildDetailRow('Rango Principal', '${entrega.rangoInicial} - ${entrega.rangoFinal}'),
              if (entrega.esRangoMixto && entrega.rangoInicialExt != null && entrega.rangoFinalExt != null)
                _buildDetailRow('Rango Extra', '${entrega.rangoInicialExt} - ${entrega.rangoFinalExt}'),
              if (entrega.distanciaCalculada != null)
                _buildDetailRow('Distancia', entrega.distanciaCalculada!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
