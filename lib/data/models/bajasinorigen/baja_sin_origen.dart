import 'package:hive/hive.dart';

@HiveType(typeId: 19)
class BajaSinOrigen {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String arete;

  @HiveField(2)
  final double latitud;

  @HiveField(3)
  final double longitud;

  @HiveField(4)
  final DateTime fecha;

  @HiveField(5)
  final String motivo;

  @HiveField(6)
  final String evidencia;

  @HiveField(7)
  final String estado;

  @HiveField(8)
  final String token;

  @HiveField(9)
  final String codHabilitado;

  @HiveField(10)
  bool enviado;

  @HiveField(11)
  final String? observaciones;

  BajaSinOrigen({
    required this.id,
    required this.arete,
    required this.latitud,
    required this.longitud,
    required this.fecha,
    required this.motivo,
    required this.evidencia,
    required this.estado,
    required this.token,
    required this.codHabilitado,
    this.enviado = false,
    this.observaciones,
  });

  BajaSinOrigen copyWith({
    String? id,
    String? arete,
    double? latitud,
    double? longitud,
    DateTime? fecha,
    String? motivo,
    String? evidencia,
    String? estado,
    String? token,
    String? codHabilitado,
    bool? enviado,
    String? observaciones,
  }) {
    return BajaSinOrigen(
      id: id ?? this.id,
      arete: arete ?? this.arete,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      fecha: fecha ?? this.fecha,
      motivo: motivo ?? this.motivo,
      evidencia: evidencia ?? this.evidencia,
      estado: estado ?? this.estado,
      token: token ?? this.token,
      codHabilitado: codHabilitado ?? this.codHabilitado,
      enviado: enviado ?? this.enviado,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  factory BajaSinOrigen.fromJson(Map<String, dynamic> json) {
    return BajaSinOrigen(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      arete: json['arete'] ?? '',
      latitud: double.tryParse(json['latitud']?.toString() ?? '0.0') ?? 0.0,
      longitud: double.tryParse(json['longitud']?.toString() ?? '0.0') ?? 0.0,
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      motivo: json['motivo'] ?? 'sin origen',
      evidencia: json['evidencia'] ?? '',
      estado: json['estado'] ?? 'pendiente',
      token: json['token'] ?? '',
      codHabilitado: json['codHabilitado'] ?? '',
      enviado: json['enviado'] ?? false,
      observaciones: json['observaciones'],
    );
  }

  Map<String, dynamic> toJsonEnvio() {
    return {
      'id': id,
      'arete': _formatearArete(arete),
      'latitud': latitud,
      'longitud': longitud,
      'fecha': fecha.toUtc().toIso8601String(),
      'motivo': motivo.toLowerCase(),
      'evidencia': evidencia,
      'token': token,
      'codHabilitado': codHabilitado,
    };
  }

  String _formatearArete(String arete) {
    String base = arete;
    if (base.startsWith('558')) {
      return base.padLeft(12, '0');
    } else {
      String sinPrefijo = base.padLeft(9, '0');
      return '558$sinPrefijo';
    }
  }
} 