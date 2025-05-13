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
      token: reader.readString(),
      isFirstTime: reader.readBool(),
      themeMode: reader.readString(),
      fechaVencimiento: reader.readString(),
      fechaEmision: reader.readString(),
      foto: reader.readString(),
      qr: reader.readString(),
      organizacion: reader.readString(),
      appVersion: reader.readString(),
      latestVersion: reader.readString(),
      lastVersionCheck: reader.readBool() ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null,
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
    writer.writeString(obj.token);
    writer.writeBool(obj.isFirstTime);
    writer.writeString(obj.themeMode);
    writer.writeString(obj.fechaVencimiento);
    writer.writeString(obj.fechaEmision);
    writer.writeString(obj.foto);
    writer.writeString(obj.qr);
    writer.writeString(obj.organizacion);
    writer.writeString(obj.appVersion);
    writer.writeString(obj.latestVersion);
    writer.writeBool(obj.lastVersionCheck != null);
    if (obj.lastVersionCheck != null) {
      writer.writeInt(obj.lastVersionCheck!.millisecondsSinceEpoch);
    }
  }
}

// 🔹 Asegúrate de registrar el adaptador en `main.dart` o en la inicialización de Hive
// Hive.registerAdapter(AppConfigAdapter());
