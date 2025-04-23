import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/data/models/razas/raza.dart';

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

  Bovino({
    required this.arete,
    required this.cue,
    required this.cupa,
    required this.edad,
    required this.sexo,
    required this.razaId,
    required this.traza,
    required this.estadoArete,
    required this.entregaId,
    this.fotoArete = '',
    this.areteMadre = '',
    this.aretePadre = '',
    this.regMadre = '',
    this.regPadre = '',
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
      razaId: razaId ?? this.razaId,
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
