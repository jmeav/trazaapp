import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ConsultasMenuView extends StatelessWidget {
  const ConsultasMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccione una opción',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _ActionButton(
                    label: 'Consultar Altas',
                    imagePath: 'assets/images/consultaraltas.png',
                    onTap: () => Get.toNamed('/consultas/altas'),
                  ),
                  _ActionButton(
                    label: 'Consultar Bajas',
                    imagePath: 'assets/images/consultarbajas.png',
                    onTap: () => Get.toNamed('/consultas/bajas'),
                  ),
                  _ActionButton(
                    label: 'Consultar Reposiciones',
                    imagePath: 'assets/images/consultarrepo.png',
                    onTap: () => Get.toNamed('/consultas/repos'),
                  ),
                  _ActionButton(
                    label: 'Consultar Bajas sin Origen',
                    imagePath: 'assets/images/consultarbajas.png',
                    onTap: () => Get.toNamed('/consultabajassinorigen'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String imagePath;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 70,
              width: 70,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface
                  ),
            ),
          ],
        ),
      ),
    );
  }
} 