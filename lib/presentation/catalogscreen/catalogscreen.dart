import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/data/local/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/local/models/bag/bag_operadora.dart';
import 'package:trazaapp/data/local/models/entregas/entregas.dart';

class CatalogosScreen extends StatelessWidget {
  final CatalogosController controller = Get.put(CatalogosController());

  String _formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Sin actualizar";
    }
  }

  Future<bool> _onWillPop() async {
    if (controller.isDownloading.value || controller.isForcedDownload.value) {
      Get.snackbar(
        'Espera',
        'No puedes salir mientras se actualizan los catálogos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Verificar si hay datos en las cajas
    final entregasBox = Hive.box<Entregas>('entregas');
    final bagBox = Hive.box<Bag>('bag');

    if (entregasBox.isEmpty && bagBox.isEmpty) {
      // Mostrar diálogo de confirmación
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('⚠️ Atención'),
          content: const Text(
            'Para continuar necesitas descargar los catálogos de entregas y aretes. '
            '¿Deseas descargarlos ahora?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Salir de la app'),
            ),
            TextButton(
              onPressed: () {
                final box = Hive.box<AppConfig>('appConfig');
                final config = box.get('config');
                if (config != null) {
                  controller.downloadAllCatalogsSequential(
                    token: config.token,
                    codhabilitado: config.codHabilitado,
                  );
                }
                Get.back(result: false);
              },
              child: const Text('Descargar ahora'),
            ),
          ],
        ),
      );

      return result ?? false;
    }

    return true;
  }

  void _handleDownloadComplete() {
    if (controller.isForcedDownload.value) {
      // Si fue una descarga forzada, ir al home
      Get.offAllNamed('/home');
    } else {
      // Si fue una actualización normal, mostrar mensaje y permitir volver
      Get.snackbar(
        '✅ Éxito',
        'Catálogos actualizados correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<AppConfig>('appConfig');
    final config = box.get('config');

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Actualización de catálogos"),
          centerTitle: true,
          automaticallyImplyLeading:
              !controller.isDownloading.value && !controller.isForcedDownload.value,
        ),
        body: Center(
          child: Obx(() {
            final percent =
                (controller.currentStep.value / controller.totalSteps).clamp(0.0, 1.0);
            final isDownloading = controller.isDownloading.value;

            if (!isDownloading && controller.currentStep.value == controller.totalSteps) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!ScaffoldMessenger.of(context).mounted) return;
                _handleDownloadComplete();
              });
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (controller.isForcedDownload.value)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        '🐄 ¡Bienvenido! Estamos descargando los catálogos para comenzar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  if (!isDownloading &&
                      controller.lastUpdateDepartamentos.isNotEmpty)
                    Text(
                      '📅 Última actualización: ${_formatDateTime(controller.lastUpdateDepartamentos.value)}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  const SizedBox(height: 40),
                  isDownloading
                      ? Column(
                          children: [
                            SizedBox(
                              height: 180,
                              child: Lottie.asset(
                                'assets/lottie/cow.json',
                                repeat: true,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 130,
                                  width: 130,
                                  child: CircularProgressIndicator(
                                    value: percent,
                                    strokeWidth: 10,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: const AlwaysStoppedAnimation(Colors.green),
                                  ),
                                ),
                                Text(
                                  "${(percent * 100).toInt()}%",
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Actualizando catálogos...",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        )
                      : controller.isForcedDownload.value
                          ? const SizedBox.shrink()
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 30.0),
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              icon: const Icon(Icons.system_update_alt, size: 28),
                              label: const Text("Actualizar catálogos"),
                              onPressed: () {
                                if (config != null) {
                                  controller.downloadAllCatalogsSequential(
                                    token: config.token,
                                    codhabilitado: config.codHabilitado,
                                  );
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Configuración no encontrada',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                            ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
