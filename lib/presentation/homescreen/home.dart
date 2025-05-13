import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/controller/managebag_controller.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/models/bag/bag_operadora.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/controller/baja_controller.dart';
import 'package:trazaapp/data/models/bajasinorigen/baja_sin_origen.dart';

// Convertido a StatefulWidget para manejar BottomNavigationBar
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  late final EntregaController entregaController;
  late final ManageBagController bagController;
  late final BajaController bajaController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    try {
      entregaController = Get.put(EntregaController());
      bagController = Get.put(ManageBagController());
      bajaController = Get.put(BajaController(), permanent: true);

      // Inicializar datos
      await Future.wait([
        entregaController.refreshData(),
        bagController.loadBagData(),
      ]);

      // Verificar catálogos después de inicializar
      checkCatalogData();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los datos: $e';
        _isLoading = false;
      });
    }
  }

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
        if (mounted) {
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
        break;
      case 1:
        Get.toNamed('/configs');
        Future.delayed(Duration.zero, () => setState(() => _selectedIndex = 0));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<AppConfig>('appConfig');
    final nombre = box.get('config')?.nombre?.split(' ').first ?? 'Usuario';
    final theme = Theme.of(context);
    final bagBox = Hive.box<Bag>('bag');
    final showGestionarAretes = bagBox.isNotEmpty;

    // if (_isLoading) {
    //   return Scaffold(
    //     body: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           const CircularProgressIndicator(),
    //           const SizedBox(height: 16),
    //           Text(
    //             'Cargando datos...',
    //             style: theme.textTheme.bodyLarge,
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeControllers,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

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
          setState(() => _isLoading = true);
          await _initializeControllers();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'Registro de Eventos'),
              Obx(() {
                final entregasPendientes = entregaController.entregasPendientesCount;
                final reposPendientes = entregaController.entregasConReposicionPendiente.length;
                final boxBajasSinOrigen = Hive.box<BajaSinOrigen>('bajassinorigen');
                final bajasSinOrigenPendientes = boxBajasSinOrigen.values.where((b) => b.estado == 'pendiente').length;
                final bajasPendientes = bajaController.bajasPendientes.length + bajasSinOrigenPendientes;
                return _buildActionGrid([
                  if (showGestionarAretes)
                    _ActionButton(
                      label: 'Gestionar Aretes',
                      imagePath: 'assets/images/gestionararetes.png',
                      onTap: () => Get.toNamed('/managebag'),
                    ),
                  _ActionButton(
                    label: 'Registrar Alta',
                    imagePath: 'assets/images/registraralta.png',
                    onTap: () => Get.toNamed('/entrega'),
                    badgeCount: entregasPendientes,
                  ),
                  _ActionButton(
                    label: 'Registrar Repo',
                    imagePath: 'assets/images/registrarrepo.png',
                    onTap: () => Get.toNamed('/repo'),
                    badgeCount: reposPendientes,
                  ),
                  _ActionButton(
                    label: 'Registrar Baja',
                    imagePath: 'assets/images/registrarbaja.png',
                    onTap: () => Get.toNamed('/baja/select'),
                  ),
                ]);
              }),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Envíos y Consultas'),
              Obx(() {
                final boxBajasSinOrigen = Hive.box<BajaSinOrigen>('bajassinorigen');
                final bajasSinOrigenPendientes = boxBajasSinOrigen.values.where((b) => b.estado == 'pendiente').length;
                final eventosPendientes = entregaController.altasParaEnviarCount + 
                                       entregaController.reposListas.length + 
                                       bajaController.bajasPendientes.length + 
                                       bajasSinOrigenPendientes;
                return _buildActionGrid([
                  _ActionButton(
                    label: 'Enviar Eventos',
                    imagePath: 'assets/images/enviareventos.png',
                    onTap: () => Get.toNamed('/send/menu'),
                    badgeCount: eventosPendientes,
                  ),
                  _ActionButton(
                    label: 'Consultas',
                    imagePath: 'assets/images/consultareventos.png',
                    onTap: () => Get.toNamed('/consultas/menu'),
                  ),
                ]);
              }),
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
                  height: 70,
                  width: 70,
                  fit: BoxFit.contain,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
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
