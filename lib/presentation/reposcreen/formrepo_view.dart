import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/formrepo_controller.dart';
import 'package:trazaapp/presentation/scanner/scanner_view.dart';
import 'package:trazaapp/presentation/widgets/custom_button.dart';
import 'package:trazaapp/presentation/widgets/custom_dropdown.dart';
import 'package:trazaapp/presentation/widgets/custom_textfield.dart';
import 'package:trazaapp/presentation/widgets/loading_widget.dart';
import 'package:trazaapp/utils/utils.dart';
import 'package:trazaapp/data/models/razas/raza.dart';

class FormRepoView extends GetView<FormRepoController> {
  FormRepoView({Key? key}) : super(key: key);

  // Declarar un controlador para el campo de búsqueda de raza
  final TextEditingController searchRazaController = TextEditingController();
  String searchRaza = '';

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
              // Encabezado con información básica
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CUE: ${controller.entrega.value?.cue ?? ""}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'CUPA: ${controller.entrega.value?.cupa ?? ""}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Cantidad: ${controller.bovinosRepo.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón de llenado rápido (ahora en la parte superior)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'llenado_rapido',
                    onPressed: () {
                      _showQuickFillDialog(context);
                    },
                    child: const Icon(Icons.flash_on),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      _showBovinosNavigator(context);
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Vista Previa',
                        style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              const Divider(
                height: 20,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),

