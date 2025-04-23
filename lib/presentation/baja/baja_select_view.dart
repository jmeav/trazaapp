import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BajaSelectView extends StatelessWidget {
  const BajaSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Bajas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.add_circle_outline, size: 32),
                title: const Text('Registrar Baja'),
                subtitle: const Text('Registrar una o varias bajas'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Get.toNamed('/baja/form'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.send_outlined, size: 32),
                title: const Text('Bajas pendientes'),
                subtitle: const Text('Ver y enviar bajas pendientes'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Get.toNamed('/baja/send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 