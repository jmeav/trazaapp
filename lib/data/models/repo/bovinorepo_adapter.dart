import 'package:hive/hive.dart';
import 'bovinorepo.dart';

class BovinoRepoAdapter extends TypeAdapter<BovinoRepo> {
  @override
  final int typeId = 14;

  @override
  BovinoRepo read(BinaryReader reader) {
    return BovinoRepo(
      arete: reader.readString(),
      edad: reader.readInt(),
      sexo: reader.readString(),
      raza: reader.readString(),
      traza: reader.readString(),
      estadoArete: reader.readString(),
      fechaNacimiento: DateTime.parse(reader.readString()),
      fotoArete: reader.readString(),
      areteMadre: reader.readString(),
      aretePadre: reader.readString(),
      regMadre: reader.readString(),
      regPadre: reader.readString(),
      repoEntregaId: reader.readString(),
      areteAnterior: reader.readString(), repoId: '',
    );
  }

  @override
  void write(BinaryWriter writer, BovinoRepo obj) {
    writer.writeString(obj.arete);
    writer.writeInt(obj.edad);
    writer.writeString(obj.sexo);
    writer.writeString(obj.raza);
    writer.writeString(obj.traza);
    writer.writeString(obj.estadoArete);
    writer.writeString(obj.fechaNacimiento.toIso8601String());
    writer.writeString(obj.fotoArete);
    writer.writeString(obj.areteMadre);
    writer.writeString(obj.aretePadre);
    writer.writeString(obj.regMadre);
    writer.writeString(obj.regPadre);
    writer.writeString(obj.repoEntregaId);
    writer.writeString(obj.areteAnterior);
  }
} 