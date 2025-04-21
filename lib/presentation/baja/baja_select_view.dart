import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BajaSelectView extends StatelessWidget {
  const BajaSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipo de Baja'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline, size: 32),
                title: const Text('Individual'),
                subtitle: const Text('Registrar una baja individual'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Get.toNamed('/baja/form'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.groups_outlined, size: 32),
                title: const Text('Múltiple'),
                subtitle: const Text('Registrar varias bajas a la vez'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Get.toNamed('/baja/multiple'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 