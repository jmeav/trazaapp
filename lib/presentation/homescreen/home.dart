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

    final box = Hive.box<AppConfig>('appConfig');
    final AppConfig? config = box.get('config');
    final String nombreCompleto = config?.nombre ?? 'Usuario';
    final String primerNombre = nombreCompleto.split(' ').first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      entregaController.refreshData();
      bagController.loadBagData();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, $primerNombre!'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
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
                        color: Colors.black,
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SummaryCard(
                    title: 'Altas Registradas',
                    count: 325,
                    icon: Icons.arrow_upward,
                  ),
                  SummaryCard(
                    title: 'Bajas Registradas',
                    count: 25,
                    icon: Icons.arrow_downward,
                  ),
                  SummaryCard(
                    title: 'Movimientos\n',
                    count: 12,
                    icon: Icons.swap_horiz,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    Obx(() => ActionCard(
                          label: 'Gestionar Aretes (${bagController.cantidadDisponible})',
                          onTap: () {
                            Get.toNamed('/managebag');
                          },
                          icon: Icons.assignment,
                        )),
                    ActionCard(
                      label: 'Verificar CUE',
                      onTap: () {
                        Get.toNamed('/verifycue');
                      },
                      icon: Icons.emergency_share_rounded,
                    ),
                    Obx(() => ActionCard(
                          label: 'Gestionar Entregas (${entregaController.entregasPendientesCount})',
                          onTap: () {
                            Get.toNamed('/entrega');
                          },
                          icon: Icons.local_shipping,
                        )),
                         ActionCard(
                      label: 'Reposición Aretes',
                      onTap: () {},
                      icon: Icons.change_circle_rounded,
                    ),
                    Obx(() => ActionCard(
                          label: 'Enviar Altas (${entregaController.entregasListasCount})',
                          onTap: () {
                            Get.toNamed('/sendview');
                          },
                          icon: Icons.send,
                        )),
                    ActionCard(
                      label: 'Consulta Bovino',
                      onTap: () {},
                      icon: Icons.search,
                    ),
                    ActionCard(
                      label: 'Bajas',
                      onTap: () {},
                      icon: Icons.thumb_down,
                    ),
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
  final IconData icon;

  const SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                // fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 14,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class ActionCard extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData icon;

  const ActionCard({
    required this.label,
    this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}