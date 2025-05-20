import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trazaapp/data/remote/endpoints.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class EnvioBajaSinOrigenRepository {
  Future<void> enviarBajaSinOrigen(Map<String, dynamic> bajaData) async {
    try {
      // Mostrar diálogo de carga
      Get.dialog(
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Enviando datos...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      Uri uri = Uri.parse("$urlbajassinorigen?proceso=bajassinorigen");
      print("🌍 URL de envío: $uri");

      var headers = {
        'Content-Type': 'application/json',
        'Cookie': 'TS0191a316=0132c26adc8adb91fcd4999933f44843b43913630c4f7d8cdfa78fc9375de020a7b95415af6979a3a1b7f0b4f013f167b6caf5e82a'
      };

      print("📤 Enviando Baja Sin Origen:");
      print(jsonEncode(bajaData));

      var response = await http.post(
        uri,
        headers: headers,
        body: json.encode(bajaData),
      );

      print("📥 Respuesta del servidor:");
      print("Status Code: ${response.statusCode}");
      print("Headers: ${response.headers}");
      print("Body: ${response.body}");

      if (response.statusCode == 201) {
        Get.back(); // Cerrar diálogo de carga
        Get.snackbar(
          'Éxito',
          'Baja sin origen enviada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        print("✅ Baja sin origen enviada con éxito: ${response.body}");
      } else {
        Get.back(); // Cerrar diálogo de carga
        try {
          var jsonResponse = jsonDecode(response.body);
          if (response.statusCode == 500 && 
              jsonResponse['error'] == 'Error en la base de datos' &&
              jsonResponse['detalle'].toString().contains('Duplicate entry')) {
            throw Exception('DUPLICATE_ENTRY');
          }
          throw Exception(jsonResponse['detalle'] ?? 'Error al enviar baja sin origen');
        } catch (e) {
          if (e.toString() == 'Exception: DUPLICATE_ENTRY') {
            rethrow;
          }
          print("⚠️ No se pudo parsear la respuesta del servidor: $e");
          print("⚠️ Respuesta raw: ${response.body}");
          if (response.body.contains('<html>')) {
            throw Exception("SERVER_ERROR");
          }
          throw Exception("UNKNOWN_ERROR");
        }
      }
    } catch (e) {
      Get.back(); // Cerrar diálogo de carga
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('SocketException')) {
        throw Exception('CONNECTION_ERROR');
      }
      rethrow;
    }
  }
} 