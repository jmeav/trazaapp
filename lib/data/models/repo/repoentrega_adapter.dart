import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/repo/repoentrega.dart';
import 'package:trazaapp/data/models/repo/bovinorepo.dart';

class RepoEntregaAdapter extends TypeAdapter<RepoEntrega> {
  @override
  final int typeId = 13;

  @override
  RepoEntrega read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return RepoEntrega(
      idRepo: fields[0] as String,
      entregaIdOrigen: fields[1] as String,
      cupa: fields[2] as String,
      cue: fields[3] as String,
      departamento: fields[4] as String,
      municipio: fields[5] as String,
      latitud: fields[6] as double,
      longitud: fields[7] as double,
      distanciaCalculada: fields[8] as String?,
      fechaRepo: fields[9] as DateTime,
      token: fields[10] as String,
      pdfEvidencia: fields[11] as String,
      observaciones: fields[12] as String,
      detalleBovinos: (fields[13] as List).cast<BovinoRepo>(),
      estadoRepo: fields[14] as String,
      fotoBovInicial: fields[15] as String,
      fotoBovFinal: fields[16] as String,
      fotoFicha: fields[17] as String,
      codhabilitado: fields[18] as String,
      idorganizacion: fields[19] as String,
      rangoInicialRepo: fields[20] as int,
      rangoFinalRepo: fields[21] as int,
      aplicaEntrega: (fields[22] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, RepoEntrega obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.idRepo)
      ..writeByte(1)
      ..write(obj.entregaIdOrigen)
      ..writeByte(2)
      ..write(obj.cupa)
      ..writeByte(3)
      ..write(obj.cue)
      ..writeByte(4)
      ..write(obj.departamento)
      ..writeByte(5)
      ..write(obj.municipio)
      ..writeByte(6)
      ..write(obj.latitud)
      ..writeByte(7)
      ..write(obj.longitud)
      ..writeByte(8)
      ..write(obj.distanciaCalculada)
      ..writeByte(9)
      ..write(obj.fechaRepo)
      ..writeByte(10)
      ..write(obj.token)
      ..writeByte(11)
      ..write(obj.pdfEvidencia)
      ..writeByte(12)
      ..write(obj.observaciones)
      ..writeByte(13)
      ..write(obj.detalleBovinos)
      ..writeByte(14)
      ..write(obj.estadoRepo)
      ..writeByte(15)
      ..write(obj.fotoBovInicial)
      ..writeByte(16)
      ..write(obj.fotoBovFinal)
      ..writeByte(17)
      ..write(obj.fotoFicha)
      ..writeByte(18)
      ..write(obj.codhabilitado)
      ..writeByte(19)
      ..write(obj.idorganizacion)
      ..writeByte(20)
      ..write(obj.rangoInicialRepo)
      ..writeByte(21)
      ..write(obj.rangoFinalRepo)
      ..writeByte(22)
      ..write(obj.aplicaEntrega);
  }
} 