import 'package:hive/hive.dart';

@HiveType(typeId: 10)
class AltaEntrega {
  @HiveField(0)
  final String idAlta;

  @HiveField(1)
  final int rangoInicial;

  @HiveField(2)
  final int rangoFinal;

  @HiveField(3)
  final String cupa;

  @HiveField(4)
  final String cue;

  @HiveField(5)
  final String departamento; // Campo agregado

  @HiveField(6)
  final String municipio; // Campo agregado

  @HiveField(7)
  final double latitud;

  @HiveField(8)
  final double longitud;

  @HiveField(9)
  final String? distanciaCalculada;

  @HiveField(10)
  final DateTime fechaAlta;

  @HiveField(11)
  final String tipoAlta;

  @HiveField(12)
  final List<BovinoResumen> detalleBovinos;

  AltaEntrega({
    required this.idAlta,
    required this.rangoInicial,
    required this.rangoFinal,
    required this.cupa,
    required this.cue,
    required this.departamento,
    required this.municipio,
    required this.latitud,
    required this.longitud,
    this.distanciaCalculada,
    required this.fechaAlta,
    required this.tipoAlta,
    required this.detalleBovinos,
  });

  AltaEntrega copyWith({
    String? idAlta,
    int? rangoInicial,
    int? rangoFinal,
    String? cupa,
    String? cue,
    String? departamento,
    String? municipio,
    double? latitud,
    double? longitud,
    String? distanciaCalculada,
    DateTime? fechaAlta,
    String? tipoAlta,
    List<BovinoResumen>? detalleBovinos,
  }) {
    return AltaEntrega(
      idAlta: idAlta ?? this.idAlta,
      rangoInicial: rangoInicial ?? this.rangoInicial,
      rangoFinal: rangoFinal ?? this.rangoFinal,
      cupa: cupa ?? this.cupa,
      cue: cue ?? this.cue,
      departamento: departamento ?? this.departamento,
      municipio: municipio ?? this.municipio,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      distanciaCalculada: distanciaCalculada ?? this.distanciaCalculada,
      fechaAlta: fechaAlta ?? this.fechaAlta,
      tipoAlta: tipoAlta ?? this.tipoAlta,
      detalleBovinos: detalleBovinos ?? this.detalleBovinos,
    );
  }
}


@HiveType(typeId: 11)
class BovinoResumen {
  @HiveField(0)
  final String arete;

  @HiveField(1)
  final int edad; // En meses

  @HiveField(2)
  final String sexo;

  @HiveField(3)
  final String raza;

  @HiveField(4)
  final String traza; // Nuevo campo

  @HiveField(5)
  final String estadoArete;

  @HiveField(6)
  final DateTime fechaNacimiento; // Ahora es un campo explícito en Hive

  BovinoResumen({
    required this.arete,
    required this.edad,
    required this.sexo,
    required this.raza,
    required this.traza,
    required this.estadoArete,
    required this.fechaNacimiento, // Se pasa explícitamente
  });

  // Getter opcional para calcular la fecha de nacimiento si es necesario en otros lugares
  DateTime get calcularFechaNacimiento {
    return DateTime.now().subtract(Duration(days: edad * 30)); // Aproximación de un mes a 30 días
  }

  BovinoResumen copyWith({
    String? arete,
    int? edad,
    String? sexo,
    String? raza,
    String? traza,
    String? estadoArete,
    DateTime? fechaNacimiento,
  }) {
    return BovinoResumen(
      arete: arete ?? this.arete,
      edad: edad ?? this.edad,
      sexo: sexo ?? this.sexo,
      raza: raza ?? this.raza,
      traza: traza ?? this.traza,
      estadoArete: estadoArete ?? this.estadoArete,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento, // Se incluye en `copyWith`
    );
  }

  Map<String, dynamic> toJson() => {
        "arete": arete,
        "edad": edad,
        "sexo": sexo,
        "raza": raza,
        "traza": traza,
        "estadoArete": estadoArete,
        "fechaNacimiento": fechaNacimiento.toIso8601String(), // Se envía en el JSON
      };
}
