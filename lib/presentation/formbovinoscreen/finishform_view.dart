import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/controller/formbovinos_controller.dart';
import 'package:trazaapp/data/models/razas/raza.dart';


class FinalizarEntregaView extends StatelessWidget {
  final FormBovinosController controller = Get.find<FormBovinosController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Finalizar Entrega")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Foto Inicial del Bovino"),
            ElevatedButton(
              onPressed: () async {
                // 📌 Capturar imagen y asignarla a `fotoBovInicial`
                controller.fotoBovInicial.value = "imagen_base64"; // Simulación
              },
              child: const Text("Tomar Foto"),
            ),
            const SizedBox(height: 16),
            const Text("Foto Final del Bovino"),
            ElevatedButton(
              onPressed: () async {
                controller.fotoBovFinal.value = "imagen_base64"; // Simulación
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
      ),
    );
  }
}
