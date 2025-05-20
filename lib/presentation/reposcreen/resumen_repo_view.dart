import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trazaapp/data/local/models/reposicion/repoentrega.dart';
import 'package:trazaapp/data/local/models/reposicion/bovinorepo.dart';
import 'package:trazaapp/data/local/models/razas/raza.dart'; // Importar Raza para obtener nombre
import 'package:hive/hive.dart'; // Importar Hive para buscar razas
import 'package:trazaapp/utils/utils.dart'; // Para mostrar imágenes base64
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/presentation/widgets/edit_bovino_dialog.dart';

class ResumenRepoView extends StatelessWidget {
  final RepoEntrega repo;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final EntregaController _entregaController = Get.find<EntregaController>();

  ResumenRepoView({required this.repo, Key? key}) : super(key: key);

  // Función para obtener el nombre de la raza
  String _getNombreRaza(String razaId) {
    final razasBox = Hive.box<Raza>('razas');
    final raza = razasBox.get(razaId);
    return raza?.nombre ?? 'ID: $razaId'; // Devuelve nombre o ID si no se encuentra
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen Reposición: ${repo.idRepo.substring(0, 5)}...'), // Mostrar ID corto
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información General', style: theme.textTheme.headlineSmall),
            const Divider(),
            _buildDetailRow(theme, 'ID Reposición', repo.idRepo),
            _buildDetailRow(theme, 'ID Entrega Origen', repo.entregaIdOrigen),
            _buildDetailRow(theme, 'Fecha Reposición', _dateFormat.format(repo.fechaRepo)),
            _buildDetailRow(theme, 'CUE', repo.cue),
            _buildDetailRow(theme, 'CUPA', repo.cupa),
            _buildDetailRow(theme, 'Departamento', repo.departamento),
            _buildDetailRow(theme, 'Municipio', repo.municipio),
            _buildDetailRow(theme, 'Observaciones', repo.observaciones.isNotEmpty ? repo.observaciones : '(Ninguna)'),
            _buildDetailRow(theme, 'Estado Actual', repo.estadoRepo),
            const SizedBox(height: 10),
            _buildImageRow(theme, 'Foto Inicial', repo.fotoBovInicial),
            _buildImageRow(theme, 'Foto Final', repo.fotoBovFinal),
            _buildPdfRow(theme, 'Ficha/Evidencia PDF', repo.fotoFicha), // Usando fotoFicha como evidencia
            
            const SizedBox(height: 20),
            Text('Detalle Bovinos (${repo.detalleBovinos.length})', style: theme.textTheme.headlineSmall),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: repo.detalleBovinos.length,
              itemBuilder: (context, index) {
                final bovino = repo.detalleBovinos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bovino ${index + 1}: Arete Nuevo ${bovino.arete}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        _buildDetailRow(theme, 'Arete Anterior', bovino.areteAnterior),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailRow(theme, 'Edad', '${bovino.edad} meses'),
                            ),
                            Expanded(
                              child: _buildDetailRow(theme, 'Sexo', bovino.sexo),
                            ),
                            // Botón de edición
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _mostrarDialogoEdicion(context, bovino),
                              tooltip: 'Editar edad y sexo',
                            ),
                          ],
                        ),
                        _buildDetailRow(theme, 'Raza', _getNombreRaza(bovino.razaId)),
                        _buildDetailRow(theme, 'Traza', bovino.traza),
                        _buildDetailRow(theme, 'Estado Arete', bovino.estadoArete),
                         if (bovino.traza == 'PURO') ...[
                           _buildDetailRow(theme, 'Arete Madre', bovino.areteMadre),
                           _buildDetailRow(theme, 'Arete Padre', bovino.aretePadre),
                           _buildDetailRow(theme, 'Reg. Madre', bovino.regMadre),
                           _buildDetailRow(theme, 'Reg. Padre', bovino.regPadre),
                         ],
                         _buildImageRow(theme, 'Foto Arete Dañado', bovino.fotoArete),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Ancho fijo para la etiqueta
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildImageRow(ThemeData theme, String label, String base64Image) {
     if (base64Image.isEmpty) return const SizedBox.shrink(); // No mostrar si no hay imagen
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 5.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
           const SizedBox(height: 5),
           GestureDetector(
             onTap: () => _showImageDialog(Get.context!, base64Image),
             child: Image.memory(
               Utils.base64ToImage(base64Image),
               height: 100, // Altura de la miniatura
               fit: BoxFit.cover,
             ),
           ),
         ],
       ),
     );
  }
  
   Widget _buildPdfRow(ThemeData theme, String label, String base64Pdf) {
     if (base64Pdf.isEmpty) return _buildDetailRow(theme, label, '(No adjunto)');
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 3.0),
       child: Row(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           SizedBox(
             width: 120,
             child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
           ),
           Expanded(
             child: Row(
               children: [
                 Icon(Icons.picture_as_pdf, color: Colors.red[700]),
                 const SizedBox(width: 5),
                 const Text('Adjunto'),
                 // Podrías añadir un botón para intentar abrirlo si tuvieras la funcionalidad
               ],
             ),
           ),
         ],
       ),
     );
   }

  void _showImageDialog(BuildContext context, String base64Image) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
              Image.memory(Utils.base64ToImage(base64Image)),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'))
           ]
        ),
      ),
    );
  }

  // Método para mostrar el diálogo de edición
  void _mostrarDialogoEdicion(BuildContext context, BovinoRepo bovino) {
    showDialog(
      context: context,
      builder: (context) => EditBovinoDialog(
        arete: bovino.arete,
        sexo: bovino.sexo,
        edad: bovino.edad,
        onSave: (sexo, edad) {
          _entregaController.actualizarBovinoRepo(repo.idRepo, bovino.arete, sexo, edad).then((_) {
            // Recargar la página para mostrar los cambios
            Get.off(() => ResumenRepoView(repo: repo));
          });
        },
      ),
    );
  }
} 