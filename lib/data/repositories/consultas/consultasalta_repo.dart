import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trazaapp/data/remote/endpoints.dart';

class ConsultasRepo {
  Future<dynamic> consultarAltas({
    required String fechaInicio,
    required String fechaFin,
    required String token,
    required String codhabilitado,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      // Puedes agregar aquí el cookie si es necesario
    };
    final body = json.encode({
      "fechaInicio": fechaInicio,
      "fechaFin": fechaFin,
      "token": token,
      "codhabilitado": codhabilitado,
    });
    final url = Uri.parse('$urlaltas?proceso=consultar');
    final request = http.Request('POST', url);
    request.body = body;
    request.headers.addAll(headers);

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      return json.decode(respStr);
    } else {
      throw Exception('Error consultando altas: ${response.reasonPhrase}');
    }
  }
} 