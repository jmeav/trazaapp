import 'package:hive/hive.dart';

@HiveType(typeId: 9)  
class AppConfig {
  @HiveField(0)
  String imei;
  @HiveField(1)
  String codHabilitado;
  @HiveField(2)
  String nombre;
  @HiveField(3)
  String cedula;
  @HiveField(4)
  String email;
  @HiveField(5)
  String movil;
  @HiveField(6)
  String idOrganizacion;
  @HiveField(7)
  String categoria;
  @HiveField(8)
  String habilitadoOperadora;
  @HiveField(9)
  String token; // 🔹 Mantendremos `token` como un campo normal
  @HiveField(10)
  bool isFirstTime;
  @HiveField(11)
  String themeMode;
  @HiveField(12)
  String fechaVencimiento;
  @HiveField(13)
  String fechaEmision;
  @HiveField(14)
  String foto;
  @HiveField(15)
  String qr;
  @HiveField(16)
  String organizacion;
  @HiveField(17)
  String appVersion;
  @HiveField(18)
  String latestVersion;
  @HiveField(19)
  DateTime? lastVersionCheck;

  AppConfig({
    required this.imei,
    required this.codHabilitado,
    required this.nombre,
    required this.cedula,
    required this.email,
    required this.movil,
    required this.idOrganizacion,
    required this.categoria,
    required this.habilitadoOperadora,
    required this.token, // 🔹 Ahora `token` debe ser pasado como argumento
    required this.isFirstTime,
    required this.themeMode,
    required this.fechaVencimiento,
    required this.fechaEmision,
    required this.foto,
    required this.qr,
    required this.organizacion,
    this.appVersion = '1.0.0',
    this.latestVersion = '1.0.0',
    this.lastVersionCheck,
  });

  /// **📌 Método `copyWith()` corregido**
  AppConfig copyWith({
    String? imei,
    String? codHabilitado,
    String? nombre,
    String? cedula,
    String? email,
    String? movil,
    String? idOrganizacion,
    String? categoria,
    String? habilitadoOperadora,
    String? token, // 🔹 Ahora `token` también es opcional
    bool? isFirstTime,
    String? themeMode,
    String? fechaVencimiento,
    String? fechaEmision,
    String? foto,
    String? qr,
    String? organizacion,
    String? appVersion,
    String? latestVersion,
    DateTime? lastVersionCheck,
  }) {
    return AppConfig(
      imei: imei ?? this.imei,
      codHabilitado: codHabilitado ?? this.codHabilitado,
      nombre: nombre ?? this.nombre,
      cedula: cedula ?? this.cedula,
      email: email ?? this.email,
      movil: movil ?? this.movil,
      idOrganizacion: idOrganizacion ?? this.idOrganizacion,
      categoria: categoria ?? this.categoria,
      habilitadoOperadora: habilitadoOperadora ?? this.habilitadoOperadora,
      token: token ?? this.token, // 🔹 Mantiene el valor original del token
      isFirstTime: isFirstTime ?? this.isFirstTime,
      themeMode: themeMode ?? this.themeMode,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      fechaEmision: fechaEmision ?? this.fechaEmision,
      foto: foto ?? this.foto,
      qr: qr ?? this.qr,
      organizacion: organizacion ?? this.organizacion,
      appVersion: appVersion ?? this.appVersion,
      latestVersion: latestVersion ?? this.latestVersion,
      lastVersionCheck: lastVersionCheck ?? this.lastVersionCheck,
    );
  }
}
