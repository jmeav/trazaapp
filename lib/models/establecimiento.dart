class Establecimiento {
  final String establecimiento;
  final String nombreEstablecimiento;

  Establecimiento({
    required this.establecimiento,
    required this.nombreEstablecimiento,
  });

  factory Establecimiento.fromJson(Map<String, dynamic> json) {
    return Establecimiento(
      establecimiento: json['establecimiento'] as String,
      nombreEstablecimiento: json['nombreEstablecimiento'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'establecimiento': establecimiento,
      'nombreEstablecimiento': nombreEstablecimiento,
    };
  }
} 