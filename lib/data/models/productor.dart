import 'package:hive/hive.dart';

@HiveType(typeId: 5)
class Productor {
  @HiveField(0)
  final String cupa;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final String departamento;

  @HiveField(3)
  final String municipio;

  @HiveField(4)
  final String celular;

  Productor({
    required this.cupa,
    required this.nombre,
    required this.departamento,
    required this.municipio,
    required this.celular,
  });

  factory Productor.fromJson(Map<String, dynamic> json) {
    return Productor(
      cupa: json['cupa'] ?? '',
      nombre: json['nombre'] ?? '',
      departamento: json['departamento'] ?? '',
      municipio: json['municipio'] ?? '',
      celular: json['celular'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cupa': cupa,
      'nombre': nombre,
      'departamento': departamento,
      'municipio': municipio,
      'celular': celular,
    };
  }
}
