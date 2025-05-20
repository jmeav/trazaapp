import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trazaapp/theme/theme_controller.dart';
import 'package:trazaapp/data/local/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/services/version_service.dart';

class ConfiguracionesScreen extends StatelessWidget {
  final ThemeController themeController = Get.find();
  final VersionService versionService = Get.put(VersionService());

  @override
  Widget build(BuildContext context) {
    final currentVersion = versionService.getCurrentVersion();
    final lastCheck = versionService.getLastCheck();
    String lastCheckText = lastCheck != null
        ? 'Última verificación: ${lastCheck.day.toString().padLeft(2, '0')}/${lastCheck.month.toString().padLeft(2, '0')}/${lastCheck.year} ${lastCheck.hour.toString().padLeft(2, '0')}:${lastCheck.minute.toString().padLeft(2, '0')}'
        : 'Nunca verificada';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Configuraciones",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌙 Sección de Apariencia
            _buildSectionTitle("Apariencia"),
            Obx(() {
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    themeController.themeData.value.brightness == Brightness.light
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Text(
                    "Modo Oscuro",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  trailing: Switch(
                    value: themeController.themeData.value.brightness == Brightness.dark,
                    onChanged: (value) => themeController.toggleTheme(context),
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // 📂 Sección de Catálogos
            _buildSectionTitle("Catálogos"),
            _buildButton(
              context: context,
              icon: Icons.folder_open,
              text: "Administrar Catálogos",
              onPressed: () => Get.toNamed('/catalogs'),
            ),

            const SizedBox(height: 20),

            // 🔄 Sección de Versión
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Versión de la App"),
                Text(
                  'v$currentVersion',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                lastCheckText,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
            _buildButton(
              context: context,
              icon: Icons.system_update,
              text: "Chequear actualización",
              onPressed: () async {
                await _checkVersionManual(context);
              },
            ),

            const SizedBox(height: 20),

            // // 🔓 Sección de Sesión
            // _buildSectionTitle("Sesión"),
            // _buildButton(
            //   context: context,
            //   icon: Icons.logout,
            //   text: "Cerrar sesión",
            //   onPressed: _logout,
            // ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Título de sección
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// 🔹 Botón con estilo elegante y tema dinámico
  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      icon: Icon(icon, size: 22),
      label: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      onPressed: onPressed,
    );
  }

  Future<void> _checkVersionManual(BuildContext context) async {
    await versionService.checkVersion();
    if (versionService.hasUpdateAvailable()) {
      final currentVersion = versionService.getCurrentVersion();
      final latestVersion = versionService.getLatestVersion();
      Get.dialog(
        AlertDialog(
          title: const Text('Actualización Disponible'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hay una nueva versión disponible: $latestVersion'),
              const SizedBox(height: 8),
              Text('Tu versión actual: $currentVersion'),
              const SizedBox(height: 16),
              const Text('Por favor, actualiza la aplicación para continuar.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                // Aquí podrías agregar la lógica para abrir la tienda de aplicaciones
              },
              child: const Text('Actualizar'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      Get.snackbar(
        'Versión actual',
        'Ya tienes la última versión instalada.',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _logout() async {
    Box<AppConfig> box;

    if (!Hive.isBoxOpen('appConfig')) {
      box = await Hive.openBox<AppConfig>('appConfig');
    } else {
      box = Hive.box<AppConfig>('appConfig');
    }

    AppConfig? currentConfig = box.get('config');

    if (currentConfig != null) {
      String imeiGuardado = currentConfig.imei;
      String tokenGuardado = currentConfig.token;

      AppConfig newConfig = currentConfig.copyWith(
        imei: imeiGuardado,
        token: tokenGuardado,
        codHabilitado: "",
        nombre: "",
        cedula: "",
        email: "",
        movil: "",
        idOrganizacion: "",
        categoria: "",
        habilitadoOperadora: "",
      );

      await box.put('config', newConfig);
      print("✅ Se ha cerrado sesión correctamente. IMEI y token siguen guardados.");
    }

    Get.offAllNamed('/login');
  }
}
