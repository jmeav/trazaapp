import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  // Variables observables
  var isLoading = false.obs;
  var isFirstTime = true.obs;
  var userType = ''.obs;
  var imei = ''.obs;
  var codigoOficial = ''.obs;
  var cedula = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkFirstTime();
  }

  // Función para verificar si es la primera vez
  void checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstTime = prefs.getBool('firstTime');
    if (firstTime == null || firstTime == true) {
      isFirstTime.value = true;
    } else {
      imei.value = prefs.getString('imei') ?? '';
      codigoOficial.value = prefs.getString('codigoOficial') ?? '';
      cedula.value = prefs.getString('cedula') ?? '';
      isFirstTime.value = false;
    }
  }

  // Función para marcar como ya no es la primera vez
  void markAsUsed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstTime', false);
  }

  // Función para iniciar sesión
  void login(String username, String password) async {
    isLoading.value = true;

    // Simular una llamada a la API para login
    await Future.delayed(const Duration(seconds: 1));

    isLoading.value = false;
    // Aquí se manejaría la respuesta de la API
    if (username.isNotEmpty && password.isNotEmpty) {
      // Suponiendo que 'userType' viene de la respuesta de la API
      userType.value = 'habilitado'; // Ejemplo

      // Guardar datos en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('imei', imei.value);
      await prefs.setString('codigoOficial', codigoOficial.value);
      await prefs.setString('cedula', cedula.value);

      // Marcar como no primera vez
       markAsUsed();

      // Navegar a la pantalla correspondiente según el tipo de usuario
      Get.offNamed('/home');
    } else {
      Get.snackbar('Error', 'Usuario o contraseña incorrectos');
    }
  }

  // Función para guardar IMEI y código oficial
  void saveDeviceInfo(String imeiInput, String codigoInput) async {
    imei.value = imeiInput;
    codigoOficial.value = codigoInput;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('imei', imei.value);
    await prefs.setString('codigoOficial', codigoOficial.value);
  }
}
