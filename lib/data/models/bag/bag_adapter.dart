import 'package:hive/hive.dart';
import 'bag.dart';

class BagAdapter extends TypeAdapter<Bag> {
  @override
  final int typeId = 6;

  @override
  Bag read(BinaryReader reader) {
    return Bag(
      rangoInicial: reader.readInt(),
      rangoFinal: reader.readInt(),
      cantidad: reader.readInt(),
      codIpsa: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Bag obj) {
    writer.writeInt(obj.rangoInicial);
    writer.writeInt(obj.rangoFinal);
    writer.writeInt(obj.cantidad);
    writer.writeString(obj.codIpsa);
  }
}
