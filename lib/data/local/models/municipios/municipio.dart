import 'package:hive/hive.dart';

@HiveType(typeId: 8)
class Municipio {
  @HiveField(0)
  final String idMunicipio;

  @HiveField(1)
  final String municipio;

  @HiveField(2)
  final String idDepartamento;

  @HiveField(3)
  DateTime? lastUpdate; // Campo para la última actualización

  Municipio({
    required this.idMunicipio,
    required this.municipio,
    required this.idDepartamento,
    this.lastUpdate,
  });

  factory Municipio.fromJson(Map<String, dynamic> json) {
    return Municipio(
      idMunicipio: json['IDMUNICIPIO'] ?? '',
      municipio: json['MUNICIPIO'] ?? '',
      idDepartamento: json['IDDEPARTAMENTO'] ?? '',
      lastUpdate: json['LAST_UPDATE'] != null
          ? DateTime.tryParse(json['LAST_UPDATE'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDMUNICIPIO': idMunicipio,
      'MUNICIPIO': municipio,
      'IDDEPARTAMENTO': idDepartamento,
      'LAST_UPDATE': lastUpdate?.toIso8601String(),
    };
  }
}
