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
      departamento: reader.readString(),
      municipio: reader.readString(),
      latitud: reader.readDouble(),
      longitud: reader.readDouble(),
      distanciaCalculada: reader.readBool() ? reader.readString() : null,
      fechaAlta: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      tipoAlta: reader.readString(),
      token: reader.readString(),
      codhabilitado: reader.readString(),
      idorganizacion: reader.readString(),
      fotoBovInicial: reader.readString(),
      fotoBovFinal: reader.readString(),
      reposicion: reader.readBool(),
      observaciones: reader.readString(),
      detalleBovinos: reader.readList().cast<BovinoResumen>(),
      estadoAlta: reader.readString(), // NUEVO
    );
  }

  @override
  void write(BinaryWriter writer, AltaEntrega obj) {
    writer.writeString(obj.idAlta);
    writer.writeInt(obj.rangoInicial);
    writer.writeInt(obj.rangoFinal);
    writer.writeString(obj.cupa);
    writer.writeString(obj.cue);
    writer.writeString(obj.departamento);
    writer.writeString(obj.municipio);
    writer.writeDouble(obj.latitud);
    writer.writeDouble(obj.longitud);
    writer.writeBool(obj.distanciaCalculada != null);
    if (obj.distanciaCalculada != null) {
      writer.writeString(obj.distanciaCalculada!);
    }
    writer.writeInt(obj.fechaAlta.millisecondsSinceEpoch);
    writer.writeString(obj.tipoAlta);
    writer.writeString(obj.token);
    writer.writeString(obj.codhabilitado);
    writer.writeString(obj.idorganizacion);
    writer.writeString(obj.fotoBovInicial);
    writer.writeString(obj.fotoBovFinal);
    writer.writeBool(obj.reposicion);
    writer.writeString(obj.observaciones);
    writer.writeList(obj.detalleBovinos);
    writer.writeString(obj.estadoAlta); // NUEVO
  }
}
