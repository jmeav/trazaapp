import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ConsultasMenuView extends StatelessWidget {
  const ConsultasMenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultas'),
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
              label: 'Consultar Altas',
              icon: FontAwesomeIcons.arrowUp,
              onTap: () => Get.toNamed('/consultas/altas'), // Ruta específica
            ),
            _buildMenuButton(
              context: context,
              label: 'Consultar Reposiciones',
              icon: FontAwesomeIcons.undo,
              onTap: () => Get.toNamed('/consultas/repos'), // Nueva ruta
            ),
            _buildMenuButton(
              context: context,
              label: 'Consultar Bajas',
              icon: FontAwesomeIcons.arrowDown,
              onTap: () {
                  // TODO: Implementar navegación a consulta de bajas cuando esté lista
                  Get.snackbar('Próximamente', 'Consulta de bajas estará disponible pronto.');
              },
            ),
          ],
        ),
      ),
    );
  }

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
              style: theme.textTheme.titleSmall, // Un poco más grande que en home
            ),
          ],
        ),
      ),
    );
  }
} 