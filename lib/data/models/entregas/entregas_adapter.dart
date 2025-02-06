import 'package:hive/hive.dart';
import 'entregas.dart';

class EntregasAdapter extends TypeAdapter<Entregas> {
  @override
  final int typeId = 2;

  @override
  Entregas read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) 
        reader.readByte(): reader.read(),
    };
    return Entregas(
      entregaId: fields[0] as String,
      fechaEntrega: fields[1] as DateTime,
      cupa: fields[2] as String,
      cue: fields[3] as String,
      estado: fields[4] as String,
      rangoInicial: fields[5] as int,
      rangoFinal: fields[6] as int,
      cantidad: fields[7] as int,
      nombreProductor: fields[8] as String,
      establecimiento: fields[9] as String,
      dias: fields[10] as int,
      nombreEstablecimiento: fields[11] as String,
      latitud: fields[12] as double,
      longitud: fields[13] as double,
      existencia: fields[14] as int,
      distanciaCalculada: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Entregas obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.entregaId)
      ..writeByte(1)
      ..write(obj.fechaEntrega)
      ..writeByte(2)
      ..write(obj.cupa)
      ..writeByte(3)
      ..write(obj.cue)
      ..writeByte(4)
      ..write(obj.estado)
      ..writeByte(5)
      ..write(obj.rangoInicial)
      ..writeByte(6)
      ..write(obj.rangoFinal)
      ..writeByte(7)
      ..write(obj.cantidad)
      ..writeByte(8)
      ..write(obj.nombreProductor)
      ..writeByte(9)
      ..write(obj.establecimiento)
      ..writeByte(10)
      ..write(obj.dias)
      ..writeByte(11)
      ..write(obj.nombreEstablecimiento)
      ..writeByte(12)
      ..write(obj.latitud)
      ..writeByte(13)
      ..write(obj.longitud)
      ..writeByte(14)
      ..write(obj.existencia)
      ..writeByte(15)
      ..write(obj.distanciaCalculada);
  }
}
