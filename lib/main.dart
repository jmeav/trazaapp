import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/data/models/altaentrega/altaentrega.dart';
import 'package:trazaapp/data/models/altaentrega/altaentrega_adapter.dart';
import 'package:trazaapp/data/models/altaentrega/resbov_adapter.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/models/bag/bag_operadora.dart';
import 'package:trazaapp/data/models/bovinos/bovino.dart';
import 'package:trazaapp/data/models/bovinos/bovino_adapter.dart';
import 'package:trazaapp/data/models/departamentos/departamento.dart';
import 'package:trazaapp/data/models/departamentos/departamento_adapter.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/data/models/entregas/entregas_adapter.dart';
import 'package:trazaapp/data/models/bag/bag_operadora_adapter.dart';
import 'package:trazaapp/data/models/establecimiento/establecimiento.dart';
import 'package:trazaapp/data/models/establecimiento/establecimiento_adapter.dart';
import 'package:trazaapp/data/models/home_stat.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_adapter.dart';
import 'package:trazaapp/data/models/municipios/minicipio_adapter.dart';
import 'package:trazaapp/data/models/municipios/municipio.dart';
import 'package:trazaapp/data/models/productores/productor.dart';
import 'package:trazaapp/data/models/productores/productor_adapter.dart';
import 'package:trazaapp/data/models/razas/raza.dart';
import 'package:trazaapp/data/models/razas/raza_adapter.dart';
import 'package:trazaapp/presentation/catalogscreen/catalogscreen.dart';
import 'package:trazaapp/presentation/finishedscreen/finished_view.dart';
import 'package:trazaapp/presentation/managebagscreen/managebag_view.dart';
import 'package:trazaapp/presentation/pendingscreen/pending_view.dart';
import 'package:trazaapp/presentation/formbovinoscreen/formbovinos_view.dart';
import 'package:trazaapp/presentation/homescreen/home.dart';
import 'package:trazaapp/presentation/splashscreen/splash_screen.dart';
import 'package:trazaapp/login/view/login_view.dart';
import 'package:trazaapp/theme/theme_controller.dart';
import 'package:trazaapp/login/controller/login_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:trazaapp/utils/configscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive
  await Hive.initFlutter();

  Get.lazyPut(() => CatalogosController());
  // Registra los adaptadores de Hive
  Hive.registerAdapter(EntregasAdapter());
  Hive.registerAdapter(BovinoAdapter());
  Hive.registerAdapter(EstablecimientoAdapter());
  Hive.registerAdapter(ProductorAdapter());
  Hive.registerAdapter(BagAdapter());
  Hive.registerAdapter(DepartamentoAdapter());
  Hive.registerAdapter(MunicipioAdapter());
  Hive.registerAdapter(AppConfigAdapter());
  Hive.registerAdapter(AltaEntregaAdapter());
  Hive.registerAdapter(BovinoResumenAdapter());
  Hive.registerAdapter(RazaAdapter());

  // Abre todas las cajas necesarias con manejo de errores
  try {
    await Future.wait([
      Hive.openBox<HomeStat>('homeStat'),
      Hive.openBox<Entregas>('entregas'),
      Hive.openBox<Bovino>('bovinos'),
      Hive.openBox<Establecimiento>('establecimientos'),
      Hive.openBox<Productor>('productores'),
      Hive.openBox<Bag>('bag'),
      Hive.openBox<Departamento>('departamentos'),
      Hive.openBox<Municipio>('municipios'),
      Hive.openBox<AppConfig>('appConfig'),
      Hive.openBox<Raza>('razas'), // Asegurar que la caja de razas se abra correctamente
      Hive.openBox<AltaEntrega>('altaEntrega'), // Nueva caja abierta
      Hive.openBox<BovinoResumen>('resumenBovino'), // Nueva caja abierta
    ]);
  } catch (e) {
    print("Error al abrir cajas de Hive: $e");
  }

  // Inicializa los controladores de GetX
  Get.put(LoginController());
  Get.put(ThemeController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeController.themeData.value,
        initialRoute: '/initial',
        getPages: [
          GetPage(name: '/initial', page: () => InitialView()),
          GetPage(name: '/splash', page: () => SplashScreen()),
          GetPage(name: '/login', page: () => const LoginView()),
          GetPage(name: '/home', page: () => const HomeView()),
          GetPage(name: '/entrega', page: () => EntregasView()),
          GetPage(name: '/formbovinos', page: () => FormBovinosView()),
          GetPage(name: '/managebag', page: () => ManageBagView()),
          GetPage(name: '/sendview', page: () => EnviarView()),
          GetPage(name: '/catalogs', page: () => CatalogosScreen()),
          GetPage(name: '/configs', page: () => ConfiguracionesScreen()),
        ],
      );
    });
  }
}

class InitialView extends StatelessWidget {
  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await themeController.loadTheme();
      final box = Hive.box<AppConfig>('appConfig');
      final initialRoute = box.containsKey('config') ? '/home' : '/splash';
      Get.offAllNamed(initialRoute);
    });

    return Scaffold(
      body: Center(
        child: SpinKitRing(
          color: themeController.spinKitRingColor,
          size: 50.0,
        ),
      ),
    );
  }
}
