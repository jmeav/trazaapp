import 'package:hive/hive.dart';
import 'entregas.dart';

class EntregasAdapter extends TypeAdapter<Entregas> {
  @override
  final int typeId = 2;

  @override
  Entregas read(BinaryReader reader) {
    return Entregas(
      entregaId: reader.read() as String,
      cupa: reader.read() as String,
      cue: reader.read() as String,
      fechaEntrega: reader.read() as DateTime,
      estado: reader.read() as String,
      cantidad: reader.read() as int,
      rangoInicial: reader.read() as int,
      rangoFinal: reader.read() as int,
      latitud: reader.read() as double,
      longitud: reader.read() as double,
      distanciaCalculada: reader.read() as String?,
      codipsa: reader.read() as String, // Nuevo campo
    );
  }

  @override
  void write(BinaryWriter writer, Entregas obj) {
    writer.write(obj.entregaId);
    writer.write(obj.cupa);
    writer.write(obj.cue);
    writer.write(obj.fechaEntrega);
    writer.write(obj.estado);
    writer.write(obj.cantidad);
    writer.write(obj.rangoInicial);
    writer.write(obj.rangoFinal);
    writer.write(obj.latitud);
    writer.write(obj.longitud);
    writer.write(obj.distanciaCalculada ?? '');
    writer.write(obj.codipsa); // Nuevo campo
  }
}
