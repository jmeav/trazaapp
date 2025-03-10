import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/controller/managebag_controller.dart';
import 'package:trazaapp/data/models/departamentos/departamento.dart';
import 'package:trazaapp/data/models/municipios/municipio.dart';
import 'package:trazaapp/data/models/establecimiento/establecimiento.dart';
import 'package:trazaapp/data/models/productores/productor.dart';

class ManageBagView extends StatelessWidget {
  final ManageBagController controller = Get.put(ManageBagController());
    final CatalogosController controller2 = Get.put(CatalogosController()); // ⬅️ Agregar esto


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar Bolsón')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBagInfo(context),
                const SizedBox(height: 16),

                // Selección de departamento y municipio
                _buildDropdown<Departamento>(
                  label: 'Departamento',
                  options: controller.departamentos,
                  selectedValue: controller.departamentoSeleccionado.value,
                  displayString: (d) => d.departamento,
                  onChanged: (departamento) {
                    controller.departamentoSeleccionado.value =
                        departamento.idDepartamento;
                    controller.filtrarMunicipios(departamento.idDepartamento);
                  },
                ),

                _buildDropdown<Municipio>(
                  label: 'Municipio',
                  options: controller.municipiosFiltrados,
                  selectedValue: controller.municipioSeleccionado.value,
                  displayString: (m) => m.municipio,
                  onChanged: (municipio) {
                    controller.municipioSeleccionado.value = municipio.idMunicipio;
                  },
                ),

                // Autocompletado para establecimientos
                if (controller.municipioSeleccionado.isNotEmpty)
                  Autocomplete<Establecimiento>(
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      return await controller.buscarEstablecimientos(textEditingValue.text);
                    },
                    displayStringForOption: (Establecimiento option) =>
                        '${option.nombreEstablecimiento} (${option.establecimiento})',
                    onSelected: (Establecimiento selection) {
                      controller.cueController.text = selection.establecimiento;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Buscar Establecimiento',
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 16),

                // Autocompletado para productores
                Autocomplete<Productor>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    return await controller.buscarProductores(textEditingValue.text);
                  },
                  displayStringForOption: (Productor option) =>
                      '${option.nombreProductor} (${option.productor})',
                  onSelected: (Productor selection) {
                    controller.cupaController.text = selection.productor;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Buscar Productor',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                _buildTextField(
                    controller.cantidadController, 'Cantidad a asignar',
                    isNumeric: true),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  icon: const Icon(Icons.assignment_turned_in),
                  label: const Text('Asignar Bag'),
                  onPressed: () {
                    if (_validarSeleccion()) {
                      controller.asignarBag();
                    } else {
                      Get.snackbar('Error',
                          'Debes seleccionar todas las opciones antes de continuar.');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Muestra la información del Bag disponible
  Widget _buildBagInfo(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bolson Disponible',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Cantidad disponible: ${controller.cantidadDisponible}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Rango disponible: ${controller.rangoAsignado.value}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// Dropdown estilizado para selección de datos
  Widget _buildDropdown<T>({
    required String label,
    required List<T> options,
    required String selectedValue,
    required String Function(T) displayString,
    String Function(T)? subtitleString,
    required Function(T) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: options.isNotEmpty
            ? options.firstWhereOrNull((e) => displayString(e) == selectedValue)
            : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        items: options.map((T option) {
          return DropdownMenuItem<T>(
            value: option,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayString(option),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (subtitleString != null)
                  Text(subtitleString(option),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          );
        }).toList(),
        onChanged: (T? value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }

  /// Campo de texto estándar con validación
  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
    );
  }

  /// Validación de selección de dropdowns antes de asignar el bag
  bool _validarSeleccion() {
    return controller.departamentoSeleccionado.isNotEmpty &&
        controller.municipioSeleccionado.isNotEmpty &&
        controller.cueController.text.isNotEmpty &&
        controller.cupaController.text.isNotEmpty;
  }
}