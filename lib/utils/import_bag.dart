import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/bag/bag.dart';

/// Función para importar datos de prueba a Bag
Future<void> importBagData() async {
  final Box<Bag> bagBox = Hive.box<Bag>('bag');

  // Si ya hay datos en Hive, no volver a importar
  if (bagBox.isNotEmpty) return;

  try {
    // Cargar el archivo JSON desde assets
    final String response = await rootBundle.loadString('assets/bag.json');
    final List<dynamic> jsonData = json.decode(response);

    // Convertir y guardar los datos en Hive
    for (var item in jsonData) {
      final bag = Bag(
        rangoInicial: item['rangoInicial'],
        rangoFinal: item['rangoFinal'],
        cantidad: item['cantidad'],
        codIpsa: item['codIpsa'],
      );

      await bagBox.add(bag);
    }

    print('Datos de Bag importados correctamente.');
  } catch (e) {
    print('Error al importar los datos de Bag: $e');
  }
}
