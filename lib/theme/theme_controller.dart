import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/theme/theme.dart';
import 'package:trazaapp/utils/util.dart';

class ThemeController extends GetxController {
  var themeData = ThemeData.light().obs;
  late Box<AppConfig> box;

  @override
  Future<void> onInit() async {
    super.onInit();
    if (!Hive.isBoxOpen('appConfig')) {
      box = await Hive.openBox<AppConfig>('appConfig');
    } else {
      box = Hive.box<AppConfig>('appConfig');
    }
    await loadTheme();
  }
  
  Future<void> loadTheme() async {
    if (box.containsKey('config')) {
      var config = box.get('config');
      updateTheme(config?.themeMode ?? 'light');
    } else {
      updateTheme('light');
    }
  }

  Future<void> changeTheme(ThemeData theme, String themeMode) async {
    themeData.value = theme;
    var config = box.get('config') ?? AppConfig(
      imei: '',
      codHabilitado: '',
      nombre: '',
      cedula: '',
      email: '',
      movil: '',
      idOrganizacion: '',
      categoria: '',
      habilitadoOperadora: '',
      isFirstTime: false,
      themeMode: themeMode,
      token: '',
      fechaVencimiento: '',
      fechaEmision: '',
      foto: '',
      qr: '',
      organizacion: '',
    );
    config.themeMode = themeMode;
    await box.put('config', config);  // Guarda el objeto AppConfig directamente
  }

  void updateTheme(String themeMode) {
    final context = Get.context ?? Get.overlayContext;
    if (context != null) {
      themeData.value = themeMode == 'dark'
          ? MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).dark()
          : MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).light();
    } else {
      themeData.value = themeMode == 'dark' ? ThemeData.dark() : ThemeData.light();
    }
  }

  void toggleTheme(BuildContext context) async {
    String currentTheme = themeData.value.brightness == Brightness.dark ? 'dark' : 'light';
    String newTheme = currentTheme == 'light' ? 'dark' : 'light';
    await changeTheme(
      newTheme == 'dark'
          ? MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).dark()
          : MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).light(),
      newTheme,
    );
  }

  Color get spinKitRingColor {
    return themeData.value.primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
