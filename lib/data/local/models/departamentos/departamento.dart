import 'package:hive/hive.dart';

@HiveType(typeId: 7)
class Departamento {
  @HiveField(0)
  final String idDepartamento;

  @HiveField(1)
  final String departamento;

  @HiveField(2)
  DateTime? lastUpdate; // Campo para la última actualización

  Departamento({
    required this.idDepartamento,
    required this.departamento,
    this.lastUpdate,
  });

  factory Departamento.fromJson(Map<String, dynamic> json) {
    return Departamento(
      idDepartamento: json['IDDEPARTAMENTO'] ?? '',
      departamento: json['DEPARTAMENTO'] ?? '',
      lastUpdate: json['LAST_UPDATE'] != null
          ? DateTime.tryParse(json['LAST_UPDATE'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDDEPARTAMENTO': idDepartamento,
      'DEPARTAMENTO': departamento,
      'LAST_UPDATE': lastUpdate?.toIso8601String(),
    };
  }
}
