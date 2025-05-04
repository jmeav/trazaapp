import 'package:hive/hive.dart';

@HiveType(typeId: 10)
class AltaEntrega {
  @HiveField(0)
  final String idAlta;

  @HiveField(1)
  final int rangoInicial;

  @HiveField(2)
  final int rangoFinal;

  @HiveField(3)
  final String cupa;

  @HiveField(4)
  final String cue;

  @HiveField(5)
  final String departamento;

  @HiveField(6)
  final String municipio;

  @HiveField(7)
  final double latitud;

  @HiveField(8)
  final double longitud;

  @HiveField(9)
  final String? distanciaCalculada;

  @HiveField(10)
  final DateTime fechaAlta;

  @HiveField(11)
  final String tipoAlta;

  @HiveField(12)
  final String token;

  @HiveField(13)
  final String codhabilitado;

  @HiveField(14)
  final String idorganizacion;

  @HiveField(15)
  final String fotoBovInicial;

  @HiveField(16)
  final String fotoBovFinal;

  @HiveField(17)
  final bool reposicion;

  @HiveField(18)
  final String observaciones;

  @HiveField(19)
  final List<BovinoResumen> detalleBovinos;

  @HiveField(20)
  final String estadoAlta; // Puede ser "Lista", "Enviada", etc.

  // ──────────────────────────────
  // NUEVO CAMPO
  // ──────────────────────────────
  @HiveField(21)
  final String fotoFicha; // PDF en base64
  // ──
  @HiveField(22) // ← siguiente campo libre
  final bool aplicaEntrega;
  
  // Campos para rangos mixtos
  @HiveField(23)
  final String rangoInicialExt;

  @HiveField(24)
  final String rangoFinalExt;

  @HiveField(25)
  final bool esRangoMixto;

  AltaEntrega({
    required this.idAlta,
    required this.rangoInicial,
    required this.rangoFinal,
    required this.cupa,
    required this.cue,
    required this.departamento,
    required this.municipio,
    required this.latitud,
    required this.longitud,
    this.distanciaCalculada,
    required this.fechaAlta,
    required this.tipoAlta,
    required this.token,
    required this.codhabilitado,
    required this.idorganizacion,
    required this.fotoBovInicial,
    required this.fotoBovFinal,
    required this.reposicion,
    required this.observaciones,
    required this.detalleBovinos,
    required this.estadoAlta,
    this.fotoFicha = '', // se inicializa vacío
    required this.aplicaEntrega,
    this.rangoInicialExt = '',
    this.rangoFinalExt = '',
    this.esRangoMixto = false,
  });

  AltaEntrega copyWith({
    String? idAlta,
    int? rangoInicial,
    int? rangoFinal,
    String? cupa,
    String? cue,
    String? departamento,
    String? municipio,
    double? latitud,
    double? longitud,
    String? distanciaCalculada,
    DateTime? fechaAlta,
    String? tipoAlta,
    String? token,
    String? codhabilitado,
    String? idorganizacion,
    String? fotoBovInicial,
    String? fotoBovFinal,
    bool? reposicion,
    String? observaciones,
    List<BovinoResumen>? detalleBovinos,
    String? estadoAlta,
    String? fotoFicha,
    bool? aplicaEntrega,
    String? rangoInicialExt,
    String? rangoFinalExt,
    bool? esRangoMixto,
  }) {
    return AltaEntrega(
      idAlta: idAlta ?? this.idAlta,
      rangoInicial: rangoInicial ?? this.rangoInicial,
      rangoFinal: rangoFinal ?? this.rangoFinal,
      cupa: cupa ?? this.cupa,
      cue: cue ?? this.cue,
      departamento: departamento ?? this.departamento,
      municipio: municipio ?? this.municipio,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      distanciaCalculada: distanciaCalculada ?? this.distanciaCalculada,
      fechaAlta: fechaAlta ?? this.fechaAlta,
      tipoAlta: tipoAlta ?? this.tipoAlta,
      token: token ?? this.token,
      codhabilitado: codhabilitado ?? this.codhabilitado,
      idorganizacion: idorganizacion ?? this.idorganizacion,
      fotoBovInicial: fotoBovInicial ?? this.fotoBovInicial,
      fotoBovFinal: fotoBovFinal ?? this.fotoBovFinal,
      reposicion: reposicion ?? this.reposicion,
      observaciones: observaciones ?? this.observaciones,
      detalleBovinos: detalleBovinos ?? this.detalleBovinos,
      estadoAlta: estadoAlta ?? this.estadoAlta,
      fotoFicha: fotoFicha ?? this.fotoFicha,
      aplicaEntrega: aplicaEntrega ?? this.aplicaEntrega,
      rangoInicialExt: rangoInicialExt ?? this.rangoInicialExt,
      rangoFinalExt: rangoFinalExt ?? this.rangoFinalExt,
      esRangoMixto: esRangoMixto ?? this.esRangoMixto,
    );
  }

