import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/baja_controller.dart';
import 'package:trazaapp/data/models/establecimiento/establecimiento.dart';
import 'package:trazaapp/data/models/productores/productor.dart';
import 'package:trazaapp/controller/arete_input_controller.dart';

class BajaFormView extends StatelessWidget {
  const BajaFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final BajaController controller = Get.find<BajaController>();
    final AreteInputController areteInput = Get.put(AreteInputController(), tag: 'areteInput');
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        // Si hay datos ingresados, mostrar advertencia
        final hayDatos = controller.detalleAretes.isNotEmpty ||
            areteInput.areteController.text.isNotEmpty ||
            controller.cueController.text.isNotEmpty ||
            controller.cupaController.text.isNotEmpty;
        if (hayDatos) {
          final result = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('¿Estás seguro?'),
              content: const Text(
                '¿Deseas salir del formulario? Los datos no guardados se perderán.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    controller.clearForm();
                    areteInput.clear();
                    Get.back(result: true);
                  },
                  child: const Text('Salir'),
                ),
              ],
            ),
          );
          return result ?? false;
        }
        controller.clearForm();
        areteInput.clear();
        return true;
      },
      child: Scaffold(
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
                                controller: areteInput.areteController,
                                decoration: const InputDecoration(
                                  hintText: 'Ingrese el número de arete',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  areteInput.isScanned.value = false;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.qr_code_scanner),
                              onPressed: () => areteInput.escanearArete(),
                            ),
                            const SizedBox(width: 8),
                            Obx(() => Chip(
                              label: Text(areteInput.isScanned.value ? 'Escaneado' : 'Digitado'),
                              backgroundColor: areteInput.isScanned.value
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.secondaryContainer,
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Motivo dropdown
                        Text('Motivo de la baja',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Obx(() {
                           final hayMotivos = controller.motivos.isNotEmpty;
                           
                           // Si no hay motivos, mostrar un mensaje o un indicador
                           if (!hayMotivos) {
                             return const Padding(
                               padding: EdgeInsets.symmetric(vertical: 8.0),
                               child: Row(
                                 children: [
                                   SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
                                   SizedBox(width: 10),
                                   Text('Cargando motivos...', 
                                 style: TextStyle(color: Colors.grey)),
                                 ],
                               )
                             );
                           }
                           
                           // Determinar el valor a mostrar en el dropdown
                           // Debe ser un ID válido que exista en la lista de motivos
                           int? valorSeleccionado = controller.selectedMotivoId.value;
                           final idSeleccionadoExiste = controller.motivos.any((m) => m.id == valorSeleccionado);
                           
                           // Si el ID seleccionado no es válido (0 o no existe), y hay motivos, 
                           // selecciona el primer motivo válido como valor por defecto para el dropdown.
                           // PERO NO actualices el controller aquí directamente para evitar bucles.
                           // La actualización del controller se hace en onChanged o al cargar el arete.
                           if (valorSeleccionado == 0 || !idSeleccionadoExiste) {
                              valorSeleccionado = controller.motivos.first.id; 
                              // Opcionalmente, podrías poner un `hintText` si prefieres que no haya selección inicial
                              // valorSeleccionado = null;
                           }
                           
                           return DropdownButtonFormField<int>(
                             value: valorSeleccionado, // Usar el ID int
                             isExpanded: true, // Para que ocupe el ancho disponible
                             decoration: const InputDecoration(
                               border: OutlineInputBorder(),
                               hintText: 'Seleccione un motivo',
                             ),
                             // Filtrar motivos con ID 0 o nombre vacío si es necesario
                             items: controller.motivos
                                 // .where((m) => m.id != 0 && m.nombre.isNotEmpty) // Descomentar si quieres filtrar inválidos
                                 .map((motivo) {
                               return DropdownMenuItem<int>(
                                 value: motivo.id,
                                 // Mostrar solo el nombre en el dropdown
                                 child: Text(motivo.nombre, overflow: TextOverflow.ellipsis),
                               );
                             }).toList(),
                             onChanged: (value) {
                               if (value != null) {
                                 // Encuentra el motivo completo por su ID y actualiza el controller
                                 final motivo = controller.motivos.firstWhere((m) => m.id == value);
                                 controller.setMotivo(value, motivo.nombre);
                               }
                             },
                              validator: (value) { // Añadir validación si es necesario
                                if (value == null || value == 0) {
                                  return 'Debe seleccionar un motivo';
                                }
                                return null;
                             },
                           );
                         }),
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
                                // Convertir motivoId (String) a int para buscar el nombre
                                final motivoIdInt = int.tryParse(arete.motivoId) ?? 0;
                                // Buscar nombre del motivo
                                final motivoNombre = controller.motivos.firstWhereOrNull((m) => m.id == motivoIdInt)?.nombre ?? 'ID: ${arete.motivoId}';
                                
                                return ListTile(
                                  title: Text('Arete: ${arete.arete}'),
                                  subtitle: Text('Motivo: $motivoNombre'), // Mostrar nombre encontrado
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
      ),
    );
  }
}
