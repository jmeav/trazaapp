import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

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

  @HiveField(9)
  final String? distanciaCalculada;

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
    this.distanciaCalculada,
  });

  /// Método `copyWith`
  Entregas copyWith({
    String? cupa,
    String? cue,
    DateTime? fechaEntrega,
    String? estado,
    int? cantidad,
    int? rangoInicial,
    int? rangoFinal,
    double? latitud,
    double? longitud,
    String? distanciaCalculada,
  }) {
    return Entregas(
      cupa: cupa ?? this.cupa,
      cue: cue ?? this.cue,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      estado: estado ?? this.estado,
      cantidad: cantidad ?? this.cantidad,
      rangoInicial: rangoInicial ?? this.rangoInicial,
      rangoFinal: rangoFinal ?? this.rangoFinal,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      distanciaCalculada: distanciaCalculada ?? this.distanciaCalculada,
    );
  }

  /// Métodos JSON para Hive
  factory Entregas.fromJson(Map<String, dynamic> json) {
    final rango = json['rango']?.split('-') ?? ['0', '0'];
   
   final fechaEntrega = DateTime.parse(json['fechaEntrega']);

    return Entregas(
      cupa: json['cupa'] ?? '',
      cue: json['cue'] ?? '',
      fechaEntrega: fechaEntrega,
      estado: json['estado'] ?? 'pendiente',
      cantidad: json['cantidad'] ?? 0,
      rangoInicial: int.parse(rango.first),
      rangoFinal: int.parse(rango.last),
      latitud: json['coordenadas']?['latitud'] ?? 0.0,
      longitud: json['coordenadas']?['longitud'] ?? 0.0,
      distanciaCalculada: json['distanciaCalculada'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cupa': cupa,
      'cue': cue,
      'fechaEntrega': DateFormat('dd/MM/yyyy').format(fechaEntrega),
      'estado': estado,
      'cantidad': cantidad,
      'rango': '$rangoInicial-$rangoFinal',
      'coordenadas': {
        'latitud': latitud,
        'longitud': longitud,
      },
      'distanciaCalculada': distanciaCalculada,
    };
  }
}
