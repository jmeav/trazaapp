import 'package:hive/hive.dart';
import 'motivosbajabovino.dart';

class MotivoBajaBovinoAdapter extends TypeAdapter<MotivoBajaBovino> {
  @override
  final int typeId = 17;

  @override
  MotivoBajaBovino read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) 
        reader.readByte(): reader.read(),
    };
    return MotivoBajaBovino(
      id: fields[0] as int,
      nombre: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MotivoBajaBovino obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre);
  }
} 