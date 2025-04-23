import 'package:hive/hive.dart';

@HiveType(typeId: 16)
class AreteBaja {
  @HiveField(0)
  final String arete;

  @HiveField(1)
  final String motivoBaja;

  @HiveField(2)
  final String bajaId;

  AreteBaja({
    required this.arete,
    required this.motivoBaja,
    required this.bajaId,
  });

  // Método copyWith para crear una copia modificada
  AreteBaja copyWith({
    String? arete,
    String? motivoBaja,
    String? bajaId,
  }) {
    return AreteBaja(
      arete: arete ?? this.arete,
      motivoBaja: motivoBaja ?? this.motivoBaja,
      bajaId: bajaId ?? this.bajaId,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'ARETE': arete,
      'MOTIVO': motivoBaja,
      'BAJA_ID': bajaId,
    };
  }

  // Constructor factory desde JSON
  factory AreteBaja.fromJson(Map<String, dynamic> json) {
    return AreteBaja(
      arete: json['ARETE'] ?? '',
      motivoBaja: json['MOTIVO'] ?? '',
      bajaId: json['BAJA_ID'] ?? '',
    );
  }
} 