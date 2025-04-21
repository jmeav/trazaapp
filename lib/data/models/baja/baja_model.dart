import 'package:hive/hive.dart';

@HiveType(typeId: 15)
class Baja {
  @HiveField(0)
  final String bajaId; // Formato: "ABJSO" + número

  @HiveField(1)
  final String arete;

  @HiveField(2)
  final String motivo;

  @HiveField(3)
  final String cue;

  @HiveField(4)
  final String cupa;

  @HiveField(5)
  final DateTime fechaRegistro;

  @HiveField(6)
  final DateTime fechaBaja;

  @HiveField(7)
  final String evidencia;

  @HiveField(8)
  final String tipoEvidencia; // 'foto' o 'pdf'

  @HiveField(9)
  final String estado; // 'pendiente', 'enviado', 'error'

  @HiveField(10)
  final String token; // IMEI del dispositivo

  @HiveField(11)
  final String codHabilitado; // Código del habilitado

  Baja({
    required this.bajaId,
    required this.arete,
    required this.motivo,
    required this.cue,
    required this.cupa,
    required this.fechaRegistro,
    required this.fechaBaja,
    required this.evidencia,
    required this.tipoEvidencia,
    this.estado = 'pendiente',
    required this.token,
    required this.codHabilitado,
  });

  // Método copyWith para crear una copia modificada del objeto
  Baja copyWith({
    String? bajaId,
    String? arete,
    String? motivo,
    String? cue,
    String? cupa,
    DateTime? fechaRegistro,
    DateTime? fechaBaja,
    String? evidencia,
    String? tipoEvidencia,
    String? estado,
    String? token,
    String? codHabilitado,
  }) {
    return Baja(
      bajaId: bajaId ?? this.bajaId,
      arete: arete ?? this.arete,
      motivo: motivo ?? this.motivo,
      cue: cue ?? this.cue,
      cupa: cupa ?? this.cupa,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      fechaBaja: fechaBaja ?? this.fechaBaja,
      evidencia: evidencia ?? this.evidencia,
      tipoEvidencia: tipoEvidencia ?? this.tipoEvidencia,
      estado: estado ?? this.estado,
      token: token ?? this.token,
      codHabilitado: codHabilitado ?? this.codHabilitado,
    );
  }

  // Constructor factory para crear un objeto Baja a partir de un JSON
  factory Baja.fromJson(Map<String, dynamic> json) {
    return Baja(
      bajaId: json['BAJA_ID'] ?? '',
      arete: json['ARETE'] ?? '',
      motivo: json['MOTIVO'] ?? '',
      cue: json['CUE'] ?? '',
      cupa: json['CUPA'] ?? '',
      fechaRegistro: DateTime.parse(json['FECHA_REGISTRO'] ?? DateTime.now().toIso8601String()),
      fechaBaja: DateTime.parse(json['FECBAJA'] ?? DateTime.now().toIso8601String()),
      evidencia: json['EVIDENCIA'] ?? '',
      tipoEvidencia: json['TIPO_EVIDENCIA'] ?? '',
      estado: json['ESTADO'] ?? 'pendiente',
      token: json['TOKEN'] ?? '',
      codHabilitado: json['COD_HABILITADO'] ?? '',
    );
  }

  // Conversión a JSON
  Map<String, dynamic> toJson() {
    return {
      'BAJA_ID': bajaId,
      'ARETE': arete,
      'MOTIVO': motivo,
      'CUE': cue,
      'CUPA': cupa,
      'FECHA_REGISTRO': fechaRegistro.toIso8601String(),
      'FECBAJA': fechaBaja.toIso8601String(),
      'EVIDENCIA': evidencia,
      'TIPO_EVIDENCIA': tipoEvidencia,
      'ESTADO': estado,
      'TOKEN': token,
      'COD_HABILITADO': codHabilitado,
    };
  }
} 