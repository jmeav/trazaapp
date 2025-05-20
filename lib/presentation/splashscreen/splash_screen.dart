import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trazaapp/login/controller/login_controller.dart';
import 'package:trazaapp/data/local/models/appconfig/appconfig_model.dart';

class SplashScreen extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());

  SplashScreen({super.key});

  Future<void> _requestPermissions() async {
    // Solicitar permisos de ubicación y cámara
    PermissionStatus locationStatus = await Permission.location.request();
    PermissionStatus cameraStatus = await Permission.camera.request();

    // Comprobar si se han otorgado los permisos
    if (locationStatus.isGranted && cameraStatus.isGranted) {
      // Marcar que ya no es la primera vez
      final box = Hive.box<AppConfig>('appConfig');
      final config = box.get('config');
      if (config != null) {
        await box.put('config', config.copyWith(isFirstTime: false));
      }
      
      // Navegar al login
      Get.offAllNamed('/login');
    } else {
      // Manejar el caso en que los permisos no se otorgaron
      Get.snackbar(
        'Permisos requeridos',
        'Necesitas otorgar permisos para continuar',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Stack(
      children: [
        OnBoardingSlider(
          finishButtonText: 'Aceptar Permisos',
          centerBackground: true,
          onFinish: _requestPermissions,
          controllerColor: primaryColor,
          totalPage: 3,
          headerBackgroundColor: Colors.white,
          pageBackgroundColor: Colors.white,
          speed: 1.8,
          finishButtonStyle: FinishButtonStyle(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          background: [
            Image.asset(
              'assets/images/wellcome.png',
              height: 400,
            ),
            Image.asset(
              'assets/images/gps.png',
              height: 400,
            ),
            Image.asset(
              'assets/images/camera.png',
              height: 400,
            ),
          ],
          pageBodies: [
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 480,
                  ),
                  Text(
                    '¡BIENVENIDO! Para Comenzar, Necesitamos Permisos!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'agilicemos la información ganadera del pais, juntos!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black26,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 480,
                  ),
                  Text(
                    'Necesitamos tu ubicación',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Para verificar que estés en el establecimiento correcto.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black26,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 480,
                  ),
                  Text(
                    'Necesitamos acceso a tu cámara',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Para tomar fotos de los aretes y documentos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black26,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
