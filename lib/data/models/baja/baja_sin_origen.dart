import 'package:hive/hive.dart';

@HiveType(typeId: 20)
class BajaSinOrigen {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime fecha;

  @HiveField(2)
  final String motivo;

  @HiveField(3)
  final String? observaciones;

  @HiveField(4)
  final double latitud;

  @HiveField(5)
  final double longitud;

  @HiveField(6)
  bool enviado;

  BajaSinOrigen({
    required this.id,
    required this.fecha,
    required this.motivo,
    this.observaciones,
    required this.latitud,
    required this.longitud,
    this.enviado = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'motivo': motivo,
      'observaciones': observaciones,
      'latitud': latitud,
      'longitud': longitud,
      'enviado': enviado,
    };
  }

  factory BajaSinOrigen.fromJson(Map<String, dynamic> json) {
    return BajaSinOrigen(
      id: json['id'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      motivo: json['motivo'] as String,
      observaciones: json['observaciones'] as String?,
      latitud: json['latitud'] as double,
      longitud: json['longitud'] as double,
      enviado: json['enviado'] as bool,
    );
  }
} 