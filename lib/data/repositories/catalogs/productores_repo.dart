import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/productores/productor.dart';
import 'package:trazaapp/data/remote/endpoints.dart';

class ProductoresRepository {
  final String _url = urlcatalogs; // URL del endpoint de catálogos

  /// Descarga el catálogo de productores usando [token] y [codhabilitado]
  /// y lo almacena en el Box de Hive "productores".
  Future<List<Productor>> fetchProductores({
    required String token,
    required String codhabilitado,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_url));
      request.fields.addAll({
        'token': token,
        'tabla': 'productores', // Tabla específica para productores
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

        // Convertir cada elemento a un objeto Productor
        List<Productor> productores =
            listData.map((jsonItem) => Productor.fromJson(jsonItem)).toList();

        // Guardar en Hive
        var box = await Hive.openBox<Productor>('productores');
        await box.clear();
        await box.addAll(productores);

        print("Productores descargados y guardados con éxito.");
        return productores;
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        print('Respuesta del servidor: ${await response.stream.bytesToString()}');
        throw Exception('Error al obtener productores.');
      }
    } catch (e) {
      print("Excepción en fetchProductores: $e");
      rethrow;
    }
  }
}
