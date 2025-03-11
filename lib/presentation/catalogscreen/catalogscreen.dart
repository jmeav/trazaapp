import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';

class CatalogosScreen extends StatelessWidget {
  final CatalogosController controller = Get.put(CatalogosController());


    String _formatDateTime(String dateTimeString) {
  try {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  } catch (e) {
    return "Fecha inválida";
  }
}

  @override
  Widget build(BuildContext context) {

    var box = Hive.box<AppConfig>('appConfig');
    var config = box.get('config');

    return Scaffold(
      appBar: AppBar(
        title: Text("Catálogos"),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () {
              if (config != null) {
                controller.downloadAllCatalogs(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          List<Widget> catalogCards = [];

          if (controller.habilitadoOperadora.value == "1") {
            catalogCards.addAll([
              _buildCatalogCard(
                title: "Departamentos",
                icon: Icons.map,
                isDownloaded: controller.departamentos.isNotEmpty,
                lastUpdated: controller.lastUpdateDepartamentos.value,
                onTap: () {
                  if (config != null) {
                    controller.downloadDepartamentos(
                      token: config.token,
                      codhabilitado: config.codHabilitado,
                    );
                  }
                },
                isLoading: controller.isDownloading.value &&
                    controller.progressText.value.contains('Departamentos'),
              ),
              _buildCatalogCard(
                title: "Municipios",
                icon: Icons.location_city,
                isDownloaded: controller.municipios.isNotEmpty,
                lastUpdated: controller.lastUpdateMunicipios.value,
                onTap: () {
                  if (config != null) {
                    controller.downloadMunicipios(
                      token: config.token,
                      codhabilitado: config.codHabilitado,
                    );
                  }
                },
                isLoading: controller.isDownloading.value &&
                    controller.progressText.value.contains('Municipios'),
              ),
              _buildCatalogCard(
                title: "Establecimientos",
                icon: Icons.store,
                isDownloaded: controller.establecimientos.isNotEmpty,
                lastUpdated: controller.lastUpdateEstablecimientos.value,
                onTap: () {
                  if (config != null) {
                    controller.downloadEstablecimientos(
                      token: config.token,
                      codhabilitado: config.codHabilitado,
                    );
                  }
                },
                isLoading: controller.isDownloading.value &&
                    controller.progressText.value.contains('Establecimientos'),
              ),
              _buildCatalogCard(
                title: "Productores",
                icon: Icons.person,
                isDownloaded: controller.productores.isNotEmpty,
                lastUpdated: controller.lastUpdateProductores.value,
                onTap: () {
                  if (config != null) {
                    controller.downloadProductores(
                      token: config.token,
                      codhabilitado: config.codHabilitado,
                    );
                  }
                },
                isLoading: controller.isDownloading.value &&
                    controller.progressText.value.contains('Productores'),
              ),
              _buildCatalogCard(
                title: "Bag",
                icon: Icons.shopping_bag,
                isDownloaded: controller.bag.value != null,
                lastUpdated: controller.lastUpdateBag.value,
                onTap: () {
                  if (config != null) {
                    controller.downloadBag(
                      token: config.token,
                      codhabilitado: config.codHabilitado,
                    );
                  }
                },
                isLoading: controller.isDownloading.value &&
                    controller.progressText.value.contains('Bag'),
              ),
            ]);
          }

          // 🔹 Catálogo de "Entregas" (disponible para todos los usuarios)
          catalogCards.add(
            _buildCatalogCard(
              title: "Entregas",
              icon: Icons.local_shipping,
              isDownloaded: controller.entregas.isNotEmpty,
              lastUpdated: controller.lastUpdateEntregas.value,
              onTap: () {
                if (config != null) {
                  controller.downloadEntregas(
                    token: config.token,
                    codhabilitado: config.codHabilitado,
                  );
                }
              },
              isLoading: controller.isDownloading.value &&
                  controller.progressText.value.contains('Entregas'),
            ),
          );

          // 🔹 Nuevo catálogo de "Razas" (disponible para todos los usuarios)
          catalogCards.add(
            _buildCatalogCard(
              title: "Razas",
              icon: Icons.pets,
              isDownloaded: controller.razas.isNotEmpty,
              lastUpdated: controller.lastUpdateRazas.value,
              onTap: () {
                if (config != null) {
                  controller.downloadRazas(
                    token: config.token,
                    codhabilitado: config.codHabilitado,
                  );
                }
              },
              isLoading: controller.isDownloading.value &&
                  controller.progressText.value.contains('Razas'),
            ),
          );

          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: catalogCards,
          );
        }),
      ),
    );
  }

  /// Widget de tarjeta de catálogo
  Widget _buildCatalogCard({
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
  lastUpdated.isEmpty
      ? 'Sin actualizar'
      : 'Última actualización: ${_formatDateTime(lastUpdated)}',
  style: TextStyle(fontSize: 12, color: Colors.white70),
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
