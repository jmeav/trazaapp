import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/managebag_controller.dart';

class ManageBagView extends StatelessWidget {
  final ManageBagController controller = Get.put(ManageBagController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Bolsón'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta con información del bag
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bolson Disponible',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('Cantidad disponible: ${controller.cantidadDisponible}',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text('Rango disponible: ${controller.rangoAsignado.value}',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Formulario para asignar bag
              _buildTextField(controller.departamentoController, 'Departamento'),
              _buildTextField(controller.municipioController, 'Municipio'),
              _buildTextField(controller.cupaController, 'CUPA'),
              _buildTextField(controller.cueController, 'CUE'),
              _buildTextField(controller.cantidadController, 'Cantidad a asignar', isNumeric: true),

              const SizedBox(height: 16),

              // Botón de asignación
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.assignment_turned_in),
                  label: const Text('Asignar Bag'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: controller.asignarBag,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
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
}
