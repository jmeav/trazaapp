import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SendMenuView extends StatelessWidget {
  const SendMenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Eventos al Servidor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 2 columnas
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2, // Ajustar para el tamaño
          children: [
            _buildMenuButton(
              context: context,
              label: 'Enviar Altas',
              icon: FontAwesomeIcons.arrowCircleUp, // Mismo icono que en home
              onTap: () => Get.toNamed('/sendview'), // Ruta existente de envío de altas
            ),
            _buildMenuButton(
              context: context,
              label: 'Enviar Reposiciones',
              icon: FontAwesomeIcons.cloudUploadAlt, // Mismo icono que en home
              onTap: () => Get.toNamed('/sendrepo'), // Ruta existente de envío de repos
            ),
            _buildMenuButton(
              context: context,
              label: 'Enviar Bajas',
              icon: FontAwesomeIcons.arrowAltCircleUp, // Mismo icono que en home
              onTap: () => Get.toNamed('/baja/send'), // Ruta existente de envío de bajas
            ),
          ],
        ),
      ),
    );
  }

  // Reutilizamos el widget del botón del menú de consultas
  Widget _buildMenuButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
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
            Icon(icon, size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
} 