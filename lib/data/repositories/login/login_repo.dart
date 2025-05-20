import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trazaapp/data/local/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/remote/endpoints.dart';
import 'package:flutter/material.dart';

class LoginRepository {
  final String apiUrl = urlogin;

  Future<void> login(String imei, String codHabilitado) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields.addAll({
        'imei': imei,
        'codhabilitado': codHabilitado,
      });

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var json = jsonDecode(responseData);

      if (response.statusCode == 200) {
        var appConfig = AppConfig(
          imei: imei,
          codHabilitado: json['CODIGO'] ?? '',
          nombre: json['NOMBRE'] ?? '',
          cedula: json['CEDULA'] ?? '',
          email: json['EMAIL'] ?? '',
          movil: json['MOVIL'] ?? '',
          idOrganizacion: json['IDORGANIZACION'] ?? '',
          categoria: json['Categoria'] ?? '',
          habilitadoOperadora: json['HABILITADOOPERADORA'] ?? '',
          isFirstTime: false,
          themeMode: 'light',
          token: json['TOKEN'] ?? '1',
          fechaVencimiento: json['FECHA_VENCIMIENTO'] ?? '',
          fechaEmision: json['FECHA_EMISION'] ?? '',
          foto: json['FOTO'] ?? '',
          qr: json['QR'] ?? '',
          organizacion: json['ORGANIZACION'] ?? '',
        );

        var box = Hive.box<AppConfig>('appConfig');
        await box.put('config', appConfig);
      } else if (response.statusCode == 401) {
        // Manejar específicamente el error 403
        if (json['IMEI_REGISTRADO'] == false) {
          Get.snackbar(
            'Error de Acceso',
            json['MENSAJE_IMEI'] ?? 'Dispositivo no autorizado',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.4),
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        } else {
          Get.snackbar(
            'Error de Acceso',
            'No tiene permisos para acceder',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.4),
            colorText: Colors.white,
          );
        }
        throw Exception(json['MENSAJE_IMEI'] ?? 'Error de acceso');
      } else {
        Get.snackbar(
          'Error',
          'Error en el login: ${response.reasonPhrase}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.4),
          colorText: Colors.white,
        );
        throw Exception('Error en el login: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
