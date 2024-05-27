import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trazaapp/theme/theme.dart';
import 'package:trazaapp/utils/util.dart';

class ThemeController extends GetxController {
  var themeData = ThemeData.light().obs;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeMode = prefs.getString('themeMode') ?? 'light';
    updateTheme(themeMode);
  }

  Future<void> changeTheme(ThemeData theme, String themeMode) async {
    themeData.value = theme;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', themeMode);
  }

  void updateTheme(String themeMode) {
    ThemeData theme;
    switch (themeMode) {
      case 'lightMediumContrast':
        theme = ThemeData.light(); // Tema predeterminado
        break;
      case 'lightHighContrast':
        theme = ThemeData.light();
        break;
      case 'darkMediumContrast':
        theme = ThemeData.dark();
        break;
      case 'darkHighContrast':
        theme = ThemeData.dark();
        break;
        case 'dark':
        theme = ThemeData.dark();
        break;
      default:
        theme = ThemeData.light();
    }
    themeData.value = theme;
  }

  void updateThemeWithContext(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      String? themeMode = prefs.getString('themeMode') ?? 'light';
      ThemeData theme;
      switch (themeMode) {
        case 'lightMediumContrast':
          theme = MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).lightMediumContrast();
          break;
        case 'lightHighContrast':
          theme = MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).lightHighContrast();
          break;
        case 'darkMediumContrast':
          theme = MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).darkMediumContrast();
          break;
        case 'darkHighContrast':
          theme = MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).darkHighContrast();
          break;
            case 'dark':
          theme = MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).dark();
          break;
        default:
          theme = MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).light();
      }
      themeData.value = theme;
    });
  }
}
