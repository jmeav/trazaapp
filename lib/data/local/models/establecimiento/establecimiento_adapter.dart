import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/establecimiento/establecimiento.dart';

class EstablecimientoAdapter extends TypeAdapter<Establecimiento> {
  @override
  final int typeId = 4;

  @override
  Establecimiento read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Establecimiento(
      idEstablecimiento: fields[0] as String,
      establecimiento: fields[1] as String,
      nombreEstablecimiento: fields[2] as String,
      idDepartamento: fields[3] as String,
      idMunicipio: fields[4] as String,
      productor: fields[5] as String,
      latitud: fields[6] as String,
      longitud: fields[7] as String,
      lastUpdate: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Establecimiento obj) {
    writer
      ..writeByte(9) // Ahora hay 9 campos
      ..writeByte(0)
      ..write(obj.idEstablecimiento)
      ..writeByte(1)
      ..write(obj.establecimiento)
      ..writeByte(2)
      ..write(obj.nombreEstablecimiento)
      ..writeByte(3)
      ..write(obj.idDepartamento)
      ..writeByte(4)
      ..write(obj.idMunicipio)
      ..writeByte(5)
      ..write(obj.productor)
      ..writeByte(6)
      ..write(obj.latitud)
      ..writeByte(7)
      ..write(obj.longitud)
      ..writeByte(8)
      ..write(obj.lastUpdate);
  }
}
