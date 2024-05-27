import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:trazaapp/entregas/controller/entrega_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final EntregaController entregaController = Get.put(EntregaController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Configuración de temas',
            onPressed: () {
              Get.toNamed('/customize_theme');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Gráfico
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
            // Resumen
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SummaryCard(title: 'Altas Registradas', count: 325),
                SummaryCard(title: 'Bajas Registradas', count: 25),
                SummaryCard(title: 'Movimientos Registrados', count: 12),
              ],
            ),
            SizedBox(height: 16),
            // Botones de acción
            Expanded(
              child: ListView(
                children: [
                  Obx(() => ActionCard(
                        label: 'Entregas Pendientes (${entregaController.entregasPendientesCount})',
                        onTap: () {
                          Get.toNamed('/entrega');
                        },
                      )),
                  ActionCard(label: 'Altas Enviadas (3)'),
                  ActionCard(label: 'Actualizaciones (1)'),
                  ActionCard(label: 'Notificaciones de bajas (3)'),
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
