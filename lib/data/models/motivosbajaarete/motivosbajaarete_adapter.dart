import 'package:hive/hive.dart';
import 'motivosbajaarete.dart';

class MotivoBajaAreteAdapter extends TypeAdapter<MotivoBajaArete> {
  @override
  final int typeId = 18;

  @override
  MotivoBajaArete read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) 
        reader.readByte(): reader.read(),
    };
    return MotivoBajaArete(
      id: fields[0] as int,
      nombre: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MotivoBajaArete obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre);
  }
} 