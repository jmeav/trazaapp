import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/departamentos/departamento.dart';
import 'package:trazaapp/data/remote/endpoints.dart';

class DepartamentosRepository {
  final String _url = urlcatalogs; // URL del endpoint de catálogos

  /// Descarga el catálogo de departamentos usando [token] y [codhabilitado]
  /// y lo almacena en el Box de Hive "departamentos".
  Future<List<Departamento>> fetchDepartamentos({
    required String token,
    required String codhabilitado,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_url));
      request.fields.addAll({
        'token': token,
        'tabla': 'departamentos', // Cambiado a 'departamentos'
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

        // Convertir cada elemento a un objeto Departamento
        List<Departamento> departamentos = listData
            .map((jsonItem) => Departamento.fromJson(jsonItem))
            .toList();

        // Guardar en Hive
        var box = await Hive.openBox<Departamento>('departamentos');
        await box.clear();
        await box.addAll(departamentos);

        print("Departamentos descargados y guardados con éxito.");
        return departamentos;
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        print('Respuesta del servidor: ${await response.stream.bytesToString()}');
        throw Exception('Error al obtener departamentos.');
      }
    } catch (e) {
      print("Excepción en fetchDepartamentos: $e");
      rethrow;
    }
  }
}
