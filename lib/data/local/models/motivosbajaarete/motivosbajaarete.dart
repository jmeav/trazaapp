import 'package:hive/hive.dart';

@HiveType(typeId: 18)
class MotivoBajaArete {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String nombre;

  MotivoBajaArete({required this.id, required this.nombre});

  factory MotivoBajaArete.fromJson(Map<String, dynamic> json) {
    // Asume que la API devuelve 'id' (puede ser String o int) y 'Nombre'
    int parsedId = 0;
    if (json['id'] != null) {
      try {
        parsedId = json['id'] is String ? int.parse(json['id']) : (json['id'] as num).toInt();
      } catch (e) {
        print('Error al parsear ID en MotivoBajaArete: ${json['id']} - $e');
        parsedId = 0;
      }
    }

    // Asume clave 'Nombre' para el nombre, con fallback a 'nombre'
    final nombreValue = json['Nombre']?.toString() ?? json['nombre']?.toString() ?? '';

    return MotivoBajaArete(
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