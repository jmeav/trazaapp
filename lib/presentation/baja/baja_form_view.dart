import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/baja_controller.dart';
import 'package:trazaapp/data/models/establecimiento/establecimiento.dart';
import 'package:trazaapp/data/models/productores/productor.dart';

class BajaFormView extends StatelessWidget {
  const BajaFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final BajaController controller = Get.find<BajaController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Baja Individual'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Arete field with scanner option
              Text('Arete', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.areteController,
                      decoration: const InputDecoration(
                        hintText: 'Ingrese el número de arete',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        controller.setAreteScanned(false);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () => _openScanner(context, controller),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => Chip(
                        label: Text(controller.isAreteScanned.value
                            ? 'Escaneado'
                            : 'Digitado'),
                        backgroundColor: controller.isAreteScanned.value
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.secondaryContainer,
                      )),
                ],
              ),
              const SizedBox(height: 16),

              // Motivo dropdown
              Text('Motivo de la baja', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedMotivo.value.isEmpty
                        ? null
                        : controller.selectedMotivo.value,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: controller.motivos.map((motivo) {
                      return DropdownMenuItem(
                        value: motivo,
                        child: Text(motivo),
                      );
                    }).toList(),
                    onChanged: (value) => controller.setMotivo(value ?? ''),
                  )),
              const SizedBox(height: 16),

              // CUE field with autocomplete
              Text('CUE', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Autocomplete<Establecimiento>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  return await controller
                      .buscarEstablecimientos(textEditingValue.text);
                },
                displayStringForOption: (Establecimiento option) =>
                    '${option.nombreEstablecimiento} (${option.establecimiento})',
                onSelected: (Establecimiento selection) {
                  controller.cueController.text = selection.establecimiento;
                },
                fieldViewBuilder:
                    (context, textController, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: textController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Buscar Establecimiento',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // CUPA field with autocomplete
              Text('CUPA', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Autocomplete<Productor>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  return await controller
                      .buscarProductores(textEditingValue.text);
                },
                displayStringForOption: (Productor option) =>
                    '${option.nombreProductor} (${option.productor})',
                onSelected: (Productor selection) {
                  controller.cupaController.text = selection.productor;
                },
                fieldViewBuilder:
                    (context, textController, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: textController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Buscar Productor',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Fecha de baja
              Text('Fecha de la baja', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: controller.fechaBajaController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: controller.fechaBaja.value,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    controller.setFechaBaja(date);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Evidencia
              Text('Evidencia', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Obx(() {
                final hasFile = controller.evidenciaFileName.value.isNotEmpty;
                final isPdf = controller.tipoEvidencia.value == 'pdf';
                
                return ElevatedButton.icon(
                  onPressed: controller.loadEvidencia,
                  icon: Icon(
                    hasFile
                        ? (isPdf ? Icons.picture_as_pdf : Icons.image)
                        : Icons.attach_file,
                    color: hasFile
                        ? theme.colorScheme.onSecondary
                        : theme.colorScheme.onPrimary,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasFile
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  label: Text(
                    hasFile
                        ? (isPdf
                            ? 'PDF: ${controller.pdfFileName.value}'
                            : 'Imagen: ${controller.evidenciaFileName.value}')
                        : 'Adjuntar archivo',
                    style: TextStyle(
                      color: hasFile
                          ? theme.colorScheme.onSecondary
                          : theme.colorScheme.onPrimary,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.saveBaja,
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openScanner(BuildContext context, BajaController controller) async {
    try {
      // Importamos de forma dinámica para asegurar una nueva instancia cada vez
      const scannerRoute = '/scanner';
      
      final result = await Navigator.of(context).pushNamed(scannerRoute);
      
      if (result != null && result is String) {
        controller.areteController.text = result;
        controller.setAreteScanned(true);
        Get.snackbar(
          'Éxito',
          'Arete escaneado correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error al escanear: $e');
      Get.snackbar(
        'Error',
        'Error al escanear el código: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
