import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';

/// Función para importar datos de prueba
Future<void> importEntregasData() async {
  final Box<Entregas> entregasBox = Hive.box<Entregas>('entregas');

  // Si ya hay datos en Hive, no volver a importar
  if (entregasBox.isNotEmpty) return;

  try {
    // Cargar el archivo JSON desde assets
    final String response = await rootBundle.loadString('assets/entregas.json');
    final List<dynamic> jsonData = json.decode(response);

    // Contador para el ID incremental
    int idCounter = 1;

    // Convertir y guardar los datos en Hive
    for (var item in jsonData) {
      final rango = item['rango']?.split('-') ?? ['0', '0'];
      final entrega = Entregas(
        entregaId: idCounter.toString(), // Asignar el ID incremental como string
        cupa: item['cupa'] ?? '',
        cue: item['cue'],
        fechaEntrega: DateTime.parse(item['fechaEntrega']),
        estado: item['estado'],
        cantidad: item['cantidad'],
        rangoInicial: int.parse(rango.first),
        rangoFinal: int.parse(rango.last),
        latitud: item['coordenadas']['latitud'],
        longitud: item['coordenadas']['longitud'],
        distanciaCalculada: item['distanciaCalculada'], codipsa: item['codipsa'], // Puede ser nulo
      );

      await entregasBox.add(entrega);
      idCounter++; // Incrementar el contador para el próximo ID
    }

    print('Datos importados correctamente.');
  } catch (e) {
    print('Error al importar los datos: $e');
  }
}
