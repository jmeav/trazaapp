import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/formbovinos_controller.dart';
import 'package:trazaapp/controller/formrepo_controller.dart';
import 'package:trazaapp/data/models/razas/raza.dart';
import 'package:trazaapp/data/models/repo/bovinorepo.dart';
import 'package:trazaapp/presentation/widgets/custom_button.dart';
import 'package:trazaapp/presentation/widgets/custom_dropdown.dart';
import 'package:trazaapp/presentation/widgets/custom_textfield.dart';
import 'package:trazaapp/presentation/widgets/loading_widget.dart';
import 'package:trazaapp/utils/utils.dart';

class FormRepoView extends GetView<FormRepoController> {
final FormRepoController controller = Get.put(FormRepoController());
  

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('¿Estás seguro?'),
            content: const Text(
              'Si sales ahora, perderás los cambios no guardados.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Salir'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Formulario de Reposición'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                // TODO: Implementar guardado
              },
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingWidget();
          }

          if (controller.bovinosRepo.isEmpty) {
            return const Center(
              child: Text('No hay bovinos para mostrar'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: (index) => controller.currentPage.value = index,
                  itemCount: controller.bovinosRepo.length,
                  itemBuilder: (context, index) {
                    final bovino = controller.bovinosRepo[index];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bovino ${index + 1} de ${controller.bovinosRepo.length}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: 'Arete Anterior',
                                  initialValue: bovino.areteAnterior,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(13),
                                  ],
                                  onChanged: (value) => controller.updateAreteAnterior(
                                    index,
                                    value,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.qr_code_scanner),
                                onPressed: () async {
                                  try {
                                    final barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                                      '#ff6666',
                                      'Cancelar',
                                      true,
                                      ScanMode.BARCODE,
                                    );
                                    if (barcodeScanRes != '-1') {
                                      controller.updateAreteAnterior(
                                        index,
                                        barcodeScanRes,
                                      );
                                    }
                                  } catch (e) {
                                    Get.snackbar(
                                      'Error',
                                      'No se pudo escanear el código',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Arete Nuevo: ${bovino.arete}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: 'Edad (meses)',
                                  initialValue: bovino.edad.toString(),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) => controller.updateEdad(
                                    index,
                                    int.tryParse(value) ?? 0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomDropdown<String>(
                                  label: 'Sexo',
                                  value: bovino.sexo,
                                  items: const ['M', 'H'],
                                  onChanged: (value) {
                                    if (value != null) {
                                      controller.updateSexo(index, value);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomDropdown<String>(
                            label: 'Raza',
                            value: bovino.raza,
                            items: controller.razas
                                .map((raza) => raza.nombre)
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.updateRaza(index, value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomDropdown<String>(
                            label: 'Estado del Arete',
                            value: bovino.estadoArete,
                            items: const ['Bueno', 'Dañado'],
                            onChanged: (value) {
                              if (value != null) {
                                controller.updateEstadoArete(index, value);
                              }
                            },
                          ),
                          if (bovino.estadoArete == 'Dañado') ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: 'Tomar Foto del Arete',
                                    icon: Icons.camera_alt,
                                    onPressed: () => controller.tomarFotoArete(index),
                                  ),
                                ),
                                if (bovino.fotoArete.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.remove_red_eye),
                                    onPressed: () {
                                      Get.dialog(
                                        Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.memory(
                                                Utils.base64ToImage(bovino.fotoArete),
                                              ),
                                              TextButton(
                                                onPressed: () => Get.back(),
                                                child: const Text('Cerrar'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          ExpansionTile(
                            title: const Text('Datos Adicionales'),
                            children: [
                              CustomTextField(
                                label: 'Arete de la Madre',
                                initialValue: bovino.areteMadre,
                                onChanged: (value) => controller.updateAreteMadre(
                                  index,
                                  value,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                label: 'Registro de la Madre',
                                initialValue: bovino.regMadre,
                                onChanged: (value) => controller.updateRegMadre(
                                  index,
                                  value,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                label: 'Arete del Padre',
                                initialValue: bovino.aretePadre,
                                onChanged: (value) => controller.updateAretePadre(
                                  index,
                                  value,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                label: 'Registro del Padre',
                                initialValue: bovino.regPadre,
                                onChanged: (value) => controller.updateRegPadre(
                                  index,
                                  value,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: controller.currentPage.value > 0
                          ? controller.previousPage
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Anterior'),
                    ),
                    TextButton.icon(
                      onPressed: controller.currentPage.value <
                              controller.bovinosRepo.length - 1
                          ? controller.nextPage
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Siguiente'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.dialog(
              AlertDialog(
                title: const Text('Llenado Rápido'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      label: 'Edad (meses)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        // TODO: Implementar llenado rápido
                      },
                    ),
                    const SizedBox(height: 8),
                    CustomDropdown<String>(
                      label: 'Sexo',
                      items: const ['M', 'H'],
                      onChanged: (value) {
                        // TODO: Implementar llenado rápido
                      },
                    ),
                    const SizedBox(height: 8),
                    CustomDropdown<String>(
                      label: 'Raza',
                      items: controller.razas
                          .map((raza) => raza.nombre)
                          .toList(),
                      onChanged: (value) {
                        // TODO: Implementar llenado rápido
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implementar llenado rápido
                      Get.back();
                    },
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            );
          },
          child: const Icon(Icons.flash_on),
        ),
      ),
    );
  }
} 