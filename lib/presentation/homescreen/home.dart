import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/controller/managebag_controller.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/models/bag/bag_operadora.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';

// Convertido a StatefulWidget para manejar BottomNavigationBar
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0; // Índice para BottomNavigationBar
  final EntregaController entregaController = Get.put(EntregaController());
  final ManageBagController bagController = Get.put(ManageBagController());

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
        if (mounted) { // Verificar si el widget está montado
        Get.offAllNamed('/catalogs');
        }
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // Ya estamos en Inicio, no hacemos nada o refrescamos
        break;
      case 1:
        Get.toNamed('/consultas');
        // Reset index a 0 para que Inicio quede seleccionado al volver
        Future.delayed(Duration.zero, () => setState(() => _selectedIndex = 0));
        break;
      case 2:
        Get.toNamed('/configs');
        // Reset index a 0 para que Inicio quede seleccionado al volver
        Future.delayed(Duration.zero, () => setState(() => _selectedIndex = 0));
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    checkCatalogData();
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<AppConfig>('appConfig');
    final nombre = box.get('config')?.nombre?.split(' ').first ?? 'Usuario';
    final theme = Theme.of(context);
    final bagBox = Hive.box<Bag>('bag');
    final showGestionarAretes = bagBox.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('${getSaludo()}, $nombre 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed('/perfil'),
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
              _buildSectionTitle(context, 'Registro de Eventos'),
              _buildActionGrid([
                if (showGestionarAretes)
                  _ActionButton(
                    label: 'Gestionar Aretes',
                    icon: FontAwesomeIcons.tags,
                    onTap: () => Get.toNamed('/managebag'),
                  ),
                  _ActionButton(
                  label: 'Registrar Alta', // Anterior: Entregas
                  icon: FontAwesomeIcons.plusCircle, // Icono cambiado
                    onTap: () => Get.toNamed('/entrega'),
                  ),
                  _ActionButton(
                  label: 'Registrar Repo', // Anterior: Reposiciones
                  icon: FontAwesomeIcons.undo, // Icono cambiado
                    onTap: () => Get.toNamed('/repo'),
                  ),
                  _ActionButton(
                    label: 'Registrar Baja',
                    icon: FontAwesomeIcons.skullCrossbones,
                    onTap: () =>Get.toNamed('/baja/form'),
                  ),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Envío al Server'),
              _buildActionGrid([
                _ActionButton(
                  label: 'Enviar Eventos', // Botón único para envíos
                  icon: FontAwesomeIcons.paperPlane, // Icono general de envío
                  onTap: () => Get.toNamed('/send/menu'), // Navega al menú de envíos
                ),
                // Se eliminan los botones específicos de envío
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Consultas'),
              _buildActionGrid([
                _ActionButton(
                  label: 'Consultas', // Botón único
                  icon: FontAwesomeIcons.search, // Icono general
                  onTap: () => Get.toNamed('/consultas/menu'), // Navega al menú
                ),
                // Se eliminan los botones específicos de consulta de altas, etc.
              ]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
        
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  // Helper para construir títulos de sección
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  // Helper para construir Grid de acciones (para reutilizar)
  Widget _buildActionGrid(List<Widget> actions) {
    // Filtrar cualquier widget nulo que pueda venir de condiciones `if`
    final validActions = actions.where((w) => w is _ActionButton).toList();

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2, // Ajusta según prefieras (2 o 3)
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.3, // Ajusta para el tamaño de los botones
      children: validActions,
    );
  }
}

// _ActionButton no necesita cambios
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
        // width: 100, // Ancho fijo puede no ser ideal con GridView
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          // color: theme.colorScheme.surfaceVariant, // Color diferente para botones
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary), // Icono más grande y con color primario
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith( // Texto más pequeño
                  // color: theme.colorScheme.onSurfaceVariant
                  color: theme.colorScheme.onSurface
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
