import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/controller/baja_controller.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/bajasinorigen/baja_sin_origen.dart';

class SendMenuView extends StatelessWidget {
  const SendMenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entregaController = Get.find<EntregaController>();
    final bajaController = Get.find<BajaController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Eventos al Servidor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final altasPendientes = entregaController.altasParaEnviarCount;
          final reposPendientes = entregaController.reposListas.length;
          final boxBajasSinOrigen = Hive.box<BajaSinOrigen>('bajassinorigen');
          final bajasSinOrigenPendientes = boxBajasSinOrigen.values.where((b) => b.estado == 'pendiente').length;
          final bajasPendientes = bajaController.bajasPendientes.length + bajasSinOrigenPendientes;
          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _ActionButton(
                label: 'Enviar Altas',
                imagePath: 'assets/images/enviaralta.png',
                onTap: () => Get.toNamed('/sendview'),
                badgeCount: altasPendientes,
              ),
              _ActionButton(
                label: 'Enviar Reposiciones',
                imagePath: 'assets/images/enviarrepo.png',
                onTap: () => Get.toNamed('/sendrepo'),
                badgeCount: reposPendientes,
              ),
              _ActionButton(
                label: 'Enviar Bajas',
                imagePath: 'assets/images/enviarbaja.png',
                onTap: () => Get.toNamed('/baja/send'),
                badgeCount: bajasPendientes,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String imagePath;
  final VoidCallback onTap;
  final int badgeCount;

  const _ActionButton({
    required this.label,
    required this.imagePath,
    required this.onTap,
    this.badgeCount = 0,
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
            Stack(
              children: [
                Image.asset(
                  imagePath,
                  height: 48,
                  width: 48,
                  fit: BoxFit.contain,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
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