import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

@HiveType(typeId: 2)
class Entregas {
  @HiveField(0)
  final String entregaId;

  @HiveField(1)
  final String cupa;

  @HiveField(2)
  final String cue;

  @HiveField(3)
  final DateTime fechaEntrega;

  @HiveField(4)
  final String estado;

  @HiveField(5)
  final int cantidad;

  @HiveField(6)
  final int rangoInicial;

  @HiveField(7)
  final int rangoFinal;

  @HiveField(8)
  final double latitud;

  @HiveField(9)
  final double longitud;

  @HiveField(10)
  final String? distanciaCalculada;

  @HiveField(11)
  final String codipsa; // Nuevo campo

  Entregas({
    required this.entregaId,
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
    required this.codipsa,
  });

  /// Método `copyWith`
  Entregas copyWith({
    String? entregaId,
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
    String? codipsa,
  }) {
    return Entregas(
      entregaId: entregaId ?? this.entregaId,
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
      codipsa: codipsa ?? this.codipsa,
    );
  }

  /// Métodos JSON para Hive
  factory Entregas.fromJson(Map<String, dynamic> json) {
    final rango = json['rango']?.split('-') ?? ['0', '0'];
    final fechaEntrega = DateTime.parse(json['fechaEntrega']);

    return Entregas(
      entregaId: json['entregaId'] ??
          DateTime.now().millisecondsSinceEpoch.toString(), // Genera un ID único si no se pasa
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
      codipsa: json['codipsa'] ?? '', // Nuevo campo
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entregaId': entregaId,
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
      'codipsa': codipsa, // Nuevo campo
    };
  }
}
