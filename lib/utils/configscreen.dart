import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/theme/theme_controller.dart';

class ConfiguracionesScreen extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuraciones"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(() {
              return ListTile(
                leading: Icon(themeController.themeData.value.brightness == Brightness.light
                    ? Icons.brightness_3
                    : Icons.wb_sunny),
                title: Text("Modo Oscuro"),
                trailing: Switch(
                  value: themeController.themeData.value.brightness == Brightness.dark,
                  onChanged: (value) {
                    themeController.toggleTheme(context);
                  },
                ),
              );
            }),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/catalogs'); // Puedes navegar a más configuraciones
              },
              child: Text("Administrar Catálogos"),
            ),
          ],
        ),
      ),
    );
  }
}
