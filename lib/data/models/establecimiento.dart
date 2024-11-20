import 'package:hive/hive.dart';

@HiveType(typeId: 4)
class Establecimiento {
  @HiveField(0)
  final String cue;

  @HiveField(1)
  final String cupa;

  @HiveField(2)
  final String nombre;

  @HiveField(3)
  final String departamento;

  @HiveField(4)
  final String municipio;

  @HiveField(5)
  final String coordenadas;

  Establecimiento({
    required this.cue,
    required this.cupa,
    required this.nombre,
    required this.departamento,
    required this.municipio,
    required this.coordenadas,
  });

  factory Establecimiento.fromJson(Map<String, dynamic> json) {
    return Establecimiento(
      cue: json['cue'] ?? '',
      cupa: json['cupa'] ?? '',
      nombre: json['nombre'] ?? '',
      departamento: json['departamento'] ?? '',
      municipio: json['municipio'] ?? '',
      coordenadas: json['coordenadas'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CUE': cue,
      'CUPA': cupa,
      'nombre': nombre,
      'departamento': departamento,
      'municipio': municipio,
      'coordenadas': coordenadas,
    };
  }
}
