import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/motivosbajabovino/motivosbajabovino.dart';
import 'package:trazaapp/data/remote/endpoints.dart';

class MotivosBajaBovinoRepository {
  final String _url = urlcatalogs; // URL del endpoint de catálogos

  Future<List<MotivoBajaBovino>> fetchMotivosBajaBovino({
    required String token,
    required String codhabilitado,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_url));
      request.fields.addAll({
        'token': token,
        'tabla': 'motivosbajabovino', // Nombre de la tabla específica
        'codhabilitado': codhabilitado,
      });

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString = await response.stream.bytesToString();
        // Imprimir la respuesta exacta para depurar
        print('Respuesta original del servidor para motivosbajabovino:');
        print(responseString);
        
        final decodedResponse = json.decode(responseString);
        print('Respuesta decodificada:');
        print(decodedResponse);
        
        List<dynamic> listData = decodedResponse is List ? decodedResponse : (decodedResponse['data'] as List? ?? []);
        print('Lista de datos extraída:');
        for (var item in listData) {
          print(item);
          // Verificar las claves disponibles
          if (item is Map) {
            print('Claves disponibles: ${item.keys.toList()}');
          }
        }
        
        // Procesar los motivos manteniendo los IDs originales
        List<MotivoBajaBovino> motivos = [];
        
        for (int i = 0; i < listData.length; i++) {
          var jsonItem = listData[i];
          
          // Verificar si es un catálogo pre-formateado o uno del servidor
          if (jsonItem is Map && jsonItem.containsKey('id') && jsonItem.containsKey('Nombre')) {
            // Formato del servidor con "id" y "Nombre"
            int id = int.tryParse(jsonItem['id'].toString()) ?? 0;
            String nombre = jsonItem['Nombre']?.toString() ?? '';
            motivos.add(MotivoBajaBovino(id: id, nombre: nombre));
            print('Agregado motivo desde formato servidor: ID=$id, Nombre=$nombre');
          } else {
            // Formato normal con "ID" y "NOMBRE" o personalizado
            var motivo = MotivoBajaBovino.fromJson(jsonItem);
            motivos.add(motivo);
            print('Agregado motivo desde formato estándar: ID=${motivo.id}, Nombre=${motivo.nombre}');
          }
        }
        
        print("MotivosBajaBovino cargados con IDs únicos: ${motivos.map((m) => '${m.id}:${m.nombre}').join(', ')}");

        var box = await Hive.openBox<MotivoBajaBovino>('motivosbajabovino');
        await box.clear();
        await box.addAll(motivos);
        return motivos;
      } else {
        throw Exception('Error al obtener motivos de baja bovino: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Excepción en fetchMotivosBajaBovino: $e');
    }
  }
} 