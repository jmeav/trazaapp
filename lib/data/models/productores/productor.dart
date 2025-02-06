import 'package:hive/hive.dart';

@HiveType(typeId: 5)
class Productor {
  @HiveField(0)
  final String idProductor;

  @HiveField(1)
  final String productor;

  @HiveField(2)
  final String nombreProductor;

  Productor({
    required this.idProductor,
    required this.productor,
    required this.nombreProductor,
  });

  factory Productor.fromJson(Map<String, dynamic> json) {
    return Productor(
      idProductor: json['IDPRODUCTOR'] ?? '',
      productor: json['PRODUCTOR'] ?? '',
      nombreProductor: json['NOMBREPRODUCTOR'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDPRODUCTOR': idProductor,
      'PRODUCTOR': productor,
      'NOMBREPRODUCTOR': nombreProductor,
    };
  }
}
