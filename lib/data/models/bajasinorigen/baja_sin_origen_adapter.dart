import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/bajasinorigen/baja_sin_origen.dart';

class BajaSinOrigenAdapter extends TypeAdapter<BajaSinOrigen> {
  @override
  final int typeId = 19;

  @override
  BajaSinOrigen read(BinaryReader reader) {
    return BajaSinOrigen(
      id: reader.readString(),
      arete: reader.readString(),
      latitud: reader.readDouble(),
      longitud: reader.readDouble(),
      fecha: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      motivo: reader.readString(),
      evidencia: reader.readString(),
      estado: reader.readString(),
      token: reader.readString(),
      codHabilitado: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, BajaSinOrigen obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.arete);
    writer.writeDouble(obj.latitud);
    writer.writeDouble(obj.longitud);
    writer.writeInt(obj.fecha.millisecondsSinceEpoch);
    writer.writeString(obj.motivo);
    writer.writeString(obj.evidencia);
    writer.writeString(obj.estado);
    writer.writeString(obj.token);
    writer.writeString(obj.codHabilitado);
  }
} 