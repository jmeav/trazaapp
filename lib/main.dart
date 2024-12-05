import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trazaapp/data/models/bovino/bovino.dart';
import 'package:trazaapp/data/models/bovino/bovino_adapter.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/data/models/entregas/entregas_adapter.dart';
import 'package:trazaapp/data/models/establecimiento.dart';
import 'package:trazaapp/data/models/home_stat.dart';
import 'package:trazaapp/data/models/productor.dart';
import 'package:trazaapp/utils/importer.dart'; // Importamos la función de importer.dart
import 'package:trazaapp/presentation/entpendientes/entlistas_view.dart';
import 'package:trazaapp/presentation/formbovinos/formbovinos_view.dart';
import 'package:trazaapp/presentation/home/home.dart';
import 'package:trazaapp/presentation/splashscreen/splash_screen.dart';
import 'package:trazaapp/login/view/login_view.dart';
import 'package:trazaapp/theme/theme_controller.dart';
import 'package:trazaapp/login/controller/login_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive
  await Hive.initFlutter();

  // Registra los adaptadores de Hive
  Hive.registerAdapter(EntregasAdapter());
  Hive.registerAdapter(BovinoAdapter());

  // Abre las cajas necesarias
  await Hive.openBox<HomeStat>('homeStat');
  await Hive.openBox<Entregas>('entregas');
  await Hive.openBox<Bovino>('bovinos');
  await Hive.openBox<Establecimiento>('establecimientos');
  await Hive.openBox<Productor>('productores');

  // Importar datos de prueba
  await importEntregasData(); // Llamada a la función de importer.dart

  // Imprimir las entregas almacenadas en Hive
  final Box<Entregas> entregasBox = Hive.box<Entregas>('entregas');
  if (entregasBox.isEmpty) {
    print('No hay entregas almacenadas en Hive.');
  } else {
    print('Entregas almacenadas en Hive:');
    for (var key in entregasBox.keys) {
      final entrega = entregasBox.get(key);
      if (entrega != null) {
        print('ID: $key, Datos: ${entrega.toJson()}');
      }
    }
  }

  // Inicializa los controladores de GetX
  final LoginController loginController = Get.put(LoginController());
  loginController.checkFirstTime();
  if (loginController.isFirstTime.value) {
  await importEntregasData();
}

  // // Borrar SharedPreferences al iniciar (solo en pruebas)
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
          GetPage(
            name: '/initial',
            page: () => InitialView(),
          ),
          GetPage(name: '/splash', page: () => SplashScreen()),
          GetPage(name: '/login', page: () => const LoginView()),
          GetPage(name: '/home', page: () => const HomeView()),
          GetPage(name: '/entrega', page: () => EntregasView()), // Nueva ruta
          GetPage(name: '/formbovinos', page: () => FormBovinosView()),
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
