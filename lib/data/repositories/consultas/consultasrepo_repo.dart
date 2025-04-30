import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trazaapp/data/remote/endpoints.dart'; // Importar endpoints

class ConsultasRepoRepo {
  Future<dynamic> consultarRepos({
    required String fechaInicio,
    required String fechaFin,
    required String token,
    required String codhabilitado,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      // Considera añadir cookies si son necesarias y gestionadas
    };
    final body = json.encode({
      "fechaInicio": fechaInicio,
      "fechaFin": fechaFin,
      "token": token,
      "codhabilitado": codhabilitado,
    });
    
    // Construir la URL usando la variable urlreposicion de endpoints.dart
    final url = Uri.parse('$urlreposicion?proceso=consultar');
    
    print('Consultando reposiciones en: $url'); // Log para depuración
    print('Body: $body'); // Log para depuración

    final request = http.Request('POST', url);
    request.body = body;
    request.headers.addAll(headers);

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      print('Respuesta consulta reposiciones (${response.statusCode}): $respStr'); // Log

      if (response.statusCode == 200) {
        return json.decode(respStr);
      } else {
        // Intentar decodificar el cuerpo de la respuesta si es un error JSON
        try {
           final errorJson = json.decode(respStr);
           final errorMessage = errorJson['message'] ?? response.reasonPhrase;
           throw Exception('Error consultando reposiciones (${response.statusCode}): $errorMessage');
        } catch (e) {
           // Si no es JSON o falla la decodificación, usar reasonPhrase
           throw Exception('Error consultando reposiciones (${response.statusCode}): ${response.reasonPhrase} - $respStr');
        }
      }
    } catch (e) {
       print('Excepción en consulta reposiciones: $e'); // Log de excepción
       throw Exception('Error de red o conexión consultando reposiciones: $e');
    }
  }
} 