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
        title: const Text('Registro de Bajas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cantidad de bajas
              Text('Cantidad de bajas', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: controller.cantidadController,
                decoration: const InputDecoration(
                  hintText: 'Ingrese la cantidad de bajas',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  int? cantidad = int.tryParse(value);
                  if (cantidad != null && cantidad > 0) {
                    controller.setCantidadBajas(cantidad);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Sección de detalles de aretes
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Arete ${controller.currentAreteIndex.value + 1} de ${controller.cantidadBajas.value}',
                            style: theme.textTheme.titleMedium,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios),
                                onPressed: controller.currentAreteIndex.value > 0
                                    ? controller.anteriorArete
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed: controller.currentAreteIndex.value <
                                        controller.cantidadBajas.value - 1
                                    ? controller.siguienteArete
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Arete field with scanner option
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
                          Chip(
                            label: Text(controller.isAreteScanned.value
                                ? 'Escaneado'
                                : 'Digitado'),
                            backgroundColor: controller.isAreteScanned.value
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.secondaryContainer,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Motivo dropdown
                      Text('Motivo de la baja',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
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
                      ),
                      const SizedBox(height: 16),

                      // Botón para guardar este arete
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.guardarAreteActual,
                          child: const Text('Guardar Arete'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Mostrar lista de aretes guardados
                      if (controller.detalleAretes.isNotEmpty) ...[
                        Text('Aretes registrados',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.detalleAretes.length,
                            itemBuilder: (context, index) {
                              final arete = controller.detalleAretes[index];
                              return ListTile(
                                title: Text('Arete: ${arete.arete}'),
                                subtitle: Text('Motivo: ${arete.motivoBaja}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    controller.currentAreteIndex.value = index;
                                    controller.cargarAreteActual();
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  )),

              const Divider(),
              Text('Información General', style: theme.textTheme.titleLarge),
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
                child: Obx(() => ElevatedButton(
                      onPressed: controller.detalleAretes.length ==
                              controller.cantidadBajas.value
                          ? controller.saveBaja
                          : null,
                      child: Text(
                          'Guardar Baja (${controller.detalleAretes.length}/${controller.cantidadBajas.value})'),
                    )),
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
