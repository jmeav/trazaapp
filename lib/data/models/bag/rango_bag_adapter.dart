import 'package:hive/hive.dart';
import 'bag_operadora.dart';

class RangoBagAdapter extends TypeAdapter<RangoBag> {
  @override
  final int typeId = 20;

  @override
  RangoBag read(BinaryReader reader) {
    return RangoBag(
      id: reader.readInt(),
      rangoInicial: reader.readInt(),
      rangoFinal: reader.readInt(),
      cantidad: reader.readInt(),
      existencia: reader.readInt(),
      dias: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, RangoBag obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.rangoInicial);
    writer.writeInt(obj.rangoFinal);
    writer.writeInt(obj.cantidad);
    writer.writeInt(obj.existencia);
    writer.writeInt(obj.dias);
  }
} 