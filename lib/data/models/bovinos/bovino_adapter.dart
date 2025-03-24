import 'package:hive/hive.dart';
import 'bovino.dart';

class BovinoAdapter extends TypeAdapter<Bovino> {
  @override
  final int typeId = 3;

  @override
  Bovino read(BinaryReader reader) {
    return Bovino(
      arete: reader.readString(),
      cue: reader.readString(),
      cupa: reader.readString(),
      edad: reader.readInt(),
      sexo: reader.readString(),
      raza: reader.readString(),
      traza: reader.readString(),
      estadoArete: reader.readString(),
      entregaId: reader.readString(), // Nuevo campo agregado
    );
  }

  @override
  void write(BinaryWriter writer, Bovino obj) {
    writer.writeString(obj.arete);
    writer.writeString(obj.cue);
    writer.writeString(obj.cupa);
    writer.writeInt(obj.edad);
    writer.writeString(obj.sexo);
    writer.writeString(obj.raza);
    writer.writeString(obj.traza);
    writer.writeString(obj.estadoArete);
    writer.writeString(obj.entregaId); // Ahora se guarda el `entregaId`
  }
}
