import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trazaapp/data/remote/endpoints.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class EnvioReposicionRepository {
  /// Envía una reposición a la API
  Future<void> enviarReposicion(Map<String, dynamic> reposicionData) async {
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

      Uri uri = Uri.parse("$urlreposicion?proceso=reposicion");
      print("🌍 URL de envío: $uri");

      var headers = {
        'Content-Type': 'application/json',
        'Cookie': 'TS0191a316=0132c26adc803ca657d757415b17d1d23e54d0a2c9a540943e397dbd01b6d048df2fd06a6c5e43308af488fdb8f4ec7fe75c1121ac'
      };

      print("📤 Enviando Reposición:");
      print(jsonEncode(reposicionData));

      var response = await http.post(
        uri,
        headers: headers,
        body: json.encode(reposicionData),
      );

      print("📥 Respuesta del servidor:");
      print("Status Code: ${response.statusCode}");
      print("Headers: ${response.headers}");
      print("Body: ${response.body}");

      if (response.statusCode == 201) {
        Get.back(); // Cerrar diálogo de carga
        Get.snackbar(
          'Éxito',
          'Reposición enviada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        print("✅ Reposición enviada con éxito: ${response.body}");
      } else {
        Get.back(); // Cerrar diálogo de carga
        Get.snackbar(
          'Error',
          'Error al enviar reposición: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print("❌ Error al enviar reposición: ${response.statusCode}");
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
        throw Exception("Error al enviar reposición.");
      }
    } catch (e) {
      Get.back(); // Cerrar diálogo de carga
      Get.snackbar(
        'Error',
        'Excepción al enviar reposición: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("⚠️ Excepción en enviarReposicion: $e");
      print("⚠️ Stack trace: ${StackTrace.current}");
      rethrow;
    }
  }
} 