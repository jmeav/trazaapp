import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class Entregas {
  @HiveField(0)
  final String cupa;

  @HiveField(1)
  final String cue;

  @HiveField(2)
  final DateTime fechaEntrega;

  @HiveField(3)
  final String estado;

  @HiveField(4)
  final int cantidad;

  @HiveField(5)
  final int rangoInicial;

  @HiveField(6)
  final int rangoFinal;

  @HiveField(7)
  final double latitud;

  @HiveField(8)
  final double longitud;

  Entregas({
    required this.cupa,
    required this.cue,
    required this.fechaEntrega,
    required this.estado,
    required this.cantidad,
    required this.rangoInicial,
    required this.rangoFinal,
    required this.latitud,
    required this.longitud,
  });

  factory Entregas.fromJson(Map<String, dynamic> json) {
    final rango = json['rango']?.split('-') ?? ['0', '0'];
    return Entregas(
      cupa: json['cupa'] ?? '',
      cue: json['cue'] ?? '',
      fechaEntrega: DateTime.parse(json['fechaEntrega']),
      estado: json['estado'] ?? 'pendiente',
      cantidad: json['cantidad'] ?? 0,
      rangoInicial: int.parse(rango.first),
      rangoFinal: int.parse(rango.last),
      latitud: json['coordenadas']?['latitud'] ?? 0.0,
      longitud: json['coordenadas']?['longitud'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cupa': cupa,
      'cue': cue,
      'fechaEntrega': fechaEntrega.toIso8601String(),
      'estado': estado,
      'cantidad': cantidad,
      'rango': '$rangoInicial-$rangoFinal',
      'coordenadas': {
        'latitud': latitud,
        'longitud': longitud,
      },
    };
  }
}
