import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/productores/productor.dart';

class ProductorAdapter extends TypeAdapter<Productor> {
  @override
  final int typeId = 5;

  @override
  Productor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Productor(
      idProductor: fields[0] as String,
      productor: fields[1] as String,
      nombreProductor: fields[2] as String,
      lastUpdate: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Productor obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.idProductor)
      ..writeByte(1)
      ..write(obj.productor)
      ..writeByte(2)
      ..write(obj.nombreProductor)
      ..writeByte(3)
      ..write(obj.lastUpdate);
  }
}
