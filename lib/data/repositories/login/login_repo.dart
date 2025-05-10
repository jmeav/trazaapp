import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/remote/endpoints.dart';

class LoginRepository {
  final String apiUrl = urlogin;

  Future<void> login(String imei, String codHabilitado) async {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields.addAll({
      'imei': imei,
      'codhabilitado': codHabilitado,
    });

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var json = jsonDecode(responseData);

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
        token: imei,
        fechaVencimiento: json['FECHA_VENCIMIENTO'] ?? '',
        fechaEmision: json['FECHA_EMISION'] ?? '',
        foto: json['FOTO'] ?? '',
        qr: json['QR'] ?? '',
      );

      var box = Hive.box<AppConfig>('appConfig');  // No abrirla de nuevo
      await box.put('config', appConfig);  // Guardar el objeto directamente
    } else {
      Get.snackbar('Error', 'Error en el login: ${response.reasonPhrase}');
    }
  }
}
