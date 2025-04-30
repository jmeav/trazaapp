import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/baja/arete_baja.dart';

@HiveType(typeId: 15)
class Baja {
  @HiveField(0)
  final String bajaId; // Formato: "ABJSO" + número

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

  @HiveField(12)
  final List<AreteBaja> detalleAretes; // Nueva lista de aretes para baja

  // Getter para cantidad de aretes
  int get cantidad => detalleAretes.length;

  Baja({
    required this.bajaId,
    required this.cue,
    required this.cupa,
    required this.fechaRegistro,
    required this.fechaBaja,
    required this.evidencia,
    required this.tipoEvidencia,
    this.estado = 'pendiente',
    required this.token,
    required this.codHabilitado,
    required this.detalleAretes,
  });

  // Método copyWith para crear una copia modificada del objeto
  Baja copyWith({
    String? bajaId,
    String? cue,
    String? cupa,
    DateTime? fechaRegistro,
    DateTime? fechaBaja,
    String? evidencia,
    String? tipoEvidencia,
    String? estado,
    String? token,
    String? codHabilitado,
    List<AreteBaja>? detalleAretes,
  }) {
    return Baja(
      bajaId: bajaId ?? this.bajaId,
      cue: cue ?? this.cue,
      cupa: cupa ?? this.cupa,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      fechaBaja: fechaBaja ?? this.fechaBaja,
      evidencia: evidencia ?? this.evidencia,
      tipoEvidencia: tipoEvidencia ?? this.tipoEvidencia,
      estado: estado ?? this.estado,
      token: token ?? this.token,
      codHabilitado: codHabilitado ?? this.codHabilitado,
      detalleAretes: detalleAretes ?? this.detalleAretes,
    );
  }

  // Constructor factory para crear un objeto Baja a partir de un JSON
  factory Baja.fromJson(Map<String, dynamic> json) {
    List<dynamic> detalleJson = json['DETALLE_ARETES'] ?? [];
    List<AreteBaja> detalles = detalleJson.map((item) => AreteBaja.fromJson(item)).toList();

    return Baja(
      bajaId: json['BAJA_ID'] ?? '',
      cue: json['CUE'] ?? '',
      cupa: json['CUPA'] ?? '',
      fechaRegistro: DateTime.parse(json['FECHA_REGISTRO'] ?? DateTime.now().toIso8601String()),
      fechaBaja: DateTime.parse(json['FECBAJA'] ?? DateTime.now().toIso8601String()),
      evidencia: json['EVIDENCIA'] ?? '',
      tipoEvidencia: json['TIPO_EVIDENCIA'] ?? '',
      estado: json['ESTADO'] ?? 'pendiente',
      token: json['TOKEN'] ?? '',
      codHabilitado: json['COD_HABILITADO'] ?? '',
      detalleAretes: detalles,
    );
  }

  // Conversión a JSON para envío al servidor
  Map<String, dynamic> toJsonEnvio() {
    return {
      'idBaja': bajaId,
      'cue': cue,
      'cupa': cupa,
      'fecharegistro': fechaRegistro.toUtc().toIso8601String(),
      'fechabaja': fechaBaja.toUtc().toIso8601String(), // Manteniendo fec_baja si es el nombre esperado por el servidor
      'evidencia': evidencia,
      'token': token,
      'codhabilitado': codHabilitado,
      'detallearetes': detalleAretes.map((a) => a.toJson()).toList(), // Usa el toJson() actualizado de AreteBaja
    };
  }
} 