import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:trazaapp/data/models/municipios/minicipio_adapter.dart';
import 'package:trazaapp/data/models/municipios/municipio.dart';
import 'package:trazaapp/data/models/productores/productor.dart';
import 'package:trazaapp/data/models/productores/productor_adapter.dart';
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

  // Registra los adaptadores de Hive
  Hive.registerAdapter(EntregasAdapter());
  Hive.registerAdapter(BovinoAdapter());
  Hive.registerAdapter(EstablecimientoAdapter());
  Hive.registerAdapter(ProductorAdapter());
  Hive.registerAdapter(BagAdapter());
  Hive.registerAdapter(DepartamentoAdapter());
  Hive.registerAdapter(MunicipioAdapter());

  // Abre las cajas necesarias
  await Hive.openBox<HomeStat>('homeStat');
  await Hive.openBox<Entregas>('entregas');
  await Hive.openBox<Bovino>('bovinos');
  await Hive.openBox<Establecimiento>('establecimientos');
  await Hive.openBox<Productor>('productores');
  await Hive.openBox<Bag>('bag');
  await Hive.openBox<Departamento>('departamentos');
  await Hive.openBox<Municipio>('municipios');

  // Inicializa los controladores de GetX
  final LoginController loginController = Get.put(LoginController());
  loginController.checkFirstTime();

  // Limpia SharedPreferences al iniciar (solo en pruebas)
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  print("SharedPreferences borrados con éxito.");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());

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
  final LoginController loginController = Get.find();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: themeController.loadTheme(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final initialRoute =
              loginController.isFirstTime.value ? '/splash' : '/home';
          WidgetsBinding.instance.addPostFrameCallback((_) {
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
        } else {
          return Scaffold(
            body: Center(
              child: SpinKitRing(
                color: themeController.spinKitRingColor,
                size: 50.0,
              ),
            ),
          );
        }
      },
    );
  }
}
