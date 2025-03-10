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
      rangoInicial: fields[4] as int,
      rangoFinal: fields[5] as int,
      cantidad: fields[6] as int,
      nombreProductor: fields[7] as String,
      establecimiento: fields[8] as String,
      dias: fields[9] as int,
      nombreEstablecimiento: fields[10] as String,
      latitud: fields[11] as double,
      longitud: fields[12] as double,
      existencia: fields[13] as int,
      distanciaCalculada: fields[14] as String?,
      estado: fields[15] as String,
      lastUpdate: fields[16] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Entregas obj) {
    writer
      ..writeByte(17) // Cantidad total de campos
      ..writeByte(0)
      ..write(obj.entregaId)
      ..writeByte(1)
      ..write(obj.fechaEntrega)
      ..writeByte(2)
      ..write(obj.cupa)
      ..writeByte(3)
      ..write(obj.cue)
      ..writeByte(4)
      ..write(obj.rangoInicial)
      ..writeByte(5)
      ..write(obj.rangoFinal)
      ..writeByte(6)
      ..write(obj.cantidad)
      ..writeByte(7)
      ..write(obj.nombreProductor)
      ..writeByte(8)
      ..write(obj.establecimiento)
      ..writeByte(9)
      ..write(obj.dias)
      ..writeByte(10)
      ..write(obj.nombreEstablecimiento)
      ..writeByte(11)
      ..write(obj.latitud)
      ..writeByte(12)
      ..write(obj.longitud)
      ..writeByte(13)
      ..write(obj.existencia)
      ..writeByte(14)
      ..write(obj.distanciaCalculada)
      ..writeByte(15)
      ..write(obj.estado)
      ..writeByte(16)
      ..write(obj.lastUpdate);
  }
}
