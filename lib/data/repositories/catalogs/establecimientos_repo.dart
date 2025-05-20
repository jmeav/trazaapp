import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/establecimiento/establecimiento.dart';
import 'package:trazaapp/data/remote/endpoints.dart';

class EstablecimientosRepository {
  final String _url = urlcatalogs; // Usamos la URL del endpoint de catálogos

  /// Descarga el catálogo de establecimientos usando [token] y [codhabilitado]
  /// y lo almacena en el Box de Hive "establecimientos".
  Future<List<Establecimiento>> fetchEstablecimientos({
    required String token,
    required String codhabilitado,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_url));
      request.fields.addAll({
        'token': token,
        'tabla': 'establecimientos',
        'codhabilitado': codhabilitado,
      });

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString = await response.stream.bytesToString();

        // Intenta decodificar el JSON
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

        // Convertir cada elemento a un objeto Establecimiento
        List<Establecimiento> establecimientos = listData
            .map((jsonItem) => Establecimiento.fromJson(jsonItem))
            .toList();

        // Almacena los establecimientos en el Box de Hive
        var box = await Hive.openBox<Establecimiento>('establecimientos');
        await box.clear(); // Limpiar antes de agregar nuevos datos
        await box.addAll(establecimientos);

        print("Establecimientos descargados y guardados con éxito.");
        return establecimientos;
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        print('Respuesta del servidor: ${await response.stream.bytesToString()}');
        throw Exception('Error al obtener establecimientos.');
      }
    } catch (e) {
      print("Excepción en fetchEstablecimientos: $e");
      rethrow; // Vuelve a lanzar la excepción para manejarla externamente si es necesario
    }
  }
}