  Map<String, dynamic> toJsonEnvio() {
    // Función auxiliar para quitar el prefijo '558' y ceros a la izquierda
    String stripTag(int value) {
      var s = value.toString();
      if (s.startsWith('558')) {
        s = s.substring(3);
      }
      s = s.replaceFirst(RegExp(r'^0+'), '');
      return s.isEmpty ? '0' : s;
    }
    
    // Procesar rango principal
    final riShort = int.tryParse(stripTag(rangoInicial)) ?? rangoInicial;
    final rfShort = int.tryParse(stripTag(rangoFinal)) ?? rangoFinal;
    
    // Procesar rangos extendidos si existen
    final String riExtShort = rangoInicialExt.isEmpty ? '' : 
      stripTag(int.tryParse(rangoInicialExt) ?? 0);
    final String rfExtShort = rangoFinalExt.isEmpty ? '' : 
      stripTag(int.tryParse(rangoFinalExt) ?? 0);
    
    return {
      "idAlta": idAlta,
      "rangoInicial": riShort,
      "rangoFinal": rfShort,
      "rangoInicialExt": int.tryParse(riExtShort) ?? 0,
      "rangoFinalExt": int.tryParse(rfExtShort) ?? 0,
      "cupa": cupa,
      "cue": cue,
      "departamento": departamento,
      "municipio": municipio,
      "latitud": latitud,
      "longitud": longitud,
      "distanciaCalculada": distanciaCalculada,
      "fechaAlta": fechaAlta.toUtc().toIso8601String(),
      "tipoAlta": tipoAlta,
      "token": token,
      "codhabilitado": codhabilitado,
      "idorganizacion": int.tryParse(idorganizacion) ?? 0,
      "fotoBovInicial": fotoBovInicial,
      "fotoBovFinal": fotoBovFinal,
      "fotoFicha": fotoFicha, 
      "reposicion": reposicion,
      "observaciones": observaciones,
      "aplicaentrega": aplicaEntrega,
      "detalleBovinos": detalleBovinos.map((b) => b.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 11)
class BovinoResumen {
  @HiveField(0)
  final String arete;

  @HiveField(1)
  final int edad;

  @HiveField(2)
  final String sexo;

  @HiveField(3)
  final String raza;

  @HiveField(4)
  final String traza;

  @HiveField(5)
  final String estadoArete;

  @HiveField(6)
  final DateTime fechaNacimiento;

  // ──────────────────────────────
  // NUEVOS CAMPOS
  // ──────────────────────────────
  @HiveField(7)
  final String fotoArete;

  @HiveField(8)
  final String areteMadre;

  @HiveField(9)
  final String aretePadre;

  @HiveField(10)
  final String regMadre;

  @HiveField(11)
  final String regPadre;

  @HiveField(12)
  final String motivoEstadoAreteId; 

  // ──────────────────────────────

  BovinoResumen({
    required this.arete,
    required this.edad,
    required this.sexo,
    required this.raza,
    required this.traza,
    required this.estadoArete,
    required this.fechaNacimiento,
    this.fotoArete = '',
    this.areteMadre = '',
    this.aretePadre = '',
    this.regMadre = '',
    this.regPadre = '',
    this.motivoEstadoAreteId = '0',
  });

  Map<String, dynamic> toJson() => {
        "arete": arete,
        "edad": edad,
        "sexo": sexo,
        "raza": raza,
        "traza": traza,
        "estadoArete": estadoArete,
        "fechaNacimiento": fechaNacimiento.toIso8601String(),
        "fotoArete": fotoArete,
        "areteMadre": areteMadre,
        "aretePadre": aretePadre,
        "regMadre": regMadre,
        "regPadre": regPadre,
        "motivoEstadoAreteId": motivoEstadoAreteId,
      };
}
