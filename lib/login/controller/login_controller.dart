import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/repositories/login/login_repo.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  var isFirstTime = true.obs;
  var userType = ''.obs;

  final LoginRepository _loginRepo = LoginRepository();

  @override
  void onInit() {
    super.onInit();
    loadConfig();
  }

  void loadConfig() async {
  if (!Hive.isBoxOpen('appConfig')) {
    await Hive.openBox<AppConfig>('appConfig');  // Asegura que la caja esté abierta
  }
  var box = Hive.box<AppConfig>('appConfig');
  if (box.containsKey('config')) {
    var config = box.get('config');
    if (config != null) {
      isFirstTime.value = config.isFirstTime;
      userType.value = config.categoria;
    } else {
      isFirstTime.value = true;
    }
  } else {
    isFirstTime.value = true;
  }
}


  Future<void> login(String imei, String codHabilitado) async {
    isLoading.value = true;
    try {
      await _loginRepo.login(imei, codHabilitado);
      loadConfig();  // Carga la nueva config después del login
      Get.offNamed('/home');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo iniciar sesión');
    } finally {
      isLoading.value = false;
    }
  }
}
