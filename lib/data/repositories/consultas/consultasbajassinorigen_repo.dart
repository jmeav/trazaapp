import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trazaapp/data/remote/endpoints.dart';

class ConsultasBajasSinOrigenRepo {
  Future<dynamic> consultarBajasSinOrigen({
    required String fechaInicio,
    required String fechaFin,
    required String token,
    required String codhabilitado,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      "fechaInicio": fechaInicio,
      "fechaFin": fechaFin,
      "token": token,
      "codhabilitado": codhabilitado,
    });
    final url = Uri.parse('$urlbajassinorigen?proceso=consultar');
    print('Consultando bajas sin origen en: $url');
    print('Body: $body');
    final request = http.Request('POST', url);
    request.body = body;
    request.headers.addAll(headers);
    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      print('Respuesta consulta bajas sin origen (${response.statusCode}): $respStr');
      if (response.statusCode == 200) {
        return json.decode(respStr);
      } else {
        try {
          final errorJson = json.decode(respStr);
          final errorMessage = errorJson['message'] ?? response.reasonPhrase;
          throw Exception('Error consultando bajas sin origen (${response.statusCode}): $errorMessage');
        } catch (e) {
          throw Exception('Error consultando bajas sin origen (${response.statusCode}): ${response.reasonPhrase} - $respStr');
        }
      }
    } catch (e) {
      print('Excepción en consulta bajas sin origen: $e');
      throw Exception('Error de red o conexión consultando bajas sin origen: $e');
    }
  }
} 