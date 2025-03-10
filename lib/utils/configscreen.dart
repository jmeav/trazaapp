import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trazaapp/theme/theme_controller.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';

class ConfiguracionesScreen extends StatelessWidget {
  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
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
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text(
                    "Modo Oscuro",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
              icon: Icons.folder_open,
              text: "Administrar Catálogos",
              color: Colors.blueAccent,
              onPressed: () => Get.toNamed('/catalogs'),
            ),

            const SizedBox(height: 20),

            // 🔓 Sección de Sesión
            _buildSectionTitle("Sesión"),
            _buildButton(
              icon: Icons.logout,
              text: "Cerrar sesión",
              color: Colors.red,
              onPressed: _logout,
            ),
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

  /// 🔹 Botón con estilo elegante
  Widget _buildButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
      ),
      icon: Icon(icon, size: 22),
      label: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onPressed: onPressed,
    );
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
      String imeiGuardado = currentConfig.imei; // 🔹 Guardamos el IMEI antes de borrar
      String tokenGuardado = currentConfig.token; // 🔹 Guardamos el token antes de borrar

      AppConfig newConfig = currentConfig.copyWith(
        imei: imeiGuardado, // ✅ Mantenemos el IMEI
        token: tokenGuardado, // ✅ Mantenemos el Token
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