import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/data/models/razas/raza.dart';

@HiveType(typeId: 14)
class BovinoRepo {
  @HiveField(0)
  final String arete;

  @HiveField(1)
  final int edad;

  @HiveField(2)
  final String sexo;

  // Almacena únicamente el ID de la raza
  @HiveField(3)
  String razaId;

  @HiveField(4)
  final String traza;

  @HiveField(5)
  final String estadoArete;

  @HiveField(15)
  final String motivoEstadoAreteId;

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

  BovinoRepo({
    required this.arete,
    required this.edad,
    required this.sexo,
    required this.razaId,
    required this.traza,
    required this.estadoArete,
    this.motivoEstadoAreteId = "0",
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

  /// Getter que usa tu lógica actual para identificar la entidad
  String get id => arete;

  /// Getter para mostrar el nombre de la raza en UI
  String get razaNombre {
    final lista = Get.find<CatalogosController>().razas;
    final r = lista.firstWhere(
      (x) => x.id == razaId,
      orElse: () => Raza(id: '', nombre: ''),
    );
    return r.nombre;
  }

  BovinoRepo copyWith({
    String? arete,
    int? edad,
    String? sexo,
    String? razaId,
    String? traza,
    String? estadoArete,
    String? motivoEstadoAreteId,
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
      razaId: razaId ?? this.razaId,
      traza: traza ?? this.traza,
      estadoArete: estadoArete ?? this.estadoArete,
      motivoEstadoAreteId: motivoEstadoAreteId ?? this.motivoEstadoAreteId,
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
        "areteAnterior": areteAnterior,
        "edad": edad,
        "sexo": sexo,
        "raza": razaId,
        "traza": traza,
        "estadoArete": estadoArete,
        "motivoEstadoAreteId": motivoEstadoAreteId,
        "fechaNacimiento": fechaNacimiento.toIso8601String(),
        "fotoArete": fotoArete,
        "areteMadre": areteMadre,
        "aretePadre": aretePadre,
        "regMadre": regMadre,
        "regPadre": regPadre,
      };
}
