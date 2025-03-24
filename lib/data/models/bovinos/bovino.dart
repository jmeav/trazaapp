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

  @HiveField(8) // Nuevo campo agregado
  String entregaId; // Identifica a qué entrega pertenece el bovino

  Bovino({
    required this.arete,
    required this.cue,
    required this.cupa,
    required this.edad,
    required this.sexo,
    required this.raza,
    required this.traza,
    required this.estadoArete,
    required this.entregaId, // Ahora cada bovino tiene un `entregaId`
  });

  // Getter para calcular la fecha de nacimiento dinámicamente
  DateTime get fechaNacimiento {
    return DateTime.now().subtract(Duration(days: edad * 30));
  }

  // Método copyWith para permitir copias con cambios
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
    );
  }
}
