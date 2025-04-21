import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/controller/managebag_controller.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/models/bag/bag_operadora.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  String getSaludo() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  void checkCatalogData() {
    final entregasBox = Hive.box<Entregas>('entregas');
    final bagBox = Hive.box<Bag>('bag');

    if (entregasBox.isEmpty && bagBox.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/catalogs');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entregaController = Get.put(EntregaController());
    final bagController = Get.put(ManageBagController());
    final box = Hive.box<AppConfig>('appConfig');
    final nombre = box.get('config')?.nombre?.split(' ').first ?? 'Usuario';
    final theme = Theme.of(context); // ✅ ¡Esto arregla el undefined 'theme'!

    checkCatalogData();

    return Scaffold(
      appBar: AppBar(
        title: Text('${getSaludo()}, $nombre 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed('/configs'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await entregaController.refreshData();
          await bagController.loadBagData();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // 📌 Actividades principales
              Text('Actividades principales', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _ActionButton(
                    label: 'Gestionar Aretes',
                    icon: FontAwesomeIcons.tags,
                    onTap: () => Get.toNamed('/managebag'),
                  ),
                  _ActionButton(
                    label: 'Entregas',
                    icon: FontAwesomeIcons.boxOpen,
                    onTap: () => Get.toNamed('/entrega'),
                  ),
                  _ActionButton(
                    label: 'Reposiciones',
                    icon: FontAwesomeIcons.recycle,
                    onTap: () => Get.toNamed('/repo'),
                  ),
                  _ActionButton(
                    label: 'Enviar Altas',
                    icon: FontAwesomeIcons.paperPlane,
                    onTap: () => Get.toNamed('/sendview'),
                  ),
                  _ActionButton(
                    label: 'Registrar Baja',
                    icon: FontAwesomeIcons.skullCrossbones,
                    onTap: () => Get.toNamed('/baja/select'),
                  ),
                  _ActionButton(
                    label: 'Enviar Bajas',
                    icon: FontAwesomeIcons.paperPlane,
                    onTap: () => Get.toNamed('/baja/send'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 🔍 Consultas y herramientas
              Text('Consultas y herramientas', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _ActionButton(
                    label: 'Verificar CUE',
                    icon: FontAwesomeIcons.qrcode,
                    onTap: () => Get.toNamed('/verifycue'),
                  ),
                  _ActionButton(
                    label: 'Consulta Bovino',
                    icon: FontAwesomeIcons.cow,
                    onTap: () {}, // TODO
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.onSurface),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
