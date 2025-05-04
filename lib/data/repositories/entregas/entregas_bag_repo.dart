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
    final bags = await fetchAllBags(token: token, codhabilitado: codhabilitado);
    if (bags.isEmpty) {
      throw Exception('No se encontraron bags para la operadora');
    }
    return bags.first;
  }

  /// Descarga todos los Bags usando [token] y [codhabilitado]
  Future<List<Bag>> fetchAllBags({
    required String token,
    required String codhabilitado,
  }) async {
    try {
      print("🔄 Iniciando fetchAllBags - URL: $_url");
      
      // Usar MultipartRequest como estaba en el código original
      var request = http.MultipartRequest('POST', Uri.parse(_url));
      request.fields.addAll({
        'token': token,
        'proceso': 'entregasoperadora',
        'codhabilitado': codhabilitado,
      });
      
      print("🔄 Enviando request: ${request.fields}");
      
      http.StreamedResponse response = await request.send();
      print("🔄 Respuesta recibida - Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        String responseString = await response.stream.bytesToString();
        print("🔄 Datos recibidos: ${responseString.substring(0, min(100, responseString.length))}...");
        
        final List<dynamic> bagJsonList = json.decode(responseString);
        print("🔄 Bags encontrados: ${bagJsonList.length}");
        
        if (bagJsonList.isEmpty) {
          throw Exception('No se encontraron bags para la operadora');
        }
        
        // Construir el bag principal
        print("🔄 Procesando bag principal: ${bagJsonList[0]}");
        final bagPrincipal = Bag.fromJson(bagJsonList[0]);
        
        // Construir rangos adicionales si hay más de un bag
        List<RangoBag> rangosAdicionales = [];
        if (bagJsonList.length > 1) {
          print("🔄 Procesando ${bagJsonList.length - 1} rangos adicionales");
          for (int i = 1; i < bagJsonList.length; i++) {
            print("🔄 Rango adicional $i: ${bagJsonList[i]}");
            rangosAdicionales.add(RangoBag.fromJson(bagJsonList[i]));
          }
        }
        
        // Crear el bag completo con todos los rangos
        final bagCompleto = bagPrincipal.copyWith(rangosAdicionales: rangosAdicionales);
        print("🔄 Bag completo creado con ${rangosAdicionales.length} rangos adicionales");
        
        // Guardar en Hive si es necesario
        var box = await Hive.openBox<Bag>('bag');
        await box.clear();
        await box.put(0, bagCompleto);
        print("✅ Bag guardado en Hive");
        
        return [bagCompleto];
      } else {
        print("❌ Error HTTP: ${response.statusCode}");
        print("❌ Razón: ${response.reasonPhrase}");
        String errorBody = await response.stream.bytesToString();
        print("❌ Cuerpo del error: $errorBody");
        throw Exception('Error al obtener el bag: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Excepción en fetchAllBags: $e");
      rethrow;
    }
  }
}

// Función auxiliar para imprimir strings largos
int min(int a, int b) => (a < b) ? a : b;
