import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/data/local/models/razas/raza.dart';

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

  // Almacena únicamente el ID de la raza
  @HiveField(5)
  String razaId;

  @HiveField(6)
  String traza;

  @HiveField(7)
  String estadoArete;

  @HiveField(8)
  String entregaId;

  // Foto del arete cuando estadoArete != "Bueno"
  @HiveField(9)
  String fotoArete;

  // Datos genealógicos cuando traza == "PURO"
  @HiveField(10)
  String areteMadre;

  @HiveField(11)
  String aretePadre;

  @HiveField(12)
  String regMadre;

  @HiveField(13)
  String regPadre;
  
  // ID del motivo de estado del arete (249 si está dañado, 0 si está bueno)
  @HiveField(14)
  String motivoEstadoAreteId;

  Bovino({
    required this.arete,
    required this.cue,
    required this.cupa,
    required this.edad,
    required this.sexo,
    required this.razaId,
    required this.traza,
    required this.entregaId,
    required this.aretePadre,
    required this.areteMadre,
    required this.regPadre,
    required this.regMadre,
    this.estadoArete = 'Bueno',
    this.motivoEstadoAreteId = '0',
    this.fotoArete = '',
  });

  /// Getter para mostrar el nombre de la raza en la UI
  String get razaNombre {
    final listaRazas = Get.find<CatalogosController>().razas;
    final r = listaRazas.firstWhere(
      (x) => x.id == razaId,
      orElse: () => Raza(id: '', nombre: ''),
    );
    return r.nombre;
  }

  Bovino copyWith({
    String? arete,
    String? cue,
    String? cupa,
    int? edad,
    String? sexo,
    String? razaId,
    String? traza,
    String? entregaId,
    String? aretePadre,
    String? areteMadre,
    String? regPadre,
    String? regMadre,
    String? estadoArete,
    String? motivoEstadoAreteId,
    String? fotoArete,
  }) {
    return Bovino(
      arete: arete ?? this.arete,
      cue: cue ?? this.cue,
      cupa: cupa ?? this.cupa,
      edad: edad ?? this.edad,
      sexo: sexo ?? this.sexo,
      razaId: razaId ?? this.razaId,
      traza: traza ?? this.traza,
      entregaId: entregaId ?? this.entregaId,
      aretePadre: aretePadre ?? this.aretePadre,
      areteMadre: areteMadre ?? this.areteMadre,
      regPadre: regPadre ?? this.regPadre,
      regMadre: regMadre ?? this.regMadre,
      estadoArete: estadoArete ?? this.estadoArete,
      motivoEstadoAreteId: motivoEstadoAreteId ?? this.motivoEstadoAreteId,
      fotoArete: fotoArete ?? this.fotoArete,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arete': arete,
      'cue': cue,
      'cupa': cupa,
      'edad': edad,
      'sexo': sexo,
      'raza_id': razaId,
      'traza': traza,
      'entrega_id': entregaId,
      'arete_padre': aretePadre,
      'arete_madre': areteMadre,
      'reg_padre': regPadre,
      'reg_madre': regMadre,
      'estado_arete': estadoArete,
      'motivoEstadoAreteId': motivoEstadoAreteId,
      'foto_arete': fotoArete,
    };
  }

  factory Bovino.fromJson(Map<String, dynamic> json) {
    return Bovino(
      arete: json['arete'] ?? '',
      cue: json['cue'] ?? '',
      cupa: json['cupa'] ?? '',
      edad: json['edad'] ?? 0,
      sexo: json['sexo'] ?? '',
      razaId: json['raza_id'] ?? '',
      traza: json['traza'] ?? 'CRUCE',
      entregaId: json['entrega_id'] ?? '',
      aretePadre: json['arete_padre'] ?? '',
      areteMadre: json['arete_madre'] ?? '',
      regPadre: json['reg_padre'] ?? '',
      regMadre: json['reg_madre'] ?? '',
      estadoArete: json['estado_arete'] ?? 'Bueno',
      motivoEstadoAreteId: json['motivo_estado_arete_id'] ?? '0',
      fotoArete: json['foto_arete'] ?? '',
    );
  }
}
