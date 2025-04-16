import 'package:hive/hive.dart';

@HiveType(typeId: 14)
class BovinoRepo {
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
  final String repoEntregaId;

  @HiveField(13)
  final String areteAnterior;

  @HiveField(14)
  final String repoId;

  String get id => arete;

  BovinoRepo({
    required this.arete,
    required this.edad,
    required this.sexo,
    required this.raza,
    required this.traza,
    required this.estadoArete,
    required this.fechaNacimiento,
    required this.areteAnterior,
    this.fotoArete = '',
    this.areteMadre = '',
    this.aretePadre = '',
    this.regMadre = '',
    this.regPadre = '',
    required this.repoEntregaId,
    required this.repoId,
  });

  BovinoRepo copyWith({
    String? arete,
    int? edad,
    String? sexo,
    String? raza,
    String? traza,
    String? estadoArete,
    DateTime? fechaNacimiento,
    String? fotoArete,
    String? areteMadre,
    String? aretePadre,
    String? regMadre,
    String? regPadre,
    String? repoEntregaId,
    String? areteAnterior,
    String? repoId,
  }) {
    return BovinoRepo(
      arete: arete ?? this.arete,
      edad: edad ?? this.edad,
      sexo: sexo ?? this.sexo,
      raza: raza ?? this.raza,
      traza: traza ?? this.traza,
      estadoArete: estadoArete ?? this.estadoArete,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      fotoArete: fotoArete ?? this.fotoArete,
      areteMadre: areteMadre ?? this.areteMadre,
      aretePadre: aretePadre ?? this.aretePadre,
      regMadre: regMadre ?? this.regMadre,
      regPadre: regPadre ?? this.regPadre,
      repoEntregaId: repoEntregaId ?? this.repoEntregaId,
      areteAnterior: areteAnterior ?? this.areteAnterior,
      repoId: repoId ?? this.repoId,
    );
  }

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
        "repoEntregaId": repoEntregaId,
        "areteAnterior": areteAnterior,
        "repoId": repoId,
      };
} 