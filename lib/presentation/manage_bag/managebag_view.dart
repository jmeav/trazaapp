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
              // Mostrar cantidad disponible
              Text(
                'Cantidad disponible: ${controller.cantidadDisponible}',
                style: Theme.of(context).textTheme.headlineSmall, // Corrección aquí
              ),
              const SizedBox(height: 16),

              // Campo para departamento
              TextField(
                controller: controller.departamentoController,
                decoration: const InputDecoration(labelText: 'Departamento'),
              ),
              const SizedBox(height: 16),

              // Campo para municipio
              TextField(
                controller: controller.municipioController,
                decoration: const InputDecoration(labelText: 'Municipio'),
              ),
              const SizedBox(height: 16),

              // Campo para CUPA
              TextField(
                controller: controller.cupaController,
                decoration: const InputDecoration(labelText: 'CUPA'),
              ),
              const SizedBox(height: 16),

              // Campo para CUE
              TextField(
                controller: controller.cueController,
                decoration: const InputDecoration(labelText: 'CUE'),
              ),
              const SizedBox(height: 16),

              // Campo para cantidad a asignar
              TextField(
                controller: controller.cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad a asignar'),
              ),
              const SizedBox(height: 16),

              // Botón para asignar
              ElevatedButton(
                onPressed: controller.asignarBag,
                child: const Text('Asignar'),
              ),

              const SizedBox(height: 16),

              // Mostrar rango asignado
              if (controller.rangoAsignado.isNotEmpty)
                Text(
                  'Rango asignado: ${controller.rangoAsignado}',
                  style: Theme.of(context).textTheme.bodyLarge, // Corrección aquí
                ),
            ],
          ),
        ),
      ),
    );
  }
}
