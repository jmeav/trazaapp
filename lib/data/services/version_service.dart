import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/remote/endpoints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class VersionService extends GetxService {
  final _box = Hive.box<AppConfig>('appConfig');
  final _connectivity = Connectivity();
  final _versionCheckInterval = const Duration(hours: 24);

  Future<void> checkVersion() async {
    try {
      // Verificar conectividad
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('No hay conexión a internet');
        return;
      }

      // Verificar si es necesario hacer el chequeo
      final config = _box.get('config');
      if (config != null && config.lastVersionCheck != null) {
        final timeSinceLastCheck = DateTime.now().difference(config.lastVersionCheck!);
        if (timeSinceLastCheck < _versionCheckInterval) {
          return;
        }
      }

      // Obtener versión actual de la app
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Obtener última versión del servidor
      final response = await http.get(Uri.parse(urversion));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['version'] as String;
        final forceUpdate = data['force_update'] as bool? ?? false;
        final updateMessage = data['message'] as String? ?? '';

        // Actualizar configuración
        if (config != null) {
          final updatedConfig = config.copyWith(
            appVersion: currentVersion,
            latestVersion: latestVersion,
            lastVersionCheck: DateTime.now(),
          );
          await _box.put('config', updatedConfig);
        }
      } else {
        print('Error al obtener la versión: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al verificar versión: $e');
    }
  }

  bool hasUpdateAvailable() {
    final config = _box.get('config');
    if (config == null) return false;

    final current = config.appVersion.split('.').map(int.parse).toList();
    final latest = config.latestVersion.split('.').map(int.parse).toList();

    for (var i = 0; i < 3; i++) {
      if (latest[i] > current[i]) return true;
      if (latest[i] < current[i]) return false;
    }
    return false;
  }

  String getCurrentVersion() {
    final config = _box.get('config');
    return config?.appVersion ?? '1.0.0';
  }

  String getLatestVersion() {
    final config = _box.get('config');
    return config?.latestVersion ?? '1.0.0';
  }

  DateTime? getLastCheck() {
    final config = _box.get('config');
    return config?.lastVersionCheck;
  }

  bool shouldCheckForUpdate() {
    final lastCheck = getLastCheck();
    if (lastCheck == null) return true;
    
    final timeSinceLastCheck = DateTime.now().difference(lastCheck);
    return timeSinceLastCheck >= _versionCheckInterval;
  }
} 