import 'package:hive/hive.dart';
import 'bovino.dart';

class BovinoAdapter extends TypeAdapter<Bovino> {
  @override
  final int typeId = 3;

  @override
  Bovino read(BinaryReader reader) {
    // Asegúrate de leer todos los campos en el mismo orden
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };

    return Bovino(
      arete: fields[0] as String,
      cue: fields[1] as String,
      cupa: fields[2] as String,
      edad: fields[3] as int,
      sexo: fields[4] as String,
      raza: fields[5] as String,
      traza: fields[6] as String,
      estadoArete: fields[7] as String,
      entregaId: fields[8] as String,
      fotoArete: fields[9] as String? ?? '',
      areteMadre: fields[10] as String? ?? '',
      aretePadre: fields[11] as String? ?? '',
      regMadre: fields[12] as String? ?? '',
      regPadre: fields[13] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, Bovino obj) {
    writer
      ..writeByte(14) // IMPORTANTE: la cantidad de campos totales
      ..writeByte(0)
      ..write(obj.arete)
      ..writeByte(1)
      ..write(obj.cue)
      ..writeByte(2)
      ..write(obj.cupa)
      ..writeByte(3)
      ..write(obj.edad)
      ..writeByte(4)
      ..write(obj.sexo)
      ..writeByte(5)
      ..write(obj.raza)
      ..writeByte(6)
      ..write(obj.traza)
      ..writeByte(7)
      ..write(obj.estadoArete)
      ..writeByte(8)
      ..write(obj.entregaId)
      ..writeByte(9)
      ..write(obj.fotoArete)
      ..writeByte(10)
      ..write(obj.areteMadre)
      ..writeByte(11)
      ..write(obj.aretePadre)
      ..writeByte(12)
      ..write(obj.regMadre)
      ..writeByte(13)
      ..write(obj.regPadre);
  }
}
