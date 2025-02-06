import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/municipios/municipio.dart';
import 'package:trazaapp/data/remote/endpoints.dart';

class MunicipiosRepository {
  final String _url = urlcatalogs; // URL del endpoint de catálogos

  /// Descarga el catálogo de municipios usando [token] y [codhabilitado]
  /// y lo almacena en el Box de Hive "municipios".
  Future<List<Municipio>> fetchMunicipios({
    required String token,
    required String codhabilitado,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_url));
      request.fields.addAll({
        'token': token,
        'tabla': 'municipios', // Cambiado a 'municipios'
        'codhabilitado': codhabilitado,
      });

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString = await response.stream.bytesToString();

        // Decodificar el JSON
        final decodedResponse = json.decode(responseString);

        // Asegúrate de que la respuesta sea una lista o un mapa con 'data'
        List<dynamic> listData;
        if (decodedResponse is List) {
          listData = decodedResponse;
        } else if (decodedResponse is Map && decodedResponse['data'] != null) {
          listData = decodedResponse['data'];
        } else {
          throw Exception("Formato de respuesta inesperado");
        }

        // Convertir cada elemento a un objeto Municipio
        List<Municipio> municipios = listData
            .map((jsonItem) => Municipio.fromJson(jsonItem))
            .toList();

        // Guardar en Hive
        var box = await Hive.openBox<Municipio>('municipios');
        await box.clear();
        await box.addAll(municipios);

        print("Municipios descargados y guardados con éxito.");
        return municipios;
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        print('Respuesta del servidor: ${await response.stream.bytesToString()}');
        throw Exception('Error al obtener municipios.');
      }
    } catch (e) {
      print("Excepción en fetchMunicipios: $e");
      rethrow;
    }
  }
}
