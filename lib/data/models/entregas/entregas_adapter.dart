import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';

class EntregasAdapter extends TypeAdapter<Entregas> {
  @override
  final int typeId = 2;

  @override
  Entregas read(BinaryReader reader) {
    return Entregas(
      entregaId: reader.readString(),
      fechaEntrega: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      cupa: reader.readString(),
      cue: reader.readString(),
      rangoInicial: reader.readInt(),
      rangoFinal: reader.readInt(),
      cantidad: reader.readInt(),
      nombreProductor: reader.readString(),
      establecimiento: reader.readString(),
      dias: reader.readInt(),
      nombreEstablecimiento: reader.readString(),
      latitud: reader.readDouble(),
      longitud: reader.readDouble(),
      existencia: reader.readInt(),
      distanciaCalculada: reader.readString(),
      estado: reader.readString(), 
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      tipo: reader.readString(),
      fotoBovInicial: reader.readString(),
      fotoBovFinal: reader.readString(),
      reposicion: reader.readBool(),
      observaciones: reader.readString(),
      departamento: reader.readString(),
      municipio: reader.readString(),
      rangoInicialExt: reader.readString(),
      rangoFinalExt: reader.readString(),
      esRangoMixto: reader.readBool(),
      aretesAsignados: reader.readIntList(),
    );
  }

  @override
  void write(BinaryWriter writer, Entregas obj) {
    writer.writeString(obj.entregaId);
    writer.writeInt(obj.fechaEntrega.millisecondsSinceEpoch);
    writer.writeString(obj.cupa);
    writer.writeString(obj.cue);
    writer.writeInt(obj.rangoInicial);
    writer.writeInt(obj.rangoFinal);
    writer.writeInt(obj.cantidad);
    writer.writeString(obj.nombreProductor);
    writer.writeString(obj.establecimiento);
    writer.writeInt(obj.dias);
    writer.writeString(obj.nombreEstablecimiento);
    writer.writeDouble(obj.latitud);
    writer.writeDouble(obj.longitud);
    writer.writeInt(obj.existencia);
    writer.writeString(obj.distanciaCalculada?.toString() ?? '');
    writer.writeString(obj.estado);
    writer.writeInt(obj.lastUpdate.millisecondsSinceEpoch);
    writer.writeString(obj.tipo);
    writer.writeString(obj.fotoBovInicial);
    writer.writeString(obj.fotoBovFinal);
    writer.writeBool(obj.reposicion);
    writer.writeString(obj.observaciones);
    writer.writeString(obj.departamento);
    writer.writeString(obj.municipio);
    writer.writeString(obj.rangoInicialExt ?? '');
    writer.writeString(obj.rangoFinalExt ?? '');
    writer.writeBool(obj.esRangoMixto);
    writer.writeIntList(obj.aretesAsignados);
  }
}
