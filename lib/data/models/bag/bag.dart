import 'package:hive/hive.dart';

@HiveType(typeId: 6)
class Bag {
  @HiveField(0)
  final int rangoInicial;

  @HiveField(1)
  final int rangoFinal;

  @HiveField(2)
  final int cantidad;

  @HiveField(3)
  final String codIpsa;

  Bag({
    required this.rangoInicial,
    required this.rangoFinal,
    required this.cantidad,
    required this.codIpsa,
  });

  // Método copyWith
  Bag copyWith({
    int? rangoInicial,
    int? rangoFinal,
    int? cantidad,
    String? codIpsa,
  }) {
    return Bag(
      rangoInicial: rangoInicial ?? this.rangoInicial,
      rangoFinal: rangoFinal ?? this.rangoFinal,
      cantidad: cantidad ?? this.cantidad,
      codIpsa: codIpsa ?? this.codIpsa,
    );
  }
}
