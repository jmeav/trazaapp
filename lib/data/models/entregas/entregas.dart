import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:trazaapp/data/models/departamentos/departamento.dart';
import 'package:trazaapp/data/models/municipios/municipio.dart';

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
  final DateTime lastUpdate;

  @HiveField(17)
  final String tipo;

  @HiveField(18)
  final String fotoBovInicial;

  @HiveField(19)
  final String fotoBovFinal;

  @HiveField(20)
  final bool reposicion;

  @HiveField(21)
  final String observaciones;

  @HiveField(22)
  final String? idAlta;

  // 🔹 Campos nuevos
  @HiveField(23)
  final String departamento;

  @HiveField(24)
  final String municipio;

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
    this.tipo = 'sistema',
    required this.fotoBovInicial,
    required this.fotoBovFinal,
    required this.reposicion,
    required this.observaciones,
    this.idAlta,
    required this.departamento,
    required this.municipio,
  });

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
    String? fotoBovInicial,
    String? fotoBovFinal,
    bool? reposicion,
    String? observaciones,
    String? idAlta,
    String? departamento,
    String? municipio,
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
      fotoBovInicial: fotoBovInicial ?? this.fotoBovInicial,
      fotoBovFinal: fotoBovFinal ?? this.fotoBovFinal,
      reposicion: reposicion ?? this.reposicion,
      observaciones: observaciones ?? this.observaciones,
      idAlta: idAlta ?? this.idAlta,
      departamento: departamento ?? this.departamento,
      municipio: municipio ?? this.municipio,
    );
  }

   factory Entregas.fromJson(Map<String, dynamic> json) {
    final tipoEntrega = json['tipo'] ?? 'sistema';

    String resolveDepartamento(String? idDept) {
      final dep = Hive.box<Departamento>('departamentos')
          .values
          .firstWhere((d) => d.idDepartamento == idDept, orElse: () => Departamento(idDepartamento: idDept ?? '', departamento: 'Desconocido'));
      return dep.departamento;
    }

    String resolveMunicipio(String? idMun) {
      final mun = Hive.box<Municipio>('municipios')
          .values
          .firstWhere((m) => m.idMunicipio == idMun, orElse: () => Municipio(idMunicipio: idMun ?? '', municipio: 'Desconocido', idDepartamento: ''));
      return mun.municipio;
    }

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
      tipo: tipoEntrega,
      fotoBovInicial: json['fotoBovInicial'] ?? '',
      fotoBovFinal: json['fotoBovFinal'] ?? '',
      reposicion: json['reposicion'] ?? false,
      observaciones: json['observaciones'] ?? '',
      idAlta: json['idAlta'],
      departamento: tipoEntrega == 'manual'
          ? (json['DEPARTAMENTO'] ?? 'Sin dept.')
          : resolveDepartamento(json['iddept']),
      municipio: tipoEntrega == 'manual'
          ? (json['MUNICIPIO'] ?? 'Sin mun.')
          : resolveMunicipio(json['idmun']),
    );
  }


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
      'tipo': tipo,
      'fotoBovInicial': fotoBovInicial,
      'fotoBovFinal': fotoBovFinal,
      'reposicion': reposicion,
      'observaciones': observaciones,
      'idAlta': idAlta,
      'DEPARTAMENTO': departamento,
      'MUNICIPIO': municipio,
    };
  }
}
