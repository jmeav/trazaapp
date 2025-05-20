import 'package:hive/hive.dart';

@HiveType(typeId: 12) // Asigna un nuevo typeId único para este modelo
class Raza {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombre;

  Raza({
    required this.id,
    required this.nombre,
  });

  Raza copyWith({
    String? id,
    String? nombre,
  }) {
    return Raza(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
    );
  }
}
