import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/controller/managebag_controller.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final EntregaController entregaController = Get.put(EntregaController());
    final ManageBagController bagController = Get.put(ManageBagController());

    // 🔹 Obtener la caja abierta (sin abrirla nuevamente)
    final box = Hive.box<AppConfig>('appConfig');

    // 🔹 Obtener la configuración guardada (sin necesidad de abrir la caja)
    final AppConfig? config = box.get('config');

    // 🔹 Si no hay datos, mostramos 'Usuario'
    final String nombreCompleto = config?.nombre ?? 'Usuario';

    // 🔹 Extraemos solo el primer nombre
    final String primerNombre = nombreCompleto.split(' ').first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      entregaController.refreshData();
      bagController.loadBagData();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, $primerNombre!'), // 🔹 Mostramos el nombre del usuario
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Configuraciones',
            onPressed: () {
              Get.toNamed('/configs');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          print("🔄 Actualizando datos...");
          await entregaController.refreshData();
          await bagController.loadBagData();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LineChart(LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: true),
                        spots: [
                          FlSpot(0, 1),
                          FlSpot(1, 3),
                          FlSpot(2, 10),
                          FlSpot(3, 7),
                          FlSpot(4, 12),
                          FlSpot(5, 13),
                        ],
                      ),
                    ],
                  )),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SummaryCard(title: 'Altas Registradas', count: 325),
                  SummaryCard(title: 'Bajas Registradas', count: 25),
                  SummaryCard(title: 'Movimientos Registrados', count: 12),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    Obx(() => ActionCard(
                          label:
                              'Gestionar Bolson (${bagController.cantidadDisponible})',
                          onTap: () {
                            Get.toNamed('/managebag');
                          },
                        )),
                    Obx(() => ActionCard(
                          label:
                              'Gestionar Pendientes (${entregaController.entregasPendientesCount})',
                          onTap: () {
                            Get.toNamed('/entrega');
                          },
                        )),
                    Obx(() => ActionCard(
                          label:
                              'Gestionar Listas (${entregaController.entregasListasCount})',
                          onTap: () {
                              Get.toNamed('/sendview');
                          },
                        )),
                    ActionCard(
                      label: 'Notificar Movimiento',
                      onTap: () {},
                    ),
                    ActionCard(label: 'Notificar Baja'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final int count;

  const SummaryCard({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 110,
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text('$count'),
          ],
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const ActionCard({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
