import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/formbovinos/controller/formbovinos_controller.dart';

class FormBovinosView extends StatelessWidget {
  final FormBovinosController controller = Get.put(FormBovinosController());

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final cue = args['cue'];
    final rango = args['rango'];
    final cantidad = args['cantidad'];
    final rangos = controller.calculateRangos(rango);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Información individual'),
      ),
      body: Obx(() {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cue: $cue'),
                  SizedBox(height: 8),
                  Text('Rango: $rango'),
                  SizedBox(height: 8),
                  Text('Cantidad: $cantidad'),
                  SizedBox(height: 8),
                ],
              ),
            ),
        Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    Text('Aplicar llenado rápido'),
    Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 10),
      child: FloatingActionButton.small(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16.0),
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
                      SizedBox(height: 16),
                      Obx(() {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 50,
                              width: 80,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: 'Edad'),
                                onChanged: (value) => controller.quickFillEdad.value = value,
                              ),
                            ),
                            Container(
                              height: 65,
                              width: 90,
                              child: DropdownButton<String>(
                                value: controller.quickFillSexo.value.isEmpty
                                    ? null
                                    : controller.quickFillSexo.value,
                                hint: Text('Sexo'),
                                onChanged: (String? newValue) {
                                  controller.quickFillSexo.value = newValue ?? '';
                                },
                                items: <String>['Macho', 'Hembra']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                            Container(
                              height: 65,
                              width: 120,
                              child: DropdownButton<String>(
                                value: controller.quickFillRaza.value.isEmpty
                                    ? null
                                    : controller.quickFillRaza.value,
                                hint: Text('Raza'),
                                onChanged: (String? newValue) {
                                  controller.quickFillRaza.value = newValue ?? '';
                                },
                                items: <String>['Angus', 'Hereford', 'Holstein', 'Charolais']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancelar'),
                          ),
                          Row(
                            children: [
                              Tooltip(
                                message: 'Borrar Llenado Rápido',
                                child: IconButton(
                                  icon: Icon(Icons.clear,color: Colors.red[400]),
                                  onPressed: () {
                                    controller.clearQuickFill();
                                    Navigator.of(context).pop();
                                    Get.snackbar('Llenado Rápido', 'Datos borrados correctamente.');
                                  },
                                ),
                              ),
                              Tooltip(
                                message: 'Aplicar Llenado Rápido',
                                child: IconButton(
                                  icon: Icon(Icons.check,color: Colors.green[600],),
                                  onPressed: () {
                                    controller.applyQuickFill();
                                    Navigator.of(context).pop();
                                    Get.snackbar('Llenado Rápido', 'Datos aplicados correctamente.');
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
            },
          );
        },
        child: Icon(Icons.flash_on),
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
                  final currentBovino = controller.bovinoInfo.values
                      .toList()[controller.currentPage.value];
                  if (currentBovino.areteColocado.value &&
                      (currentBovino.edad.value.isEmpty ||
                          currentBovino.sexo.value.isEmpty ||
                          currentBovino.raza.value.isEmpty)) {
                    Get.snackbar('Campos incompletos',
                        'Por favor, llena todos los campos antes de continuar.');
                    controller.pageController
                        .jumpToPage(controller.currentPage.value);
                  } else {
                    controller.currentPage.value = index;
                  }
                },
                itemCount: rangos.length,
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: _buildFormPage(rangos[index]),
                  );
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
                              rangos.length - 1
                          ? () {
                              Get.snackbar(
                                  'Guardado', 'Los datos han sido guardados.');
                            }
                          : controller.nextPage,
                      child: Row(
                        children: [
                          Text(controller.currentPage.value == rangos.length - 1
                              ? 'Guardar'
                              : 'Siguiente'),
                          SizedBox(width: 8),
                          Icon(controller.currentPage.value == rangos.length - 1
                              ? Icons.save
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
    );
  }

  Widget _buildFormPage(String bovinoID) {
    final bovinoData = controller.bovinoInfo[bovinoID]!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Arete: ${bovinoData.arete}'),
          SizedBox(height: 16),
          Obx(() {
            return TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Edad (en meses)'),
              onChanged: (value) => bovinoData.edad.value = value,
              controller: TextEditingController(text: bovinoData.edad.value)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: bovinoData.edad.value.length),
                ),
            );
          }),
          SizedBox(height: 16),
          Obx(() {
            return DropdownButton<String>(
              value:
                  bovinoData.sexo.value.isEmpty ? null : bovinoData.sexo.value,
              hint: Text('Sexo'),
              isExpanded: true,
              onChanged: (String? newValue) {
                bovinoData.sexo.value = newValue ?? '';
              },
              items: <String>['Macho', 'Hembra']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            );
          }),
          SizedBox(height: 16),
          Obx(() {
            return DropdownButton<String>(
              value:
                  bovinoData.raza.value.isEmpty ? null : bovinoData.raza.value,
              hint: Text('Raza'),
              isExpanded: true,
              onChanged: (String? newValue) {
                bovinoData.raza.value = newValue ?? '';
              },
              items: <String>['Angus', 'Hereford', 'Holstein', 'Charolais']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            );
          }),
          SizedBox(height: 16),
          Obx(() {
            return CheckboxListTile(
              title: Text('Arete colocado'),
              value: bovinoData.areteColocado.value,
              onChanged: (bool? value) {
                bovinoData.areteColocado.value = value ?? false;
              },
            );
          }),
        ],
      ),
    );
  }
}
