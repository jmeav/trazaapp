import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trazaapp/controller/verifycue_controller.dart';
import 'package:trazaapp/data/local/models/departamentos/departamento.dart';
import 'package:trazaapp/data/local/models/municipios/municipio.dart';
import 'package:trazaapp/data/local/models/establecimiento/establecimiento.dart';

class VerifyEstablishmentView extends StatelessWidget {
  final VerifyEstablishmentController controller = Get.put(VerifyEstablishmentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Establecimientos'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selección de departamento
                _buildDropdown<Departamento>(
                  label: 'Departamento',
                  options: controller.departamentos,
                  selectedValue: controller.departamentoSeleccionado.value,
                  displayString: (d) => d.departamento,
                  onChanged: (departamento) {
                    controller.departamentoSeleccionado.value = departamento.idDepartamento;
                    controller.filtrarMunicipios(departamento.idDepartamento);
                  },
                ),

                const SizedBox(height: 16),

                // Selección de municipio
                _buildDropdown<Municipio>(
                  label: 'Municipio',
                  options: controller.municipiosFiltrados,
                  selectedValue: controller.municipioSeleccionado.value,
                  displayString: (m) => m.municipio,
                  onChanged: (municipio) {
                    controller.municipioSeleccionado.value = municipio.idMunicipio;
                  },
                ),

                const SizedBox(height: 16),

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
                      controller.seleccionarEstablecimiento(selection);
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

                const SizedBox(height: 20),

                // Botón de validación
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.location_searching),
                    label: const Text('Validar Ubicación'),
                    onPressed: () {
                      controller.validarUbicacion();
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Mapa y distancia (solo se muestra después de presionar el botón)
                if (controller.mostrarMapa.value && controller.establecimientoSeleccionado.value != null)
                  Column(
                    children: [
                      Text(
                        'Distancia: ${controller.distanciaCalculada.value}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 300,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(
                              double.parse(controller.establecimientoSeleccionado.value!.latitud),
                              double.parse(controller.establecimientoSeleccionado.value!.longitud),
                            ),
                            initialZoom: 13.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: ['a', 'b', 'c'],
                            ),
                            MarkerLayer(
                              markers: [
                                // Marcador del establecimiento
                                Marker(
                                  point: LatLng(
                                    double.parse(controller.establecimientoSeleccionado.value!.latitud),
                                    double.parse(controller.establecimientoSeleccionado.value!.longitud),
                                  ),
                                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                                ),
                                // Marcador de la ubicación del usuario
                                Marker(
                                  point: LatLng(
                                    controller.userLocation.value.latitude,
                                    controller.userLocation.value.longitude,
                                  ),
                                  child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                                ),
                              ],
                            ),
                            // Línea entre la ubicación del usuario y el establecimiento
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: [
                                    LatLng(
                                      controller.userLocation.value.latitude,
                                      controller.userLocation.value.longitude,
                                    ),
                                    LatLng(
                                      double.parse(controller.establecimientoSeleccionado.value!.latitud),
                                      double.parse(controller.establecimientoSeleccionado.value!.longitud),
                                    ),
                                  ],
                                  color: Colors.blue,
                                  strokeWidth: 3,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
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
}