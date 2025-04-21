class Productor {
  final String productor;
  final String nombreProductor;

  Productor({
    required this.productor,
    required this.nombreProductor,
  });

  factory Productor.fromJson(Map<String, dynamic> json) {
    return Productor(
      productor: json['productor'] as String,
      nombreProductor: json['nombreProductor'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productor': productor,
      'nombreProductor': nombreProductor,
    };
  }
} 