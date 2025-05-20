import 'package:hive/hive.dart';
import 'bag_operadora.dart';

class BagAdapter extends TypeAdapter<Bag> {
  @override
  final int typeId = 6;

  @override
  Bag read(BinaryReader reader) {
    return Bag(
      id: reader.readInt(),
      rangoInicial: reader.readInt(),
      rangoFinal: reader.readInt(),
      cantidad: reader.readInt(),
      dias: reader.readInt(),
      existencia: reader.readInt(),
      rangosAdicionales: (reader.readList() as List).cast<RangoBag>(),
    );
  }

  @override
  void write(BinaryWriter writer, Bag obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.rangoInicial);
    writer.writeInt(obj.rangoFinal);
    writer.writeInt(obj.cantidad);
    writer.writeInt(obj.dias);
    writer.writeInt(obj.existencia);
    writer.writeList(obj.rangosAdicionales);
  }
}
