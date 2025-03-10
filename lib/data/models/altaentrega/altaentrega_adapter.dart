import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/altaentrega/altaentrega.dart';

class AltaEntregaAdapter extends TypeAdapter<AltaEntrega> {
  @override
  final int typeId = 10;

  @override
  AltaEntrega read(BinaryReader reader) {
    return AltaEntrega(
      idAlta: reader.readString(),
      rangoInicial: reader.readInt(),
      rangoFinal: reader.readInt(),
      cupa: reader.readString(),
      cue: reader.readString(),
      departamento: reader.readString(), // Campo agregado
      municipio: reader.readString(), // Campo agregado
      latitud: reader.readDouble(),
      longitud: reader.readDouble(),
      distanciaCalculada: reader.readBool() ? reader.readString() : null,
      fechaAlta: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      tipoAlta: reader.readString(),
      detalleBovinos: reader.readList().cast<BovinoResumen>(),
    );
  }

  @override
  void write(BinaryWriter writer, AltaEntrega obj) {
    writer.writeString(obj.idAlta);
    writer.writeInt(obj.rangoInicial);
    writer.writeInt(obj.rangoFinal);
    writer.writeString(obj.cupa);
    writer.writeString(obj.cue);
    writer.writeString(obj.departamento); // Campo agregado
    writer.writeString(obj.municipio); // Campo agregado
    writer.writeDouble(obj.latitud);
    writer.writeDouble(obj.longitud);
    writer.writeBool(obj.distanciaCalculada != null);
    if (obj.distanciaCalculada != null) {
      writer.writeString(obj.distanciaCalculada!);
    }
    writer.writeInt(obj.fechaAlta.millisecondsSinceEpoch);
    writer.writeString(obj.tipoAlta);
    writer.writeList(obj.detalleBovinos);
  }
}
