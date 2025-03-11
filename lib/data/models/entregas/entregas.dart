import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

@HiveType(typeId: 2)
class Entregas {
  @HiveField(0)
  final String entregaId;

  @HiveField(1)
  final DateTime fechaEntrega;

  @HiveField(2)
  final String cupa;

  @HiveField(3)
  final String cue;

  @HiveField(4)
  final int rangoInicial;

  @HiveField(5)
  final int rangoFinal;

  @HiveField(6)
  final int cantidad;

  @HiveField(7)
  final String nombreProductor;

  @HiveField(8)
  final String establecimiento;

  @HiveField(9)
  final int dias;

  @HiveField(10)
  final String nombreEstablecimiento;

  @HiveField(11)
  final double latitud;

  @HiveField(12)
  final double longitud;

  @HiveField(13)
  final int existencia;

  @HiveField(14)
  final String? distanciaCalculada;

  @HiveField(15)
  final String estado;

  @HiveField(16)
  DateTime lastUpdate;

  @HiveField(17) // Nuevo campo
  final String tipo; // "manual" o "sistema"

  Entregas({
    required this.entregaId,
    required this.fechaEntrega,
    required this.cupa,
    required this.cue,
    required this.rangoInicial,
    required this.rangoFinal,
    required this.cantidad,
    required this.nombreProductor,
    required this.establecimiento,
    required this.dias,
    required this.nombreEstablecimiento,
    required this.latitud,
    required this.longitud,
    required this.existencia,
    this.distanciaCalculada,
    required this.estado,
    required this.lastUpdate,
    this.tipo = 'sistema', // Por defecto es "sistema"
  });

  // Método copyWith
  Entregas copyWith({
    String? entregaId,
    DateTime? fechaEntrega,
    String? cupa,
    String? cue,
    int? rangoInicial,
    int? rangoFinal,
    int? cantidad,
    String? nombreProductor,
    String? establecimiento,
    int? dias,
    String? nombreEstablecimiento,
    double? latitud,
    double? longitud,
    int? existencia,
    String? distanciaCalculada,
    String? estado,
    DateTime? lastUpdate,
    String? tipo,
  }) {
    return Entregas(
      entregaId: entregaId ?? this.entregaId,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      cupa: cupa ?? this.cupa,
      cue: cue ?? this.cue,
      rangoInicial: rangoInicial ?? this.rangoInicial,
      rangoFinal: rangoFinal ?? this.rangoFinal,
      cantidad: cantidad ?? this.cantidad,
      nombreProductor: nombreProductor ?? this.nombreProductor,
      establecimiento: establecimiento ?? this.establecimiento,
      dias: dias ?? this.dias,
      nombreEstablecimiento: nombreEstablecimiento ?? this.nombreEstablecimiento,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      existencia: existencia ?? this.existencia,
      distanciaCalculada: distanciaCalculada ?? this.distanciaCalculada,
      estado: estado ?? this.estado,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      tipo: tipo ?? this.tipo,
    );
  }

  /// Creación del objeto a partir de un JSON
  factory Entregas.fromJson(Map<String, dynamic> json) {
    return Entregas(
      entregaId: json['ID'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      fechaEntrega: DateTime.tryParse(json['FECHAENTRAGA'] ?? '') ?? DateTime.now(),
      cupa: json['CUPA'] ?? '',
      cue: json['CUE'] ?? '',
      rangoInicial: int.tryParse(json['RANGO_INICIAL'] ?? '0') ?? 0,
      rangoFinal: int.tryParse(json['RANGO_FINAL'] ?? '0') ?? 0,
      cantidad: int.tryParse(json['CANTIDAD'] ?? '0') ?? 0,
      nombreProductor: json['NOMBREPRODUCTOR'] ?? '',
      establecimiento: json['DESTABLECIMIENTO'] ?? '',
      dias: int.tryParse(json['DIAS'] ?? '0') ?? 0,
      nombreEstablecimiento: json['NOMBREESTABLECIMIENTO']?.trim() ?? '',
      latitud: double.tryParse(json['Latitud'] ?? '0.0') ?? 0.0,
      longitud: double.tryParse(json['Longitud'] ?? '0.0') ?? 0.0,
      existencia: int.tryParse(json['EXISTENCIA'] ?? '0') ?? 0,
      distanciaCalculada: json['distanciaCalculada'],
      estado: json['ESTADO'] ?? 'pendiente',
      lastUpdate: DateTime.now(),
    );
  }

  /// Conversión del objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'ID': entregaId,
      'FECHAENTRAGA': DateFormat('yyyy-MM-dd').format(fechaEntrega),
      'CUPA': cupa,
      'CUE': cue,
      'RANGO_INICIAL': rangoInicial.toString(),
      'RANGO_FINAL': rangoFinal.toString(),
      'CANTIDAD': cantidad.toString(),
      'NOMBREPRODUCTOR': nombreProductor,
      'DESTABLECIMIENTO': establecimiento,
      'DIAS': dias.toString(),
      'NOMBREESTABLECIMIENTO': nombreEstablecimiento,
      'Latitud': latitud.toString(),
      'Longitud': longitud.toString(),
      'EXISTENCIA': existencia.toString(),
      'distanciaCalculada': distanciaCalculada,
      'ESTADO': estado,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}
