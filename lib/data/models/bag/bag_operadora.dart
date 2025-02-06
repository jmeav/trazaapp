import 'package:hive/hive.dart';

@HiveType(typeId: 6)
class Bag {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int rangoInicial;

  @HiveField(2)
  final int rangoFinal;

  @HiveField(3)
  final int cantidad;

  @HiveField(4)
  final int dias;

  @HiveField(5)
  final int existencia;

  Bag({
    required this.id,
    required this.rangoInicial,
    required this.rangoFinal,
    required this.cantidad,
    required this.dias,
    required this.existencia,
  });

  // Método copyWith para crear una copia modificada del objeto
  Bag copyWith({
    int? id,
    int? rangoInicial,
    int? rangoFinal,
    int? cantidad,
    int? dias,
    int? existencia,
  }) {
    return Bag(
      id: id ?? this.id,
      rangoInicial: rangoInicial ?? this.rangoInicial,
      rangoFinal: rangoFinal ?? this.rangoFinal,
      cantidad: cantidad ?? this.cantidad,
      dias: dias ?? this.dias,
      existencia: existencia ?? this.existencia,
    );
  }

  // Constructor factory para crear un objeto Bag a partir de un JSON
  factory Bag.fromJson(Map<String, dynamic> json) {
    return Bag(
      id: int.tryParse(json['ID'] ?? '0') ?? 0,
      rangoInicial: int.tryParse(json['RANGO_INICIAL'] ?? '0') ?? 0,
      rangoFinal: int.tryParse(json['RANGO_FINAL'] ?? '0') ?? 0,
      cantidad: int.tryParse(json['CANTIDAD'] ?? '0') ?? 0,
      dias: int.tryParse(json['DIAS'] ?? '0') ?? 0,
      existencia: int.tryParse(json['EXISTENCIA'] ?? '0') ?? 0,
    );
  }

  // Conversión a JSON, en caso de ser necesario
  Map<String, dynamic> toJson() {
    return {
      'ID': id.toString(),
      'RANGO_INICIAL': rangoInicial.toString(),
      'RANGO_FINAL': rangoFinal.toString(),
      'CANTIDAD': cantidad.toString(),
      'DIAS': dias.toString(),
      'EXISTENCIA': existencia.toString(),
    };
  }
}
