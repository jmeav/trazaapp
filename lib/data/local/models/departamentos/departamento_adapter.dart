import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/departamentos/departamento.dart';

class DepartamentoAdapter extends TypeAdapter<Departamento> {
  @override
  final int typeId = 7;

  @override
  Departamento read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) 
        reader.readByte(): reader.read(),
    };
    return Departamento(
      idDepartamento: fields[0] as String,
      departamento: fields[1] as String,
      lastUpdate: fields[2] as DateTime?, // Leer el campo lastUpdate
    );
  }

  @override
  void write(BinaryWriter writer, Departamento obj) {
    writer
      ..writeByte(3) // Ahora hay 3 campos
      ..writeByte(0)
      ..write(obj.idDepartamento)
      ..writeByte(1)
      ..write(obj.departamento)
      ..writeByte(2)
      ..write(obj.lastUpdate); // Escribir el campo lastUpdate
  }
}
