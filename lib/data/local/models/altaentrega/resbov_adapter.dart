import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/altaentrega/altaentrega.dart';


class BovinoResumenAdapter extends TypeAdapter<BovinoResumen> {
  @override
  final int typeId = 11;

  @override
  BovinoResumen read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for(int i=0; i<numOfFields; i++) reader.readByte(): reader.read(),
    };

    return BovinoResumen(
      arete: fields[0] as String,
      edad: fields[1] as int,
      sexo: fields[2] as String,
      raza: fields[3] as String,
      traza: fields[4] as String,
      estadoArete: fields[5] as String,
      fechaNacimiento: DateTime.fromMillisecondsSinceEpoch(fields[6] as int),
      fotoArete: fields[7] as String? ?? '',
      areteMadre: fields[8] as String? ?? '',
      aretePadre: fields[9] as String? ?? '',
      regMadre: fields[10] as String? ?? '',
      regPadre: fields[11] as String? ?? '',
      motivoEstadoAreteId: fields[12] as String? ?? '0',
    );
  }

  @override
  void write(BinaryWriter writer, BovinoResumen obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.arete)
      ..writeByte(1)
      ..write(obj.edad)
      ..writeByte(2)
      ..write(obj.sexo)
      ..writeByte(3)
      ..write(obj.raza)
      ..writeByte(4)
      ..write(obj.traza)
      ..writeByte(5)
      ..write(obj.estadoArete)
      ..writeByte(6)
      ..write(obj.fechaNacimiento.millisecondsSinceEpoch)
      ..writeByte(7)
      ..write(obj.fotoArete)
      ..writeByte(8)
      ..write(obj.areteMadre)
      ..writeByte(9)
      ..write(obj.aretePadre)
      ..writeByte(10)
      ..write(obj.regMadre)
      ..writeByte(11)
      ..write(obj.regPadre)
      ..writeByte(12)
      ..write(obj.motivoEstadoAreteId);
  }
}
