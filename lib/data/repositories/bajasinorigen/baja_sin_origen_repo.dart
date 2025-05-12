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
        Get.snackbar(
          'Error',
          'Error al enviar baja sin origen: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print("❌ Error al enviar baja sin origen: ${response.statusCode}");
        try {
          var jsonResponse = jsonDecode(response.body);
          print("🔹 Respuesta del servidor: $jsonResponse");
        } catch (e) {
          print("⚠️ No se pudo parsear la respuesta del servidor: $e");
          print("⚠️ Respuesta raw: ${response.body}");
          
          if (response.body.contains('<html>')) {
            throw Exception("El servidor ha rechazado la solicitud. Por favor, verifica la configuración del servidor o contacta al administrador.");
          }
        }
        throw Exception("Error al enviar baja sin origen.");
      }
    } catch (e) {
      Get.back(); // Cerrar diálogo de carga
      Get.snackbar(
        'Error',
        'Excepción al enviar baja sin origen: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("⚠️ Excepción en enviarBajaSinOrigen: $e");
      print("⚠️ Stack trace: ${StackTrace.current}");
      rethrow;
    }
  }
} 