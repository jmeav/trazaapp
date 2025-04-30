import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/motivosbajaarete/motivosbajaarete.dart';
import 'package:trazaapp/data/remote/endpoints.dart';

class MotivosBajaAreteRepository {
  final String _url = urlcatalogs; // URL del endpoint de catálogos

  Future<List<MotivoBajaArete>> fetchMotivosBajaArete({
    required String token,
    required String codhabilitado,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_url));
      request.fields.addAll({
        'token': token,
        'tabla': 'motivosbajaarete', // Nombre de la tabla específica
        'codhabilitado': codhabilitado,
      });

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString = await response.stream.bytesToString();
        final decodedResponse = json.decode(responseString);

        // Asume que la respuesta es una lista o un mapa con una clave 'data' que contiene la lista
        List<dynamic> listData = decodedResponse is List 
            ? decodedResponse 
            : (decodedResponse['data'] as List? ?? []);

        // Mapea directamente usando el constructor fromJson simplificado
        List<MotivoBajaArete> motivos = listData
            .map((item) => MotivoBajaArete.fromJson(item as Map<String, dynamic>))
            .toList();

        // Guarda en Hive
        var box = await Hive.openBox<MotivoBajaArete>('motivosbajaarete');
        await box.clear();
        await box.addAll(motivos);
        
        return motivos;
      } else {
        // Considera loguear el cuerpo de la respuesta en caso de error
        // String errorBody = await response.stream.bytesToString();
        // print('Error en fetchMotivosBajaArete: ${response.statusCode}, Body: $errorBody');
        throw Exception('Error al obtener motivos de baja arete: ${response.reasonPhrase} (${response.statusCode})');
      }
    } catch (e) {
      // Considera loguear la excepción
      // print('Excepción en fetchMotivosBajaArete: $e');
      throw Exception('Excepción en fetchMotivosBajaArete: $e');
    }
  }
} 