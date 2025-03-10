// Adaptador manual de Hive para AppConfig
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';

class AppConfigAdapter extends TypeAdapter<AppConfig> {
  @override
  final int typeId = 9;  

  @override
  AppConfig read(BinaryReader reader) {
    return AppConfig(
      imei: reader.readString(),
      codHabilitado: reader.readString(),
      nombre: reader.readString(),
      cedula: reader.readString(),
      email: reader.readString(),
      movil: reader.readString(),
      idOrganizacion: reader.readString(),
      categoria: reader.readString(),
      habilitadoOperadora: reader.readString(),
      token: reader.readString(), // 🔹 Ahora se lee el token correctamente
      isFirstTime: reader.readBool(),
      themeMode: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, AppConfig obj) {
    writer.writeString(obj.imei);
    writer.writeString(obj.codHabilitado);
    writer.writeString(obj.nombre);
    writer.writeString(obj.cedula);
    writer.writeString(obj.email);
    writer.writeString(obj.movil);
    writer.writeString(obj.idOrganizacion);
    writer.writeString(obj.categoria);
    writer.writeString(obj.habilitadoOperadora);
    writer.writeString(obj.token); // 🔹 Ahora se guarda el token correctamente
    writer.writeBool(obj.isFirstTime);
    writer.writeString(obj.themeMode);
  }
}

// 🔹 Asegúrate de registrar el adaptador en `main.dart` o en la inicialización de Hive
// Hive.registerAdapter(AppConfigAdapter());
