import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class HomeStat {
  @HiveField(0)
  final int altasRegistradas;

  @HiveField(1)
  final int bajasRegistradas;

  @HiveField(2)
  final int movimientosRegistrados;

  @HiveField(3)
  final int aretesAsignados;

  HomeStat({
    required this.altasRegistradas,
    required this.bajasRegistradas,
    required this.movimientosRegistrados,
    required this.aretesAsignados,
  });

  factory HomeStat.fromJson(Map<String, dynamic> json) {
    return HomeStat(
      altasRegistradas: json['altasRegistradas'] ?? 0,
      bajasRegistradas: json['bajasRegistradas'] ?? 0,
      movimientosRegistrados: json['movimientosRegistrados'] ?? 0,
      aretesAsignados: json['aretesAsignados'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'altasRegistradas': altasRegistradas,
      'bajasRegistradas': bajasRegistradas,
      'movimientosRegistrados': movimientosRegistrados,
      'aretesAsignados': aretesAsignados,
    };
  }
}
