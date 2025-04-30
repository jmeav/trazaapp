import 'package:hive/hive.dart';

@HiveType(typeId: 16)
class AreteBaja {
  @HiveField(0)
  final String arete;

  @HiveField(1)
  final String motivoId;

  @HiveField(2)
  final String bajaId;

  AreteBaja({
    required this.arete,
    required this.motivoId,
    required this.bajaId,
  });

  // Método copyWith para crear una copia modificada
  AreteBaja copyWith({
    String? arete,
    String? motivoId,
    String? bajaId,
  }) {
    return AreteBaja(
      arete: arete ?? this.arete,
      motivoId: motivoId ?? this.motivoId,
      bajaId: bajaId ?? this.bajaId,
    );
  }

  // Método para convertir a JSON para envío al servidor
  Map<String, dynamic> toJson() {
    return {
      'arete': arete,
      'motivoId': motivoId,
    };
  }

  // Constructor factory desde JSON (puede necesitar ajustes si la fuente es diferente)
  factory AreteBaja.fromJson(Map<String, dynamic> json) {
    final motivoValue = json['MOTIVO'] ?? json['motivo_id'] ?? '';
    return AreteBaja(
      arete: json['ARETE'] ?? json['arete'] ?? '',
      motivoId: motivoValue.toString(),
      bajaId: json['BAJA_ID'] ?? json['baja_id'] ?? '',
    );
  }
} 