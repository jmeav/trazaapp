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
                leading: const Icon(Icons.home, size: 32),
                title: const Text('Baja Bovino en Establecimiento'),
                subtitle: const Text('Registrar baja en un establecimiento'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Get.toNamed('/baja/form'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.qr_code, size: 32),
                title: const Text('Baja General (Sin Origen)'),
                subtitle: const Text('Registrar baja solo con código, motivo y evidencia'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Get.toNamed('/baja/formany'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 