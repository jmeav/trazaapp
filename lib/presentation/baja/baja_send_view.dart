import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/baja_controller.dart';

class BajaSendView extends StatefulWidget {
  const BajaSendView({super.key});

  @override
  State<BajaSendView> createState() => _BajaSendViewState();
}

class _BajaSendViewState extends State<BajaSendView> {
  final BajaController controller = Get.find<BajaController>();

  @override
  void initState() {
    super.initState();
    // No necesitamos cargar las bajas aquí, el controlador lo hace en onReady
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Bajas'),
        backgroundColor: Colors.blue,
      ),
      body: Obx(() {
        // Mostrar indicador de carga mientras isLoading es true
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando bajas pendientes...'),
              ],
            ),
          );
        }
        
        // Si no hay bajas pendientes, mostrar mensaje
        if (controller.bajasPendientes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 48, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'No hay bajas pendientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Registra nuevas bajas para enviar'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/baja/form'),
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar Baja'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }
        
        // Mostrar la lista de bajas pendientes
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Bajas pendientes: ${controller.bajasPendientes.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: controller.cargarBajasPendientes,
                    tooltip: 'Actualizar lista',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.bajasPendientes.length,
                padding: const EdgeInsets.all(8.0),
                itemBuilder: (context, index) {
                  final baja = controller.bajasPendientes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Arete: ${baja.arete}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8, 
                                  vertical: 4
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Pendiente',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          _buildInfoRow('Motivo', baja.motivo),
                          _buildInfoRow('Fecha', baja.fechaBaja.toString().split(' ')[0]),
                          _buildInfoRow('CUE', baja.cue),
                          _buildInfoRow('CUPA', baja.cupa),
                          if (baja.evidencia.isNotEmpty)
                            _buildInfoRow('Evidencia', '📷 Disponible'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: Obx(() => FloatingActionButton.extended(
        onPressed: controller.bajasPendientes.isEmpty 
            ? null 
            : controller.enviarBajasPendientes,
        backgroundColor: controller.bajasPendientes.isEmpty 
            ? Colors.grey 
            : Colors.blue,
        icon: const Icon(Icons.send),
        label: const Text('Enviar'),
      )),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 