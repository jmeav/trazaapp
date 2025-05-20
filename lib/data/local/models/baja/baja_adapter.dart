import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/baja/arete_baja.dart';
import 'baja_model.dart';

class BajaAdapter extends TypeAdapter<Baja> {
  @override
  final int typeId = 15;

  @override
  Baja read(BinaryReader reader) {
    return Baja(
      bajaId: reader.readString(),
      cue: reader.readString(),
      cupa: reader.readString(),
      fechaRegistro: DateTime.parse(reader.readString()),
      fechaBaja: DateTime.parse(reader.readString()),
      evidencia: reader.readString(),
      tipoEvidencia: reader.readString(),
      estado: reader.readString(),
      token: reader.readString(),
      codHabilitado: reader.readString(),
      detalleAretes: (reader.readList() as List).cast<AreteBaja>(),
      idorganizacion: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Baja obj) {
    writer.writeString(obj.bajaId);
    writer.writeString(obj.cue);
    writer.writeString(obj.cupa);
    writer.writeString(obj.fechaRegistro.toIso8601String());
    writer.writeString(obj.fechaBaja.toIso8601String());
    writer.writeString(obj.evidencia);
    writer.writeString(obj.tipoEvidencia);
    writer.writeString(obj.estado);
    writer.writeString(obj.token);
    writer.writeString(obj.codHabilitado);
    writer.writeString(obj.idorganizacion);
    writer.writeList(obj.detalleAretes);
  }
} 