import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/municipios/municipio.dart';

class MunicipioAdapter extends TypeAdapter<Municipio> {
  @override
  final int typeId = 8;

  @override
  Municipio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Municipio(
      idMunicipio: fields[0] as String,
      municipio: fields[1] as String,
      idDepartamento: fields[2] as String,
      lastUpdate: fields[3] as DateTime?, // Leer el campo lastUpdate
    );
  }

  @override
  void write(BinaryWriter writer, Municipio obj) {
    writer
      ..writeByte(4) // Ahora hay 4 campos
      ..writeByte(0)
      ..write(obj.idMunicipio)
      ..writeByte(1)
      ..write(obj.municipio)
      ..writeByte(2)
      ..write(obj.idDepartamento)
      ..writeByte(3)
      ..write(obj.lastUpdate); // Escribir el campo lastUpdate
  }
}
