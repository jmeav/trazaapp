import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/data/remote/endpoints.dart';

class EntregasRepository {
  final String _url = urlentregas; // Endpoint de operador

  /// Descarga el catálogo de entregas usando [token] y [codhabilitado]
  Future<List<Entregas>> fetchEntregas({
    required String token,
    required String codhabilitado,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_url));
      request.fields.addAll({
        'token': token,
        'proceso': 'entregas',
        'codhabilitado': codhabilitado,
      });

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString = await response.stream.bytesToString();
        final decodedResponse = json.decode(responseString);

        List<dynamic> listData;
        if (decodedResponse is List) {
          listData = decodedResponse;
        } else if (decodedResponse is Map && decodedResponse['data'] != null) {
          listData = decodedResponse['data'];
        } else {
          throw Exception("Formato de respuesta inesperado");
        }

        List<Entregas> entregas =
            listData.map((jsonItem) => Entregas.fromJson(jsonItem)).toList();

        var box = await Hive.openBox<Entregas>('entregas');
        await box.clear();
        await box.addAll(entregas);

        print("✅ Entregas descargadas y guardadas con éxito.");
        return entregas;
      } else {
        print('❌ Error en la solicitud: ${response.statusCode}');
        print('🔹 Respuesta del servidor: ${await response.stream.bytesToString()}');
        throw Exception('Error al obtener entregas.');
      }
    } catch (e) {
      print("⚠️ Excepción en fetchEntregas: $e");
      rethrow;
    }
  }
}
