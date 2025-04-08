import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<AppConfig>('appConfig');
    final config = box.get('config');

    return WillPopScope(
      onWillPop: () async {
        if (controller.isDownloading.value || controller.isForcedDownload.value) {
          Get.snackbar(
            'Espera',
            'No puedes salir mientras se actualizan los catálogos',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return false;
        }
        return true;
      },
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ ¡Catálogos actualizados con éxito!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 3),
                  ),
                );
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
                                  Get.snackbar('Error', 'Configuración no encontrada');
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
