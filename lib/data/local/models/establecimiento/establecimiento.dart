import 'package:hive/hive.dart';

@HiveType(typeId: 4)
class Establecimiento {
  @HiveField(0)
  final String idEstablecimiento;

  @HiveField(1)
  final String establecimiento;

  @HiveField(2)
  final String nombreEstablecimiento;

  @HiveField(3)
  final String idDepartamento;

  @HiveField(4)
  final String idMunicipio;

  @HiveField(5)
  final String productor;

  @HiveField(6)
  final String latitud;

  @HiveField(7)
  final String longitud;

  @HiveField(8)
  DateTime? lastUpdate; // Campo para la última actualización

  Establecimiento({
    required this.idEstablecimiento,
    required this.establecimiento,
    required this.nombreEstablecimiento,
    required this.idDepartamento,
    required this.idMunicipio,
    required this.productor,
    required this.latitud,
    required this.longitud,
    this.lastUpdate,
  });

  factory Establecimiento.fromJson(Map<String, dynamic> json) {
    return Establecimiento(
      idEstablecimiento: json['IDESTABLECIMIENTO'] ?? '',
      establecimiento: json['ESTABLECIMIENTO'] ?? '',
      nombreEstablecimiento: json['NOMBREESTABLECIMIENTO'] ?? '',
      idDepartamento: json['IDDEPARTAMENTO'] ?? '',
      idMunicipio: json['IDMUNICIPIO'] ?? '',
      productor: json['PRODUCTOR'] ?? '',
      latitud: json['Latitud']?.toString() ?? '0.0',  // Convertir a String directamente
      longitud: json['Longitud']?.toString() ?? '0.0', // Convertir a String directamente
      lastUpdate: json['LAST_UPDATE'] != null
          ? DateTime.tryParse(json['LAST_UPDATE'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDESTABLECIMIENTO': idEstablecimiento,
      'ESTABLECIMIENTO': establecimiento,
      'NOMBREESTABLECIMIENTO': nombreEstablecimiento,
      'IDDEPARTAMENTO': idDepartamento,
      'IDMUNICIPIO': idMunicipio,
      'PRODUCTOR': productor,
      'Latitud': latitud,
      'Longitud': longitud,
      'LAST_UPDATE': lastUpdate?.toIso8601String(),
    };
  }
}
