import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trazaapp/data/models/altaentrega/altaentrega.dart';
import 'package:trazaapp/data/remote/endpoints.dart';

class EnvioAltasRepository {
  /// Envía un alta a la API y lo almacena en Hive si es exitoso
  Future<void> enviarAlta(AltaEntrega altaEntrega) async {
    try {
      Uri uri = Uri.parse("$urlaltas?proceso=alta&codhabilitado=${altaEntrega.codhabilitado}");
      print("🌍 URL de envío: $uri");

      var headers = {
  'Content-Type': 'application/json',
  'Cookie': 'TS0191a316=0132c26adc406776fbc50246b266d4bf5715bb57f7b2bda70226710eab47882c7a2f4568e154aef4d3842a5a976bdd661f7b08af27'
};

      Map<String, dynamic> altaJson = altaEntrega.toJsonEnvio();
      print("📤 Enviando AltaEntrega:");
      print(jsonEncode(altaJson));

      var response = await http.post(
        uri,
        headers: headers,
        body: json.encode(altaJson),
      );

      print("📥 Respuesta del servidor:");
      print("Status Code: ${response.statusCode}");
      print("Headers: ${response.headers}");
      print("Body: ${response.body}");

      if (response.statusCode == 201) {
        print("✅ Alta enviada con éxito: ${response.body}");
      } else {
        print("❌ Error al enviar alta: ${response.statusCode}");
        try {
          var jsonResponse = jsonDecode(response.body);
          print("🔹 Respuesta del servidor: $jsonResponse");
        } catch (e) {
          print("⚠️ No se pudo parsear la respuesta del servidor: $e");
          print("⚠️ Respuesta raw: ${response.body}");
          
          // Si la respuesta es HTML, probablemente sea un error de firewall
          if (response.body.contains('<html>')) {
            throw Exception("El servidor ha rechazado la solicitud. Por favor, verifica la configuración del servidor o contacta al administrador.");
          }
        }
        throw Exception("Error al enviar alta.");
      }
    } catch (e) {
      print("⚠️ Excepción en enviarAlta: $e");
      print("⚠️ Stack trace: ${StackTrace.current}");
      rethrow;
    }
  }
}
