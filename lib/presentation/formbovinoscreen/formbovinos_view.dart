import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/formbovinos_controller.dart';
import 'package:trazaapp/data/models/razas/raza.dart';

class FormBovinosView extends StatelessWidget {
  final FormBovinosController controller = Get.put(FormBovinosController());

  @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('¿Estás seguro?'),
          content: const Text('¿Deseas salir del formulario? Los datos no guardados se perderán.'),
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
        backgroundColor: Colors.transparent,
        title: const Text('Información individual'),
      ),
      body: Obx(() {
        if (controller.rangos.isEmpty || controller.bovinoInfo.isEmpty) {
          return const Center(
            child: SpinKitCircle(
              color: Color.fromARGB(255, 3, 136, 244),
              size: 50.0,
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cue: ${controller.bovinoInfo.values.first.cue}'),
                  const SizedBox(height: 8),
                  Text(
                      'Rango: ${controller.rangos.first} - ${controller.rangos.last}'),
                  const SizedBox(height: 8),
                  Text('Cantidad: ${controller.rangos.length}'),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Aplicar llenado rápido'),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0, left: 10),
                  child: FloatingActionButton.small(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildQuickFillDialog(context);
                        },
                      );
                    },
                    child: const Icon(Icons.flash_on),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(
                color: Color.fromARGB(255, 213, 197, 197),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: (index) {
                  controller.currentPage.value = index;
                  controller.update();
                },
                itemCount: controller.rangos.length + 1,
                itemBuilder: (context, index) {
                  if (index == controller.rangos.length) {
                    return _buildFinalDataForm();
                  }
                  return _buildFormPage(controller.rangos[index]);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: controller.currentPage.value > 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: controller.previousPage,
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back),
                          SizedBox(width: 8),
                          Text('Anterior'),
                        ],
                      ),
                    ),
                  ),
                ),
                Obx(() {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: controller.currentPage.value ==
                              controller.rangos.length
                          ? () async {
                              controller.saveFinalData();
                            }
                          : controller.nextPage,
                      child: Row(
                        children: [
                          Text(controller.currentPage.value ==
                                  controller.rangos.length
                              ? 'Finalizar Entrega'
                              : 'Siguiente'),
                          const SizedBox(width: 8),
                          Icon(controller.currentPage.value ==
                                  controller.rangos.length
                              ? Icons.check
                              : Icons.arrow_forward),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        );
      }),
    ));
  }

  Widget _buildFormPage(String bovinoID) {
    final bovinoData = controller.bovinoInfo[bovinoID]!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Arete: ${bovinoData.arete}'),
          const SizedBox(height: 16),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Edad (en meses)'),
            controller: TextEditingController(
              text: bovinoData.edad > 0 ? bovinoData.edad.toString() : '',
            ),
            onChanged: (value) {
              final updatedEdad = int.tryParse(value) ?? 0;
              final updatedBovino = bovinoData.copyWith(edad: updatedEdad);
              controller.bovinoInfo[bovinoID] = updatedBovino;
              controller.update();
            },
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: bovinoData.sexo.isEmpty ? null : bovinoData.sexo,
            hint: const Text('Sexo'),
            isExpanded: true,
            onChanged: (String? newValue) {
              bovinoData.sexo = newValue ?? '';
              controller.bovinoInfo[bovinoID] = bovinoData;
              controller.update();
            },
            items: const <String>['M', 'H']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Obx(() {
            return DropdownButton<String>(
              value: bovinoData.raza.isEmpty ? null : bovinoData.raza,
              hint: const Text('Raza'),
              isExpanded: true,
              onChanged: (String? newValue) {
                bovinoData.raza = newValue ?? '';
                controller.bovinoInfo[bovinoID] = bovinoData;
                controller.update();
              },
              items:
                  controller.razas.map<DropdownMenuItem<String>>((Raza raza) {
                return DropdownMenuItem<String>(
                  value: raza.nombre,
                  child: Text(raza.nombre),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 16),
        Obx(() {
  final bovino = controller.bovinoInfo[bovinoID]!; // 🔄 Obtener dentro del Obx
  return DropdownButton<String>(
    value: bovino.traza.isEmpty ? 'CRUCE' : bovino.traza,
    isExpanded: true,
    onChanged: (String? newValue) {
      bovino.traza = newValue ?? 'CRUCE';
      controller.bovinoInfo[bovinoID] = bovino;
      controller.update();
    },
    items: const ['CRUCE', 'PURO']
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
  );
}),
        ],
      ),
    );
  }

  Widget _buildFinalDataForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Foto Inicial del Bovino"),
          ElevatedButton(
            onPressed: () async {
              controller.fotoBovInicial.value = "imagen_base64";
            },
            child: const Text("Tomar Foto"),
          ),
          const SizedBox(height: 16),
          const Text("Foto Final del Bovino"),
          ElevatedButton(
            onPressed: () async {
              controller.fotoBovFinal.value = "imagen_base64";
            },
            child: const Text("Tomar Foto"),
          ),
          const SizedBox(height: 16),
          const Text("Observaciones"),
          TextField(
            onChanged: (value) => controller.observaciones.value = value,
            decoration: const InputDecoration(
              hintText: "Ingrese observaciones...",
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              controller.saveFinalData();
            },
            child: const Text("Finalizar Entrega"),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFillDialog(BuildContext context) {
    final controller = Get.find<FormBovinosController>();

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Llenado Rápido',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Edad'),
                    onChanged: (value) =>
                        controller.quickFillEdad.value = value,
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Obx(() {
                    return DropdownButton<String>(
                      value: controller.quickFillSexo.value.isEmpty
                          ? null
                          : controller.quickFillSexo.value,
                      hint: const Text('Sexo'),
                      onChanged: (String? newValue) {
                        controller.quickFillSexo.value = newValue ?? '';
                      },
                      items: const <String>['M', 'H']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    );
                  }),
                ),
                SizedBox(
                  width: 120,
                  child: Obx(() {
                    return DropdownButton<String>(
                      value: controller.quickFillRaza.value.isEmpty
                          ? null
                          : controller.quickFillRaza.value,
                      hint: const Text('Raza'),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        controller.quickFillRaza.value = newValue ?? '';
                      },
                      items: controller.razas
                          .map<DropdownMenuItem<String>>((Raza raza) {
                        return DropdownMenuItem<String>(
                          value: raza.nombre,
                          child: Text(raza.nombre),
                        );
                      }).toList(),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                Row(
                  children: [
                    Tooltip(
                      message: 'Borrar Llenado Rápido',
                      child: IconButton(
                        icon: Icon(Icons.clear, color: Colors.red[400]),
                        onPressed: () {
                          controller.clearQuickFill();
                          Navigator.of(context).pop();
                          Get.snackbar(
                            'Llenado Rápido',
                            'Datos borrados correctamente.',
                            duration: const Duration(seconds: 2),
                          );
                        },
                      ),
                    ),
                    Tooltip(
                      message: 'Aplicar Llenado Rápido',
                      child: IconButton(
                        icon: Icon(Icons.check, color: Colors.green[600]),
                        onPressed: () {
                          if (controller.quickFillRaza.value.isNotEmpty &&
                              !controller.razas.any((r) =>
                                  r.nombre == controller.quickFillRaza.value)) {
                            Get.snackbar(
                              'Error',
                              'La raza seleccionada no es válida.',
                              duration: const Duration(seconds: 2),
                            );
                            return;
                          }
                          controller.applyQuickFill();
                          Navigator.of(context).pop();
                          Get.snackbar(
                            'Llenado Rápido',
                            'Datos aplicados correctamente.',
                            duration: const Duration(seconds: 2),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
