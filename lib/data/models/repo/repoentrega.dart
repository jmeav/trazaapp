import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/repo/bovinorepo.dart';

@HiveType(typeId: 13)
class RepoEntrega {
  @HiveField(0)
  final String idRepo;

  @HiveField(1)
  final String entregaIdOrigen;

  @HiveField(2)
  final String cupa;

  @HiveField(3)
  final String cue;

  @HiveField(4)
  final String departamento;

  @HiveField(5)
  final String municipio;

  @HiveField(6)
  final double latitud;

  @HiveField(7)
  final double longitud;

  @HiveField(8)
  final String? distanciaCalculada;

  @HiveField(9)
  final DateTime fechaRepo;

  @HiveField(10)
  final String token;

  @HiveField(11)
  final String pdfEvidencia;

  @HiveField(12)
  final String observaciones;

  @HiveField(13)
  final List<BovinoRepo> detalleBovinos;

  @HiveField(14)
  final String estadoRepo;

  @HiveField(15)
  final String fotoBovInicial;

  @HiveField(16)
  final String fotoBovFinal;

  @HiveField(17)
  final String fotoFicha;

  @HiveField(18)
  final String codhabilitado;

  @HiveField(19)
  final String idorganizacion;

  @HiveField(20)
  final int rangoInicialRepo;

  @HiveField(21)
  final int rangoFinalRepo;

  int get cantidad => rangoFinalRepo - rangoInicialRepo + 1;

  RepoEntrega({
    required this.idRepo,
    required this.entregaIdOrigen,
    required this.cupa,
    required this.cue,
    required this.departamento,
    required this.municipio,
    required this.latitud,
    required this.longitud,
    this.distanciaCalculada,
    required this.fechaRepo,
    required this.token,
    required this.pdfEvidencia,
    required this.observaciones,
    required this.detalleBovinos,
    required this.estadoRepo,
    required this.fotoBovInicial,
    required this.fotoBovFinal,
    required this.fotoFicha,
    required this.codhabilitado,
    required this.idorganizacion,
    required this.rangoInicialRepo,
    required this.rangoFinalRepo,
  });

  RepoEntrega copyWith({
    String? idRepo,
    String? entregaIdOrigen,
    String? cupa,
    String? cue,
    String? departamento,
    String? municipio,
    double? latitud,
    double? longitud,
    String? distanciaCalculada,
    DateTime? fechaRepo,
    String? token,
    String? pdfEvidencia,
    String? observaciones,
    List<BovinoRepo>? detalleBovinos,
    String? estadoRepo,
    String? fotoBovInicial,
    String? fotoBovFinal,
    String? fotoFicha,
    String? codhabilitado,
    String? idorganizacion,
    int? rangoInicialRepo,
    int? rangoFinalRepo,
  }) {
    return RepoEntrega(
      idRepo: idRepo ?? this.idRepo,
      entregaIdOrigen: entregaIdOrigen ?? this.entregaIdOrigen,
      cupa: cupa ?? this.cupa,
      cue: cue ?? this.cue,
      departamento: departamento ?? this.departamento,
      municipio: municipio ?? this.municipio,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      distanciaCalculada: distanciaCalculada ?? this.distanciaCalculada,
      fechaRepo: fechaRepo ?? this.fechaRepo,
      token: token ?? this.token,
      pdfEvidencia: pdfEvidencia ?? this.pdfEvidencia,
      observaciones: observaciones ?? this.observaciones,
      detalleBovinos: detalleBovinos ?? this.detalleBovinos,
      estadoRepo: estadoRepo ?? this.estadoRepo,
      fotoBovInicial: fotoBovInicial ?? this.fotoBovInicial,
      fotoBovFinal: fotoBovFinal ?? this.fotoBovFinal,
      fotoFicha: fotoFicha ?? this.fotoFicha,
      codhabilitado: codhabilitado ?? this.codhabilitado,
      idorganizacion: idorganizacion ?? this.idorganizacion,
      rangoInicialRepo: rangoInicialRepo ?? this.rangoInicialRepo,
      rangoFinalRepo: rangoFinalRepo ?? this.rangoFinalRepo,
    );
  }


  Map<String, dynamic> toJsonEnvio() => {
    "idRepo": idRepo,
    "entregaIdOrigen": entregaIdOrigen,
    "cupa": cupa,
    "cue": cue,
    "departamento": departamento,
    "municipio": municipio,
    "latitud": latitud,
    "longitud": longitud,
    "distanciaCalculada": distanciaCalculada,
    "fechaRepo": fechaRepo.toUtc().toIso8601String(),
    "token": token,
    "pdfEvidencia": pdfEvidencia,
    "observaciones": observaciones,
    "estadoRepo": estadoRepo,
    "fotoBovInicial": fotoBovInicial,
    "fotoBovFinal": fotoBovFinal,
    "fotoFicha": fotoFicha,
    "codhabilitado": codhabilitado,
    "idorganizacion": int.tryParse(idorganizacion) ?? 0,
    "rangoInicialRepo": rangoInicialRepo,
    "rangoFinalRepo": rangoFinalRepo,
    "detalleBovinos": detalleBovinos.map((b) => b.toJson()).toList(),
  };
} 