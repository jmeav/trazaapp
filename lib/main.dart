import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/entregas/view/entregas_view.dart';
import 'package:trazaapp/home/home.dart';
import 'package:trazaapp/home/view/splash_screen.dart';
import 'package:trazaapp/login/view/login_view.dart';
import 'package:trazaapp/theme/configthemes.dart';
import 'package:trazaapp/theme/theme_controller.dart';
import 'package:trazaapp/login/controller/login_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final LoginController loginController = Get.put(LoginController());
   loginController.checkFirstTime(); // Asegura que el valor esté inicializado

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
          GetPage(name: '/customize_theme', page: () => ThemeCustomizationView()),
          GetPage(name: '/entrega', page: () => EntregasView()),  // Nueva ruta
          // Añade aquí las demás rutas
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
          final initialRoute = loginController.isFirstTime.value ? '/splash' : '/home';
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(initialRoute);
          });
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
