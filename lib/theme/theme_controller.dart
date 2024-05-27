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
  }

  Future<void> loadTheme(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeMode = prefs.getString('themeMode') ?? 'light';
    updateTheme(themeMode, context);
  }

  Future<void> changeTheme(ThemeData theme, String themeMode) async {
    themeData.value = theme;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', themeMode);
  }

  void updateTheme(String themeMode, BuildContext context) {
    ThemeData theme;
    switch (themeMode) {
      case 'dark':
        theme = MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).dark();
        break;
      default:
        theme = MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).light();
    }
    themeData.value = theme;
  }

  void toggleTheme(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentThemeMode = prefs.getString('themeMode') ?? 'light';
    if (currentThemeMode == 'light') {
      changeTheme(
        MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).dark(),
        'dark',
      );
    } else {
      changeTheme(
        MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).light(),
        'light',
      );
    }
  }
}
