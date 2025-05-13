import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/repositories/login/login_repo.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';

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
      await Hive.openBox<AppConfig>('appConfig');
    }
    var box = Hive.box<AppConfig>('appConfig');
    if (box.containsKey('config')) {
      var config = box.get('config');
      if (config != null) {
        print("✅ Config cargada - isFirstTime: ${config.isFirstTime}");
        isFirstTime.value = config.isFirstTime;
        userType.value = config.categoria;
      } else {
        print("⚠️ Config es null, estableciendo isFirstTime como true");
        isFirstTime.value = true;
      }
    } else {
      print("⚠️ No hay config en la box, estableciendo isFirstTime como true");
      isFirstTime.value = true;
    }
  }

  Future<void> login(String imei, String codHabilitado) async {
    isLoading.value = true;
    try {
      await _loginRepo.login(imei, codHabilitado);
      
      // Recargar la configuración después del login
      loadConfig();
      
      // Obtener el controlador de catálogos
      final catalogosController = Get.find<CatalogosController>();
      
      // Si es la primera vez, ir directamente a la pantalla de catálogos
      final box = Hive.box<AppConfig>('appConfig');
      final config = box.get('config');
      
      if (config?.isFirstTime == true) {
        print("✅ Primer login exitoso, redirigiendo a descarga de catálogos");
        catalogosController.isForcedDownload.value = true;
        Get.offAllNamed('/catalogs');
      } else {
        print("✅ Login exitoso, redirigiendo a home");
        Get.offAllNamed('/home');
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }
}
