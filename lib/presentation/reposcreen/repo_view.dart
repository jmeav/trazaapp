import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/data/models/repo/repoentrega.dart';
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

        final reposiciones = controller.reposicionesPendientes;

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
                        final repo = reposiciones[index];
                        return _buildReposicionCard(repo);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildReposicionCard(RepoEntrega repo) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con ID y fecha
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Reposición #${repo.idRepo}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _mostrarDetallesReposicion(repo),
                  tooltip: 'Ver detalles',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repo.departamento,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'CUE: ${repo.cue}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(Get.context!).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repo.cupa,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Org: ${repo.idorganizacion}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(Get.context!).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(Get.context!).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${repo.cantidad} aretes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatFecha(repo.fechaRepo),
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(Get.context!).textTheme.bodySmall?.color,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.assignment_turned_in, size: 18),
                  label: const Text('Enviar'),
                  onPressed: () async {
                    // Aquí puedes poner la lógica para enviar la reposición
                    // o navegar a un detalle si es necesario
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size(100, 36),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetallesReposicion(RepoEntrega repo) {
    Get.dialog(
      AlertDialog(
        title: Text('Detalles de Reposición'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', repo.idRepo),
              _buildDetailRow('Fecha', formatFecha(repo.fechaRepo)),
              _buildDetailRow('Estado', repo.estadoRepo),
              _buildDetailRow('Departamento', repo.departamento),
              _buildDetailRow('Municipio', repo.municipio),
              _buildDetailRow('CUE', repo.cue),
              _buildDetailRow('CUPA', repo.cupa),
              _buildDetailRow('Cantidad', '${repo.cantidad} aretes'),
              _buildDetailRow('Rango', '${repo.rangoInicialRepo} - ${repo.rangoFinalRepo}'),
              if (repo.distanciaCalculada != null)
                _buildDetailRow('Distancia', repo.distanciaCalculada!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 