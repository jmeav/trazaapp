import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/bag/bag_operadora.dart';
import 'package:trazaapp/data/remote/endpoints.dart';

class BagRepository {
  final String _url = urlentregas; // Endpoint de operador

  /// Descarga el Bag usando [token] y [codhabilitado]
  Future<Bag> fetchBag({
    required String token,
    required String codhabilitado,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_url));
      request.fields.addAll({
        'token': token,
        'proceso': 'entregasoperadora',
        'codhabilitado': codhabilitado,
      });

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString = await response.stream.bytesToString();
        final decodedResponse = json.decode(responseString);

        if (decodedResponse is List && decodedResponse.isNotEmpty) {
          final bagData =
              decodedResponse.first; // Tomar el primer Map de la lista
          Bag bag = Bag.fromJson(bagData);

          var box = await Hive.openBox<Bag>('bag');
          await box.clear();
          await box.put(0, bag);

          print("✅ Bag descargado y guardado con éxito.");
          return bag;
        } else {
          throw Exception("Formato de respuesta inesperado");
        }
      } else {
        print('❌ Error en la solicitud: ${response.statusCode}');
        print(
            '🔹 Respuesta del servidor: ${await response.stream.bytesToString()}');
        throw Exception('Error al obtener el Bag.');
      }
    } catch (e) {
      print("⚠️ Excepción en fetchBag: $e");
      rethrow;
    }
  }
}
