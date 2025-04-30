import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/baja/arete_baja.dart';

class AreteBajaAdapter extends TypeAdapter<AreteBaja> {
  @override
  final int typeId = 16;

  @override
  AreteBaja read(BinaryReader reader) {
    return AreteBaja(
      arete: reader.read(),
      motivoId: reader.read(),
      bajaId: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, AreteBaja obj) {
    writer.write(obj.arete);
    writer.write(obj.motivoId);
    writer.write(obj.bajaId);
  }
} 