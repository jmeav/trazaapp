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
  final CatalogosController controller2 =
      Get.put(CatalogosController()); // ⬅️ Agregar esto

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

                _buildDropdown<Departamento>(
                  label: 'Departamento',
                  options: controller.departamentos,
                  selectedValue:
                      controller.departamentoSeleccionado, // ✅ Cambiado
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
                  selectedValue: controller.municipioSeleccionado, // ✅ Cambiado
                  displayString: (m) => m.municipio,
                  onChanged: (municipio) {
                    controller.municipioSeleccionado.value =
                        municipio.idMunicipio;
                  },
                ),

                // Autocompletado para establecimientos
                if (controller.municipioSeleccionado.isNotEmpty)
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
                        (context, controller, focusNode, onFieldSubmitted) {
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
                    return await controller
                        .buscarProductores(textEditingValue.text);
                  },
                  displayStringForOption: (Productor option) =>
                      '${option.nombreProductor} (${option.productor})',
                  onSelected: (Productor selection) {
                    controller.cupaController.text = selection.productor;
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
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

                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.assignment_turned_in),
                    label: const Text('Realizar Entrega'),
                    onPressed: () async {
                      if (_validarSeleccion()) {
                        final cantidadText = controller.cantidadController.text;

                        if (cantidadText.isNotEmpty) {
                          final cantidad = int.tryParse(cantidadText);

                          if (cantidad != null) {
                            bool exito = await controller.asignarAretes(cantidad);
                          } else {
                            Get.snackbar('Error', 'La cantidad debe ser un número válido.');
                          }
                        } else {
                          Get.snackbar('Error', 'Debes ingresar una cantidad.');
                        }
                      } else {
                        Get.snackbar('Error', 'Debes seleccionar todas las opciones antes de continuar.');
                      }
                    },
                  ),
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
      elevation: 10, // Sombra más pronunciada
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Bordes más redondeados
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // Bordes redondeados
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono decorativo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory, // Icono de inventario
                    size: 30,
                    // color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Aretes Disponibles',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          // color: Colors.white, // Texto blanco
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Cantidad disponible
              Text(
                'Cantidad disponible:',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    // fontWeight: FontWeight.bold,
                    // color: Colors.white.withOpacity(0.8), // Texto semi-transparente
                    ),
              ),
              Text(
                '${controller.cantidadDisponible}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    // fontWeight: FontWeight.bold,
                    // color: Colors.white, // Texto blanco
                    ),
              ),
              const SizedBox(height: 15),
              // Rango disponible
              Text(
                'Rangos disponibles:',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(),
              ),
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: controller.rangosConsecutivos.map((rango) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      '${_formatearArete(rango.first)} - ${_formatearArete(rango.last)}  (${rango.length} aretes)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  )
                ).toList(),
              )),
              const SizedBox(height: 15),
              
              // Botón para detalles del bolsón
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Ver Detalles del Bolsón'),
                  onPressed: () => _showBagInfoDialog(context),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Botón para rangos residuales
              Obx(() => controller.tieneRangosResiduales
                ? Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.app_registration),
                      label: const Text('Rangos Residuales Disponibles'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => controller.mostrarRangosResiduales(),
                    ),
                  )
                : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBagInfoDialog(BuildContext context) {
    final controller = Get.find<ManageBagController>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Información del Bolsón'),
          content: Obx(() => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumen de Rangos:', style: const TextStyle(fontWeight: FontWeight.bold)),
                ...controller.rangosConsecutivos.map((rango) =>
                  ExpansionTile(
                    title: Text(
                      '${_formatearArete(rango.first)} - ${_formatearArete(rango.last)}  (${rango.length} aretes)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, right: 8.0),
                        child: SelectableText(
                          rango.map((arete) => _formatearArete(arete)).join(', '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  )
                ),
                const SizedBox(height: 8),
                Text('Total de aretes disponibles: ${controller.cantidadDisponible.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  String _formatearArete(int arete) {
    final base = arete.toString();
    if (base.startsWith('558')) {
      return base.padLeft(12, '0');
    } else {
      return '558' + base.padLeft(9, '0');
    }
  }

  Widget _buildDropdown<T>({
    required String label,
    required List<T> options,
    required RxString selectedValue, // ✅ Ahora usa un `RxString` directamente
    required String Function(T) displayString,
    String Function(T)? subtitleString,
    required Function(T) onChanged,
  }) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<T>(
            value: options.isNotEmpty
                ? options.firstWhereOrNull((e) =>
                    displayString(e) == selectedValue.value) // ✅ Usa `value`
                : null,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: label,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
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
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
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
        ));
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
