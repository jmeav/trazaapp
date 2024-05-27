import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/theme/theme_controller.dart';
import 'package:trazaapp/utils/util.dart';
import 'package:trazaapp/theme/theme.dart';

class ThemeCustomizationView extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personalizar Tema'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildThemeCard(
                    context,
                    'Claro',
                    Icons.wb_sunny,
                    Colors.yellow[600]!,
                    () {
                      themeController.changeTheme(
                        MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).light(),
                        'light',
                      );
                    },
                  ),
                  _buildThemeCard(
                    context,
                    'Oscuro',
                    Icons.nights_stay,
                    Colors.black,
                    () {
                      themeController.changeTheme(
                        MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).dark(),
                        'dark',
                      );
                    },
                  ),
                  _buildThemeCard(
                    context,
                    'Contraste Medio Claro',
                    Icons.brightness_medium,
                    Colors.yellow[500]!,
                    () {
                      themeController.changeTheme(
                        MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).lightMediumContrast(),
                        'lightMediumContrast',
                      );
                    },
                  ),
                  _buildThemeCard(
                    context,
                    'Contraste Medio Oscuro',
                    Icons.brightness_medium_outlined,
                    Colors.grey[800]!,
                    () {
                      themeController.changeTheme(
                        MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).darkMediumContrast(),
                        'darkMediumContrast',
                      );
                    },
                  ),
                  _buildThemeCard(
                    context,
                    'Alto Contraste Claro',
                    Icons.brightness_high,
                    Colors.yellow[400]!,
                    () {
                      themeController.changeTheme(
                        MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).lightHighContrast(),
                        'lightHighContrast',
                      );
                    },
                  ),
                  _buildThemeCard(
                    context,
                    'Alto Contraste Oscuro',
                    Icons.brightness_high_outlined,
                    Colors.grey[900]!,
                    () {
                      themeController.changeTheme(
                        MaterialTheme(createTextTheme(context, 'Aldrich', 'Courier Prime')).darkHighContrast(),
                        'darkHighContrast',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
