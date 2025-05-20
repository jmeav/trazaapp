import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/razas/raza.dart';

class RazaAdapter extends TypeAdapter<Raza> {
  @override
  final int typeId = 12; // Asegúrate de que coincida con el modelo

  @override
  Raza read(BinaryReader reader) {
    return Raza(
      id: reader.readString(),
      nombre: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Raza obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.nombre);
  }
}
