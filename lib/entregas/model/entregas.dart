class Entrega {
  final String cue;
  final String fechaEntrega;
  final String estado;
  final int cantidad;
  final String rango;
  late final String distancia;
  final Coordenadas coordenadas;
  final String distanciaCalculada; // Nueva propiedad

  Entrega({
    required this.cue,
    required this.fechaEntrega,
    required this.estado,
    required this.cantidad,
    required this.rango,
    required this.distancia,
    required this.coordenadas,
    this.distanciaCalculada = '', // Inicializada como una cadena vacía
  });

  factory Entrega.fromJson(Map<String, dynamic> json) {
    return Entrega(
      cue: json['cue'],
      fechaEntrega: json['fechaEntrega'],
      estado: json['estado'],
      cantidad: json['cantidad'],
      rango: json['rango'],
      distancia: json['distancia'],
      coordenadas: Coordenadas.fromJson(json['coordenadas']),
    );
  }

  Entrega copyWith({
    String? cue,
    String? fechaEntrega,
    String? estado,
    int? cantidad,
    String? rango,
    String? distancia,
    Coordenadas? coordenadas,
    String? distanciaCalculada,
  }) {
    return Entrega(
      cue: cue ?? this.cue,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      estado: estado ?? this.estado,
      cantidad: cantidad ?? this.cantidad,
      rango: rango ?? this.rango,
      distancia: distancia ?? this.distancia,
      coordenadas: coordenadas ?? this.coordenadas,
      distanciaCalculada: distanciaCalculada ?? this.distanciaCalculada,
    );
  }
}

class Coordenadas {
  final double latitud;
  final double longitud;

  Coordenadas({
    required this.latitud,
    required this.longitud,
  });

  factory Coordenadas.fromJson(Map<String, dynamic> json) {
    return Coordenadas(
      latitud: json['latitud'],
      longitud: json['longitud'],
    );
  }
}
