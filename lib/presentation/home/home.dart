import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/presentation/entlistas/entenviar_view.dart';
import 'package:trazaapp/theme/theme_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    String rol = 'HB Operadora';
    int asignados = 50;
    final EntregaController entregaController = Get.put(EntregaController());
    final ThemeController themeController = Get.put(ThemeController());
     WidgetsBinding.instance.addPostFrameCallback((_) {
      entregaController.refreshData(); // Actualiza datos al mostrar la vista
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, $rol!'),
        elevation: 0,
        actions: [
          Obx(() {
            return IconButton(
              icon: Icon(
                  themeController.themeData.value.brightness == Brightness.light
                      ? Icons.brightness_3
                      : Icons.wb_sunny),
              tooltip: 'Cambiar tema',
              onPressed: () {
                themeController.toggleTheme(context);
              },
            );
          }),
        ],
      ),
      body: Padding(
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
                    ActionCard(label: 'Gestionar Bolson (500)'),
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
                      Get.to(() => EnviarView());
                    },
                  )),
                  ActionCard(label: 'Notificar Movimiento'),
                  ActionCard(label: 'Notificar Baja'),
                ],
              ),
            ),
          ],
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
