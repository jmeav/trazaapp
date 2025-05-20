import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/razas/raza.dart';
import 'package:trazaapp/data/remote/endpoints.dart';

class RazasRepository {
  final String _url = urlcatalogs; // URL del endpoint de catálogos

  /// Descarga el catálogo de razas usando [token] y [codhabilitado]
  /// y lo almacena en el Box de Hive "razas".
  Future<List<Raza>> fetchRazas({
    required String token,
    required String codhabilitado,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_url));
      request.fields.addAll({
        'token': token,
        'tabla': 'raza', // Tabla específica para razas
        'codhabilitado': codhabilitado,
      });

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString = await response.stream.bytesToString();

        // Decodificar el JSON
        final decodedResponse = json.decode(responseString);

        // Asegurar que la respuesta sea una lista o un mapa con 'data'
        List<dynamic> listData;
        if (decodedResponse is List) {
          listData = decodedResponse;
        } else if (decodedResponse is Map && decodedResponse['data'] != null) {
          listData = decodedResponse['data'];
        } else {
          throw Exception("Formato de respuesta inesperado");
        }

        // Convertir cada elemento a un objeto Raza
        List<Raza> razas = listData.map((jsonItem) => Raza(
              id: jsonItem['id'].toString(),
              nombre: jsonItem['Nombre'],
            )).toList();

        // Guardar en Hive
        var box = await Hive.openBox<Raza>('razas');
        await box.clear();
        await box.addAll(razas);

        print("Razas descargadas y guardadas con éxito.");
        return razas;
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        print('Respuesta del servidor: ${await response.stream.bytesToString()}');
        throw Exception('Error al obtener razas.');
      }
    } catch (e) {
      print("Excepción en fetchRazas: $e");
      rethrow;
    }
  }
}
