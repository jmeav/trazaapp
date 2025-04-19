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
      if (cantidad != null && cantidad < entrega.cantidad) {
        isDialogOpen = false;
        Get.back();
        controller.configurarReposicion(entrega.entregaId, cantidad);
        // No mostramos mensaje de éxito aquí ya que el controller lo manejará
      } else {
        Get.snackbar(
          'Error',
          'Por favor ingrese una cantidad válida',
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
      WillPopScope(
        onWillPop: () async {
          handleCancel();
          return false;
        },
        child: AlertDialog(
          title: const Text('Cantidad para reposición'),
          content: TextField(
            controller: cantidadController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Ingrese la cantidad para reposición',
              hintText: 'Máximo: ${entrega.cantidad - 1}',
            ),
            onChanged: (value) {
              final cantidad = int.tryParse(value);
              if (cantidad != null && cantidad >= entrega.cantidad) {
                Get.snackbar(
                  'Error',
                  'La cantidad debe ser menor al total',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: handleCancel,
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: handleAccept,
              child: const Text('Aceptar'),
            ),
          ],
        ),
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
}
