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
      };

      Map<String, dynamic> altaJson = altaEntrega.toJsonEnvio();

      print("📤 Enviando AltaEntrega:");
      print(jsonEncode(altaJson));

      var response = await http.post(
        uri,
        headers: headers,
        body: json.encode(altaJson),
      );

      if (response.statusCode == 201) {
        print("✅ Alta enviada con éxito: ${response.body}");
        // (Opcional: no necesitas volver a guardar aquí si ya está guardada en Hive)
      } else {
        print("❌ Error al enviar alta: ${response.statusCode}");
        try {
          var jsonResponse = jsonDecode(response.body);
          print("🔹 Respuesta del servidor: $jsonResponse");
        } catch (_) {
          print("⚠️ No se pudo parsear la respuesta del servidor.");
        }
        throw Exception("Error al enviar alta.");
      }
    } catch (e) {
      print("⚠️ Excepción en enviarAlta: $e");
      rethrow;
    }
  }
}
