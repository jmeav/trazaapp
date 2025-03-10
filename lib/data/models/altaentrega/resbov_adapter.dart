import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/altaentrega/altaentrega.dart';

class BovinoResumenAdapter extends TypeAdapter<BovinoResumen> {
  @override
  final int typeId = 11;

  @override
  BovinoResumen read(BinaryReader reader) {
    return BovinoResumen(
      arete: reader.readString(),
      edad: reader.readInt(),
      sexo: reader.readString(),
      raza: reader.readString(),
      traza: reader.readString(),
      estadoArete: reader.readString(),
      fechaNacimiento: DateTime.fromMillisecondsSinceEpoch(reader.readInt()), // Se lee de Hive
    );
  }

  @override
  void write(BinaryWriter writer, BovinoResumen obj) {
    writer.writeString(obj.arete);
    writer.writeInt(obj.edad);
    writer.writeString(obj.sexo);
    writer.writeString(obj.raza);
    writer.writeString(obj.traza);
    writer.writeString(obj.estadoArete);
    writer.writeInt(obj.fechaNacimiento.millisecondsSinceEpoch); // Se guarda en Hive
  }
}
