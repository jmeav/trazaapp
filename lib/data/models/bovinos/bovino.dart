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
  String traza;

  @HiveField(7)
  String estadoArete;

  @HiveField(8)
  String entregaId;

  // ──────────────────────────────
  // NUEVOS CAMPOS
  // ──────────────────────────────
  // Foto si estadoArete ≠ "Bueno"
  @HiveField(9)
  String fotoArete;

  // Datos genealógicos si traza = "PURO"
  @HiveField(10)
  String areteMadre;

  @HiveField(11)
  String aretePadre;

  @HiveField(12)
  String regMadre;

  @HiveField(13)
  String regPadre;
  // ──────────────────────────────

  Bovino({
    required this.arete,
    required this.cue,
    required this.cupa,
    required this.edad,
    required this.sexo,
    required this.raza,
    required this.traza,
    required this.estadoArete,
    required this.entregaId,
    this.fotoArete = '',
    this.areteMadre = '',
    this.aretePadre = '',
    this.regMadre = '',
    this.regPadre = '',
  });

  // ...
  // copyWith para incluir nuevos campos
  Bovino copyWith({
    String? arete,
    String? cue,
    String? cupa,
    int? edad,
    String? sexo,
    String? raza,
    String? traza,
    String? estadoArete,
    String? entregaId,
    String? fotoArete,
    String? areteMadre,
    String? aretePadre,
    String? regMadre,
    String? regPadre,
  }) {
    return Bovino(
      arete: arete ?? this.arete,
      cue: cue ?? this.cue,
      cupa: cupa ?? this.cupa,
      edad: edad ?? this.edad,
      sexo: sexo ?? this.sexo,
      raza: raza ?? this.raza,
      traza: traza ?? this.traza,
      estadoArete: estadoArete ?? this.estadoArete,
      entregaId: entregaId ?? this.entregaId,
      fotoArete: fotoArete ?? this.fotoArete,
      areteMadre: areteMadre ?? this.areteMadre,
      aretePadre: aretePadre ?? this.aretePadre,
      regMadre: regMadre ?? this.regMadre,
      regPadre: regPadre ?? this.regPadre,
    );
  }
}
