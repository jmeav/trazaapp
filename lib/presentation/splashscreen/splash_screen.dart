import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trazaapp/login/controller/login_controller.dart';

class SplashScreen extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());

  SplashScreen({super.key});

  Future<void> _requestPermissions() async {
    // Solicitar permisos de ubicación y cámara
    PermissionStatus locationStatus = await Permission.location.request();
    PermissionStatus cameraStatus = await Permission.camera.request();

    // Comprobar si se han otorgado los permisos
    if (locationStatus.isGranted && cameraStatus.isGranted) {
      // Navegar a la pantalla de inicio de sesión
      Get.offNamed('/login');
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
    return Obx(() {
      if (loginController.isFirstTime.value) {
        return OnBoardingSlider(
          finishButtonText: 'Aceptar Permisos',
          centerBackground: true,
          onFinish: _requestPermissions,
          finishButtonStyle: const FinishButtonStyle(
            // backgroundColor: kDarkBlueColor,
          ),
          skipTextButton: const Text(
            'Saltar',
            style: TextStyle(
              fontSize: 16,
              // color: kDarkBlueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          controllerColor: const Color.fromARGB(255, 167, 215, 106),
          totalPage: 3,
          headerBackgroundColor: Colors.white,
          pageBackgroundColor: Colors.white,
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
          speed: 1.8,
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
                      // color: kDarkBlueColor,
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
                    'GPS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // color: kDarkBlueColor,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Utilizaremos la ubicación de tu GPS para calcular las distancias',
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
                    'CAMARA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // color: kDarkBlueColor,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Utilizaremos la cámara para tomar fotos de las evidencias',
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
        );
      } else {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    });
  }
}
