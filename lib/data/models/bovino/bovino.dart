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
  int edad;

  @HiveField(4)
  String sexo;

  @HiveField(5)
  String raza;

  @HiveField(6)
  String estadoArete;

  Bovino({
    required this.arete,
    required this.cue,
    required this.cupa,
    required this.edad,
    required this.sexo,
    required this.raza,
    required this.estadoArete,
  });

  // Método copyWith
  Bovino copyWith({
    String? arete,
    String? cue,
    String? cupa,
    int? edad,
    String? sexo,
    String? raza,
    String? estadoArete,
  }) {
    return Bovino(
      arete: arete ?? this.arete,
      cue: cue ?? this.cue,
      cupa: cupa ?? this.cupa,
      edad: edad ?? this.edad,
      sexo: sexo ?? this.sexo,
      raza: raza ?? this.raza,
      estadoArete: estadoArete ?? this.estadoArete,
    );
  }
}
