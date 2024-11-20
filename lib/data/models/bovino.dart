import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class Bovino {
  @HiveField(0)
  final String arete;

  @HiveField(1)
  final String cue;

  @HiveField(2)
  final String cupa;

  @HiveField(3)
  final int edad;

  @HiveField(4)
  final String sexo;

  @HiveField(5)
  final String raza;

  @HiveField(6)
  final String estadoArete;

  Bovino({
    required this.arete,
    required this.cue,
    required this.cupa,
    required this.edad,
    required this.sexo,
    required this.raza,
    required this.estadoArete,
  });

  factory Bovino.fromJson(Map<String, dynamic> json) {
    return Bovino(
      arete: json['arete'] ?? '',
      cue: json['cue'] ?? '',
      cupa: json['cupa'] ?? '',
      edad: json['edad'] ?? 0,
      sexo: json['sexo'] ?? '',
      raza: json['raza'] ?? '',
      estadoArete: json['estadoArete'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arete': arete,
      'cue': cue,
      'cupa': cupa,
      'edad': edad,
      'sexo': sexo,
      'raza': raza,
      'estadoArete': estadoArete,
    };
  }
}
