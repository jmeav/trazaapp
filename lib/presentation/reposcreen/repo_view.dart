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
                    'Reposición #${entrega.entregaId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Agregar icono de información
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _mostrarDetallesReposicion(entrega),
                  tooltip: 'Ver detalles',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            const Divider(height: 16),
            
            // Información principal en formato horizontal
            Row(
              children: [
                // Columna izquierda: Establecimiento y CUE
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entrega.nombreEstablecimiento,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'CUE: ${entrega.cue}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(Get.context!).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Columna derecha: Productor y CUPA
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entrega.nombreProductor,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'CUPA: ${entrega.cupa}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(Get.context!).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Columna cantidad de aretes
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
                          '${entrega.cantidad} aretes',
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
            
            // Fecha y botón
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatFecha(entrega.fechaEntrega),
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(Get.context!).textTheme.bodySmall?.color,
                  ),
                ),
                
                ElevatedButton.icon(
                  icon: const Icon(Icons.assignment_turned_in, size: 18),
                  label: const Text('Realizar'),
                  onPressed: () => Get.toNamed('/formrepo', arguments: {
                    'entregaId': entrega.entregaId.split('_').first,
                    'repoId': entrega.entregaId,
                    'rangoInicial': entrega.rangoInicial,
                    'cantidad': entrega.cantidad,
                  }),
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

  // Método para mostrar detalles de la reposición
  void _mostrarDetallesReposicion(Entregas entrega) {
    Get.dialog(
      AlertDialog(
        title: Text('Detalles de Reposición'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', entrega.entregaId),
              _buildDetailRow('Fecha', formatFecha(entrega.fechaEntrega)),
              _buildDetailRow('Estado', entrega.estadoReposicion),
              _buildDetailRow('Departamento', entrega.departamento),
              _buildDetailRow('Municipio', entrega.municipio),
              _buildDetailRow('Establecimiento', entrega.nombreEstablecimiento),
              _buildDetailRow('CUE', entrega.cue),
              _buildDetailRow('Productor', entrega.nombreProductor),
              _buildDetailRow('CUPA', entrega.cupa),
              _buildDetailRow('Cantidad', '${entrega.cantidad} aretes'),
              _buildDetailRow('Rango', '${entrega.rangoInicial} - ${entrega.rangoFinal}'),
              if (entrega.distanciaCalculada != null)
                _buildDetailRow('Distancia', entrega.distanciaCalculada!),
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