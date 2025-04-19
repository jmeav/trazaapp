import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/presentation/widgets/custom_button.dart';
import 'package:trazaapp/presentation/widgets/loading_widget.dart';
import 'package:trazaapp/utils/utils.dart';
import 'package:intl/intl.dart';

class RepoView extends GetView<EntregaController> {
  const RepoView({Key? key}) : super(key: key);

  String formatFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Reposiciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshData(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        final reposiciones = controller.entregasConReposicionPendiente;

        return Column(
          children: [
            Expanded(
              child: reposiciones.isEmpty
                  ? const Center(
                      child: Text('No hay reposiciones pendientes'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: reposiciones.length,
                      itemBuilder: (context, index) {
                        final entrega = reposiciones[index];
                        return _buildReposicionCard(entrega);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildReposicionCard(Entregas entrega) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reposición #${entrega.entregaId}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '📅 ${formatFecha(entrega.fechaEntrega)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('📍 ${entrega.departamento}, ${entrega.municipio}'),
            Text('🏢 ${entrega.nombreEstablecimiento}'),
            Text('👨‍🌾 ${entrega.nombreProductor}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('📦 Cantidad: ${entrega.cantidad}'),
                Text('🔢 Rango: ${entrega.rangoInicial} - ${entrega.rangoFinal}'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: () {
                  Get.toNamed('/formrepo', arguments: {
                    'entregaId': entrega.entregaId,
                    'rangoInicial': entrega.rangoInicial,
                    'rangoFinal': entrega.rangoFinal,
                    'cantidad': entrega.cantidad,
                  });
                },
                text: 'Realizar Reposición',
                icon: Icons.refresh,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 