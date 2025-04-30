import 'package:hive/hive.dart';

@HiveType(typeId: 17)
class MotivoBajaBovino {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String nombre;

  MotivoBajaBovino({required this.id, required this.nombre});

  factory MotivoBajaBovino.fromJson(Map<String, dynamic> json) {
    // Asume que la API devuelve 'id' (puede ser String o int) y 'Nombre'
    int parsedId = 0;
    if (json['id'] != null) {
      try {
        parsedId = json['id'] is String ? int.parse(json['id']) : (json['id'] as num).toInt();
      } catch (e) {
        // Manejar error de parseo si es necesario, o asignar un valor por defecto
        print('Error al parsear ID en MotivoBajaBovino: ${json['id']} - $e');
        parsedId = 0; // O lanzar excepción
      }
    }

    // Asume clave 'Nombre' para el nombre, con fallback a 'nombre'
    final nombreValue = json['Nombre']?.toString() ?? json['nombre']?.toString() ?? '';

    return MotivoBajaBovino(
      id: parsedId,
      nombre: nombreValue,
    );
  }

  Map<String, dynamic> toJson() {
    // Usa claves en minúscula para consistencia
    return {
      'id': id,
      'nombre': nombre,
    };
  }
} 