              // PageView modificado para incluir página final
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: (index) {
                    controller.currentPage.value = index;
                  },
                  itemCount: controller.bovinosRepo.length +
                      1, // +1 para la página final
                  itemBuilder: (context, index) {
                    // Si es la última página, mostrar la página final
                    if (index == controller.bovinosRepo.length) {
                      return _buildFinalDataForm();
                    } else {
                      // Si no, mostrar la página de bovino correspondiente
                      return _buildFormPage(index);
                    }
                  },
                ),
              ),

              // BOTONES Navegación
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // BOTÓN ANTERIOR
                    Obx(() {
                      return Visibility(
                        visible: controller.currentPage.value > 0,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: controller.previousPage,
                          label: const Text('Anterior'),
                        ),
                      );
                    }),

                    // BOTÓN SIGUIENTE (cambia en la última página)
                    Obx(() {
                      final current = controller.currentPage.value;

                      // Si estamos en la página final, no mostramos el botón
                      if (current == controller.bovinosRepo.length) {
                        return const SizedBox();
                      }

                      // Caso contrario (páginas de bovinos)
                      return ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(
                          // Si es el último bovino => "Ir a Fotos/Docs"
                          (current == controller.bovinosRepo.length - 1)
                              ? 'Ir a Fotos/Docs'
                              : 'Siguiente',
                        ),
                        onPressed: () {
                          // Si estás en el último bovino => saltar a la página final
                          if (current == controller.bovinosRepo.length - 1) {
                            controller.currentPage.value =
                                controller.bovinosRepo.length;
                            controller.pageController
                                .jumpToPage(controller.bovinosRepo.length);
                          } else {
                            // Si no, siguiente
                            controller.nextPage();
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Página de formulario para un Bovino
  Widget _buildFormPage(int index) {
    final bovino = controller.bovinosRepo[index];
    final total = controller.bovinosRepo.length;
    String _formatearArete(String arete) {
      if (arete.startsWith('558')) {
        return arete.padLeft(12, '0');
      } else {
        return '558' + arete.padLeft(9, '0');
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Arete: ${_formatearArete(bovino.arete)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            '${index + 1} de $total',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: GetBuilder<FormRepoController>(
                  builder: (ctrl) => CustomTextField(
                    label: 'Arete Anterior',
                    initialValue: bovino.areteAnterior,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(13),
                    ],
                    onChanged: (value) =>
                        controller.updateAreteAnterior(index, value),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () async {
                  try {
                    final result = await Get.toNamed('/scanner');
                    if (result != null && result is String) {
                      controller.updateAreteAnterior(index, result);
                      controller.update();
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
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Arete Nuevo: ${bovino.arete}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Edad (meses)',
                  initialValue: bovino.edad > 0 ? bovino.edad.toString() : '',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  onChanged: (value) {
                    int edad = int.tryParse(value) ?? 0;
                    if (edad > 240) {
                      edad = 240;
                      Get.snackbar(
                        'Límite de edad',
                        'La edad máxima permitida es 240 meses.',
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    }
                    controller.updateEdad(index, edad);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomDropdown<String>(
                  label: 'Sexo',
                  value: bovino.sexo.isEmpty ? null : bovino.sexo,
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
          Autocomplete<Raza>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return controller.razas;
              }
              return controller.razas.where((Raza r) =>
                  r.nombre.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            displayStringForOption: (Raza option) => option.nombre,
            initialValue: TextEditingValue(
              text: bovino.razaId.isNotEmpty
                  ? (controller.razas.firstWhereOrNull((r) => r.id == bovino.razaId)?.nombre ?? '')
                  : '',
            ),
            onSelected: (Raza selection) {
              controller.updateRaza(index, selection.id);
            },
            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Buscar raza',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          CustomDropdown<String>(
            label: 'Traza',
            value: bovino.traza.isEmpty ? 'CRUCE' : bovino.traza,
            items: const ['CRUCE', 'PURO'],
            onChanged: (value) {
              if (value != null) {
                controller.updateTraza(index, value);
              }
            },
          ),

          // Si es PURO => genealogía
          if (bovino.traza == 'PURO') ...[
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Arete Madre (obligatorio)',
              initialValue: bovino.areteMadre,
              keyboardType: TextInputType.number,
              onChanged: (value) => controller.updateAreteMadre(index, value),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              label: 'Arete Padre (obligatorio)',
              initialValue: bovino.aretePadre,
              keyboardType: TextInputType.number,
              onChanged: (value) => controller.updateAretePadre(index, value),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              label: 'Registro Madre (opcional)',
              initialValue: bovino.regMadre,
              onChanged: (value) => controller.updateRegMadre(index, value),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              label: 'Registro Padre (opcional)',
              initialValue: bovino.regPadre,
              onChanged: (value) => controller.updateRegPadre(index, value),
            ),
          ],

          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.orange, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.orange, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estado del Arete:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CustomDropdown<String>(
                        label: '',
                        value: bovino.estadoArete,
                        items: const ['Bueno', 'Dañado', 'No Utilizado'],
                        onChanged: (value) {
                          if (value != null) {
                            controller.updateEstadoArete(index, value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (bovino.estadoArete == 'Dañado' || bovino.estadoArete == 'No Utilizado') ...[
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
        ],
      ),
    );
  }

  // Página final para fotos y PDF
  Widget _buildFinalDataForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final controller = Get.find<FormRepoController>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.error.value != null && controller.error.value!.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  border: Border.all(color: Colors.red, width: 1.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(controller.error.value!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            const Text(
              'Fotos y Documento Final',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Campo de observaciones
            TextField(
              controller: controller.observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                border: OutlineInputBorder(),
                hintText:
                    'Ingrese aquí cualquier observación relevante sobre la reposición',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Foto Inicial
            const Text('Foto Inicial'),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Tomar Foto Inicial'),
              onPressed: () => controller.pickImageUniversal(target: 'inicial'),
            ),
            const SizedBox(height: 6),
            _buildImageThumbnail(controller.fotoBovInicial.value),

            const SizedBox(height: 20),

            // Foto Final
            const Text('Foto Final'),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Tomar Foto Final'),
              onPressed: () => controller.pickImageUniversal(target: 'final'),
            ),
            const SizedBox(height: 6),
            _buildImageThumbnail(controller.fotoBovFinal.value),

            const SizedBox(height: 20),

            // PDF Ficha
            const Text('Documento de Ficha (PDF)'),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Seleccionar PDF'),
              onPressed: () => controller.pickPdfFicha(),
            ),
            const SizedBox(height: 6),
            _buildPdfIndicator(controller.fotoFicha.value, controller),

            const SizedBox(height: 40),

            // Botón Final
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                onPressed: () {
                  _validarYGuardarReposicion(controller);
                },
                child: const Text(
                  "Finalizar",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Diálogo de llenado rápido
  void _showQuickFillDialog(BuildContext context) {
    int? edad;
    String? sexo;
    String? raza;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Llenado Rápido'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Edad (meses)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  onChanged: (value) {
                    int edad = int.tryParse(value) ?? 0;
                    if (edad > 240) {
                      edad = 240;
                      Get.snackbar(
                        'Límite de edad',
                        'La edad máxima permitida es 240 meses.',
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    }
                    edad = edad;
                  },
                ),
                const SizedBox(height: 8),
                CustomDropdown<String>(
                  label: 'Sexo',
                  items: const ['M', 'H'],
                  onChanged: (value) {
                    sexo = value;
                  },
                ),
                const SizedBox(height: 8),
                Autocomplete<Raza>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return controller.razas;
                    }
                    return controller.razas.where((Raza r) =>
                        r.nombre.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  displayStringForOption: (Raza option) => option.nombre,
                  onSelected: (Raza selection) {
                    raza = selection.id;
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Buscar raza',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Validar que se hayan seleccionado todos los campos
                if ((edad == null || edad! <= 0) ||
                    sexo == null ||
                    raza == null) {
                  Get.snackbar(
                    'Error',
                    'Debe completar todos los campos',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                // Aplicar los valores a todos los bovinos
                controller.applyQuickFill(
                  edad: edad!,
                  sexo: sexo!,
                  raza: raza!,
                );

                Get.back();
                Get.snackbar(
                  'Éxito',
                  'Datos aplicados correctamente a todos los bovinos',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  // Miniatura para imágenes
  Widget _buildImageThumbnail(String base64img) {
    if (base64img.isEmpty) {
      return const Text(
        'No hay imagen seleccionada',
        style: TextStyle(color: Colors.grey),
      );
    }
    try {
      final bytes = base64Decode(base64img);
      return Center(
        child: Container(
          width: 150,
          height: 150,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueGrey, width: 2),
            image: DecorationImage(
              image: MemoryImage(bytes),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } catch (_) {
      return const Text(
        'Error al mostrar la imagen',
        style: TextStyle(color: Colors.red),
      );
    }
  }

  // Indicador para PDF
  Widget _buildPdfIndicator(String base64pdf, FormRepoController controller) {
    if (base64pdf.isEmpty) {
      return const Text(
        'No hay PDF seleccionado',
        style: TextStyle(color: Colors.grey),
      );
    } else {
      // Mostramos el nombre guardado en el controller
      final pdfName = controller.pdfFileName.value;
      return GestureDetector(
        onTap: () {
          Get.snackbar('PDF', 'Abrir archivo: $pdfName');
        },
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.red),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                pdfName.isNotEmpty ? pdfName : 'PDF seleccionado',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }

  // Validar y guardar reposición
  void _validarYGuardarReposicion(FormRepoController controller) {
    // Verificar que todos los bovinos tengan la información necesaria
    bool datosCompletos = true;
    String mensajeError = '';

    for (int i = 0; i < controller.bovinosRepo.length; i++) {
      final bovino = controller.bovinosRepo[i];
      if (bovino.sexo.isEmpty || bovino.razaId.isEmpty || bovino.edad <= 0) {
        datosCompletos = false;
        mensajeError =
            'El bovino \\${i + 1} no tiene todos los datos requeridos';
        break;
      }

      if ((bovino.estadoArete == 'Dañado' || bovino.estadoArete == 'No Utilizado') && bovino.fotoArete.isEmpty) {
        datosCompletos = false;
        mensajeError =
            'El bovino \\${i + 1} tiene arete ${bovino.estadoArete.toLowerCase()} pero no tiene foto';
        break;
      }
    }

    // Verificar que las fotos y observaciones estén completas
    if (datosCompletos) {
      if (controller.fotoBovInicial.value.isEmpty) {
        datosCompletos = false;
        mensajeError = 'Debe tomar la foto inicial';
      } else if (controller.fotoBovFinal.value.isEmpty) {
        datosCompletos = false;
        mensajeError = 'Debe tomar la foto final';
      } else if (controller.fotoFicha.value.isEmpty) {
        datosCompletos = false;
        mensajeError = 'Debe seleccionar el documento de ficha';
      } else if (controller.observacionesController.text.trim().isEmpty) {
        datosCompletos = false;
        mensajeError = 'Debe ingresar observaciones';
      }
    }

    if (!datosCompletos) {
      Get.snackbar(
        'Error',
        mensajeError,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Si todo está completo, guardar la reposición
    controller.guardarReposicion();
  }

  // Navegador de bovinos
  void _showBovinosNavigator(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Lista de Bovinos'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.bovinosRepo.length,
              itemBuilder: (context, i) {
                final bovino = controller.bovinosRepo[i];
                return ListTile(
                  leading: const Icon(Icons.tag),
                  title: Text('Arete: ${bovino.arete}'),
                  subtitle: Text('Anterior: ${bovino.areteAnterior}'),
                  onTap: () {
                    // Cierra el diálogo
                    Navigator.pop(context);
                    // Navegamos a esa página en el PageView
                    controller.currentPage.value = i;
                    controller.pageController.jumpToPage(i);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
