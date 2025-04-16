import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/formbovinos_controller.dart';
import 'package:trazaapp/data/models/razas/raza.dart';
import 'package:flutter/services.dart';

class FormBovinosView extends StatelessWidget {
  final FormBovinosController controller = Get.put(FormBovinosController());

  FormBovinosView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
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
                onPressed: () => Get.offAllNamed('/home'),
                child: const Text('Salir'),
              ),
            ],
          ),
        );
        return result ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Formulario de Bovinos'),
          centerTitle: true,
        ),
        // ─────────────────────────────────────────────
        // UN SOLO Obx para todo el contenido
        // ─────────────────────────────────────────────
        body: Obx(() {
          // 1) Si rangos o bovinoInfo están vacíos => spinner
          if (controller.rangos.isEmpty || controller.bovinoInfo.isEmpty) {
            return const Center(
              child: SpinKitCircle(
                color: Color.fromARGB(255, 3, 136, 244),
                size: 50.0,
              ),
            );
          }

          // 2) Construimos la UI principal normalmente
          return Column(
            children: [
              // Encabezado
              Container(
                color: Colors.blue.shade50,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tomamos el primer bovino para mostrar su CUE
                    Text(
                      'CUE: ${controller.bovinoInfo.values.first.cue}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Rango: ${controller.rangos.first} - ${controller.rangos.last}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Cantidad total: ${controller.rangos.length}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Botón Llenado Rápido
             Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    // 1) Botón "Llenado Rápido"
    FloatingActionButton.small(
      heroTag: 'llenado_rapido',
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => _buildQuickFillDialog(context),
        );
      },
      child: const Icon(Icons.flash_on),
    ),
    const SizedBox(width: 16),

    // 2) Botón "Ver Bovinos"
    FloatingActionButton.small(
      heroTag: 'ver_bovinos',
      backgroundColor: Colors.orange,
      onPressed: () {
        _showBovinosNavigator(context);
      },
      child: const Icon(Icons.list_alt),
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

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: (index) {
                    controller.currentPage.value = index;
                  },
                  itemCount: controller.rangos.length + 1,
                  itemBuilder: (context, index) {
                    // si es la última, mostramos la final
                    if (index == controller.rangos.length) {
                      return _buildFinalDataForm();
                    } else {
                      final bovinoID = controller.rangos[index];
                      return _buildFormPage(bovinoID);
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
      Visibility(
        visible: controller.currentPage.value < controller.rangos.length,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.previousPage,
          label: const Text('Anterior'),
        ),
      ),

      // BOTÓN SIGUIENTE (oculto en la página final)
      Obx(() {
        final current = controller.currentPage.value;

        // Si estamos en la página final (fotos, index == rangos.length), NO se muestra el botón
        if (current == controller.rangos.length) {
          return const SizedBox(); // devuelves un widget vacío
        }

        // Caso contrario (páginas de bovinos)
        return ElevatedButton.icon(
          icon: const Icon(Icons.arrow_forward),
          label: Text(
            // Si es el último bovino => "Ir a Fotos/Docs"
            (current == controller.rangos.length - 1)
                ? 'Ir a Fotos/Docs'
                : 'Siguiente',
          ),
          onPressed: () {
            // si estás en el último bovino => saltar a la página final
            if (current == controller.rangos.length - 1) {
              controller.currentPage.value = controller.rangos.length;
              controller.pageController.jumpToPage(controller.rangos.length);
            } else {
              // si no, siguiente
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

  // ═══════════════════════════════════════════════════════
  // Página de formulario para un Bovino
  // ═══════════════════════════════════════════════════════
  Widget _buildFormPage(String bovinoID) {
    // Tomamos el bovino actual
    final bovinoData = controller.bovinoInfo[bovinoID]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bovino Arete: $bovinoID',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // EstadoArete
          Row(
            children: [
              const Text('Estado del Arete:'),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: bovinoData.estadoArete,
                items: const ['Bueno', 'Dañado', 'Perdido'].map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) {
                  var updated = bovinoData.copyWith(
                    estadoArete: val ?? 'Bueno',
                  );
                  if (val != 'Bueno') {
                    // Si no es Bueno => limpiamos
                    updated = updated.copyWith(
                      edad: 0,
                      sexo: '',
                      raza: '',
                      areteMadre: '',
                      aretePadre: '',
                      regMadre: '',
                      regPadre: '',
                    );
                  }
                  controller.bovinoInfo[bovinoID] = updated;
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Si estadoArete != Bueno => tomar foto arete
          if (bovinoData.estadoArete != 'Bueno') ...[
            const Text(
              'Por favor, toma una foto del arete dañado/perdido:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_camera),
              label: const Text('Tomar Foto Arete'),
              onPressed: () async {
                await controller.pickImageUniversal(
                  target: 'arete',
                  bovinoID: bovinoID,
                );
              },
            ),
            const SizedBox(height: 12),

            // Miniatura
            _buildMiniaturaArete(bovinoData.fotoArete),
          ],

          // Si es "Bueno", pedimos edad, sexo, raza, traza
          if (bovinoData.estadoArete == 'Bueno') ...[
            const SizedBox(height: 10),
            // EDAD
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Edad (en meses)',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text: bovinoData.edad > 0 ? '${bovinoData.edad}' : '',
              )..selection = TextSelection.fromPosition(
                  TextPosition(offset: bovinoData.edad > 0 ? '${bovinoData.edad}'.length : 0),
                ),
              onChanged: (value) {
                final e = int.tryParse(value) ?? 0;
                final updated = bovinoData.copyWith(edad: e);
                controller.bovinoInfo[bovinoID] = updated;
              },
            ),

            const SizedBox(height: 16),

            // SEXO
            DropdownButtonFormField<String>(
              value: bovinoData.sexo.isEmpty ? null : bovinoData.sexo,
              decoration: const InputDecoration(
                labelText: 'Sexo',
                border: OutlineInputBorder(),
              ),
              items: const ['M', 'H']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                final updated = bovinoData.copyWith(sexo: val ?? '');
                controller.bovinoInfo[bovinoID] = updated;
              },
            ),

            const SizedBox(height: 16),

            // RAZA
            DropdownButtonFormField<String>(
              value: bovinoData.raza.isEmpty ? null : bovinoData.raza,
              decoration: const InputDecoration(
                labelText: 'Raza',
                border: OutlineInputBorder(),
              ),
              items: controller.razas.map((Raza r) {
                return DropdownMenuItem(
                  value: r.nombre,
                  child: Text(r.nombre),
                );
              }).toList(),
              onChanged: (val) {
                final updated = bovinoData.copyWith(raza: val ?? '');
                controller.bovinoInfo[bovinoID] = updated;
              },
            ),

            const SizedBox(height: 16),

            // TRAZA
            DropdownButtonFormField<String>(
              value: bovinoData.traza.isEmpty ? 'CRUCE' : bovinoData.traza,
              decoration: const InputDecoration(
                labelText: 'Traza',
                border: OutlineInputBorder(),
              ),
              items: const ['CRUCE', 'PURO'].map((t) {
                return DropdownMenuItem(value: t, child: Text(t));
              }).toList(),
              onChanged: (val) {
                final updated = bovinoData.copyWith(traza: val ?? 'CRUCE');
                controller.bovinoInfo[bovinoID] = updated;
              },
            ),

            // Si es PURO => genealogía
            if (bovinoData.traza == 'PURO') ...[
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Arete Madre (obligatorio)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: bovinoData.areteMadre)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: bovinoData.areteMadre.length),
                  ),
                onChanged: (val) {
                  final updated = bovinoData.copyWith(areteMadre: val);
                  controller.bovinoInfo[bovinoID] = updated;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Arete Padre (obligatorio)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: bovinoData.aretePadre)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: bovinoData.aretePadre.length),
                  ),
                onChanged: (val) {
                  final updated = bovinoData.copyWith(aretePadre: val);
                  controller.bovinoInfo[bovinoID] = updated;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Registro Madre (opcional)',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: bovinoData.regMadre)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: bovinoData.regMadre.length),
                  ),
                onChanged: (val) {
                  final updated = bovinoData.copyWith(regMadre: val);
                  controller.bovinoInfo[bovinoID] = updated;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Registro Padre (opcional)',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: bovinoData.regPadre)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: bovinoData.regPadre.length),
                  ),
                onChanged: (val) {
                  final updated = bovinoData.copyWith(regPadre: val);
                  controller.bovinoInfo[bovinoID] = updated;
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  // Última Página => fotos y PDF
  Widget _buildFinalDataForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        // un Obx pequeño aquí para leer las variables fotoBovInicial, fotoBovFinal, fotoFicha
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fotos y Documento Final',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Foto Inicial
            const Text('Foto Inicial'),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Tomar Foto Inicial'),
              onPressed: () {
                controller.pickImageUniversal(target: 'inicial');
              },
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
              onPressed: () {
                controller.pickImageUniversal(target: 'final');
              },
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
              onPressed: () {
                controller.pickPdfFicha();
              },
            ),
            const SizedBox(height: 6),
            _buildPdfIndicator(controller.fotoFicha.value),

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
                  controller.saveFinalData();
                },
                child: const Text(
                  "Finalizar Entrega",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        );
      }),
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

// Indicador PDF
  Widget _buildPdfIndicator(String base64pdf) {
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
          // Aquí, si deseas, puedes abrir el PDF local.
          // Por ejemplo, usando open_file o cualquier plugin.
          // O un simple snackbar:
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
                overflow: TextOverflow.ellipsis, // si el nombre es muy largo
              ),
            ),
          ],
        ),
      );
    }
  }

  // ══════════════════════════════════════════════
  // Diálogo de Llenado Rápido
  // ══════════════════════════════════════════════
  Widget _buildQuickFillDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          // Este Obx sí es válido: se lee quickFillEdad/sexo/raza
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Llenado Rápido',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Edad',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        controller.quickFillEdad.value = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Sexo',
                        border: OutlineInputBorder(),
                      ),
                      value: controller.quickFillSexo.value.isEmpty
                          ? null
                          : controller.quickFillSexo.value,
                      items: const ['M', 'H'].map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (val) {
                        controller.quickFillSexo.value = val ?? '';
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Raza',
                  border: OutlineInputBorder(),
                ),
                value: controller.quickFillRaza.value.isEmpty
                    ? null
                    : controller.quickFillRaza.value,
                items: controller.razas.map((Raza r) {
                  return DropdownMenuItem(
                    value: r.nombre,
                    child: Text(r.nombre),
                  );
                }).toList(),
                onChanged: (val) {
                  controller.quickFillRaza.value = val ?? '';
                },
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          controller.clearQuickFill();
                          Navigator.pop(context);
                          Get.snackbar(
                            'Llenado Rápido',
                            'Datos borrados correctamente.',
                          );
                        },
                        icon: const Icon(Icons.clear, color: Colors.red),
                        tooltip: 'Borrar Llenado Rápido',
                      ),
                      IconButton(
                        onPressed: () {
                          if (controller.quickFillRaza.value.isNotEmpty &&
                              !controller.razas.any((r) =>
                                  r.nombre == controller.quickFillRaza.value)) {
                            Get.snackbar(
                              'Error',
                              'La raza seleccionada no es válida.',
                            );
                            return;
                          }
                          controller.applyQuickFill();
                          Navigator.pop(context);
                          Get.snackbar(
                            'Llenado Rápido',
                            'Datos aplicados correctamente.',
                          );
                        },
                        icon: const Icon(Icons.check, color: Colors.green),
                        tooltip: 'Aplicar Llenado Rápido',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }


  void _showBovinosNavigator(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final allRangos = controller.rangos; // List<String> con los aretes
        return AlertDialog(
          title: const Text('Lista de Bovinos'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allRangos.length,
              itemBuilder: (context, i) {
                final areteID = allRangos[i];
                return ListTile(
                  leading: const Icon(Icons.pets),
                  title: Text('Arete: $areteID'),
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
        );
      },
    );
  }

  // ══════════════════════════════════════════════
  // Miniatura Arete (base64)
  // ══════════════════════════════════════════════
  Widget _buildMiniaturaArete(String base64img) {
    if (base64img.isEmpty) return const SizedBox();

    try {
      final bytes = base64Decode(base64img);
      return Center(
        child: Container(
          width: 150,
          height: 150,
          margin: const EdgeInsets.only(top: 8),
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
        'Error al mostrar foto del arete',
        style: TextStyle(color: Colors.red),
      );
    }
  }
}
