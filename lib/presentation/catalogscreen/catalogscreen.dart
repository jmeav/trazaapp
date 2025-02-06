import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/login/controller/login_controller.dart';

class CatalogosScreen extends StatelessWidget {
  final CatalogosController controller = Get.put(CatalogosController());
  final LoginController loginController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Catálogos"),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () {
              controller.downloadAllCatalogs(
                token: loginController.token.value,
                codhabilitado: loginController.codigoOficial.value,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildCatalogCard(
                context,
                title: 'Departamentos',
                icon: Icons.map,
                isDownloaded: controller.departamentos.isNotEmpty,
                lastUpdated: controller.progressText.value.contains('Departamentos')
                    ? 'Descargando...'
                    : controller.departamentos.isNotEmpty
                        ? 'Actualizado: ${controller.departamentos.first.lastUpdate}'
                        : 'Sin actualizar',
                onTap: () => controller.downloadDepartamentos(
                  token: loginController.token.value,
                  codhabilitado: loginController.codigoOficial.value,
                ),
                isLoading: controller.isDownloading.value && controller.progressText.value.contains('Departamentos'),
              ),
              _buildCatalogCard(
                context,
                title: 'Municipios',
                icon: Icons.location_city,
                isDownloaded: controller.municipios.isNotEmpty,
                lastUpdated: controller.progressText.value.contains('Municipios')
                    ? 'Descargando...'
                    : controller.municipios.isNotEmpty
                        ? 'Actualizado: ${controller.municipios.first.lastUpdate}'
                        : 'Sin actualizar',
                onTap: () => controller.downloadMunicipios(
                  token: loginController.token.value,
                  codhabilitado: loginController.codigoOficial.value,
                ),
                isLoading: controller.isDownloading.value && controller.progressText.value.contains('Municipios'),
              ),
              _buildCatalogCard(
                context,
                title: 'Establecimientos',
                icon: Icons.business,
                isDownloaded: controller.establecimientos.isNotEmpty,
                lastUpdated: controller.progressText.value.contains('Establecimientos')
                    ? 'Descargando...'
                    : controller.establecimientos.isNotEmpty
                        ? 'Actualizado: ${controller.establecimientos.first.lastUpdate}'
                        : 'Sin actualizar',
                onTap: () => controller.downloadEstablecimientos(
                  token: loginController.token.value,
                  codhabilitado: loginController.codigoOficial.value,
                ),
                isLoading: controller.isDownloading.value && controller.progressText.value.contains('Establecimientos'),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCatalogCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isDownloaded,
    required String lastUpdated,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Card(
        color: isDownloaded ? Colors.green[300] : Colors.grey[400],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Text(
                lastUpdated,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white30,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
