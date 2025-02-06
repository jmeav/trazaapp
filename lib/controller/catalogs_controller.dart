import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/departamentos/departamento.dart';
import 'package:trazaapp/data/models/establecimiento/establecimiento.dart';
import 'package:trazaapp/data/models/municipios/municipio.dart';
import 'package:trazaapp/data/repositories/catalogs/departamentos_repo.dart';
import 'package:trazaapp/data/repositories/catalogs/establecimientos_repo.dart';
import 'package:trazaapp/data/repositories/catalogs/municipios_repo.dart';

class CatalogosController extends GetxController {
  var isDownloading = false.obs;
  var progressText = ''.obs;

  var establecimientos = <Establecimiento>[].obs;
  var departamentos = <Departamento>[].obs;
  var municipios = <Municipio>[].obs;

  final EstablecimientosRepository _establecimientosRepo = EstablecimientosRepository();
  final DepartamentosRepository _departamentosRepo = DepartamentosRepository();
  final MunicipiosRepository _municipiosRepo = MunicipiosRepository();

  @override
  void onInit() {
    super.onInit();
    checkCatalogStatus();
  }

  void checkCatalogStatus() async {
    var boxEst = await Hive.openBox<Establecimiento>('establecimientos');
    var boxDep = await Hive.openBox<Departamento>('departamentos');
    var boxMun = await Hive.openBox<Municipio>('municipios');

    establecimientos.assignAll(boxEst.values.whereType<Establecimiento>().toList());
    departamentos.assignAll(boxDep.values.whereType<Departamento>().toList());
    municipios.assignAll(boxMun.values.whereType<Municipio>().toList());
  }

  Future<void> downloadAllCatalogs({required String token, required String codhabilitado}) async {
    await downloadDepartamentos(token: token, codhabilitado: codhabilitado);
    await downloadMunicipios(token: token, codhabilitado: codhabilitado);
    await downloadEstablecimientos(token: token, codhabilitado: codhabilitado);
  }

  Future<void> downloadEstablecimientos({required String token, required String codhabilitado}) async {
    try {
      isDownloading.value = true;
      progressText.value = "Descargando Establecimientos...";

      var data = await _establecimientosRepo.fetchEstablecimientos(
        token: token,
        codhabilitado: codhabilitado,
      );

      establecimientos.assignAll(data);

      var box = await Hive.openBox<Establecimiento>('establecimientos');
      await box.clear();
      for (var item in data) {
        item.lastUpdate = DateTime.now();
        await box.add(item);
      }

      progressText.value = "Establecimientos descargados con éxito";
    } catch (e) {
      progressText.value = "Error al descargar Establecimientos: $e";
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> downloadDepartamentos({required String token, required String codhabilitado}) async {
    try {
      isDownloading.value = true;
      progressText.value = "Descargando Departamentos...";

      var data = await _departamentosRepo.fetchDepartamentos(
        token: token,
        codhabilitado: codhabilitado,
      );

      departamentos.assignAll(data);

      var box = await Hive.openBox<Departamento>('departamentos');
      await box.clear();
      for (var item in data) {
        item.lastUpdate = DateTime.now();
        await box.add(item);
      }

      progressText.value = "Departamentos descargados con éxito";
    } catch (e) {
      progressText.value = "Error al descargar Departamentos: $e";
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> downloadMunicipios({required String token, required String codhabilitado}) async {
    try {
      isDownloading.value = true;
      progressText.value = "Descargando Municipios...";

      var data = await _municipiosRepo.fetchMunicipios(
        token: token,
        codhabilitado: codhabilitado,
      );

      municipios.assignAll(data);

      var box = await Hive.openBox<Municipio>('municipios');
      await box.clear();
      for (var item in data) {
        item.lastUpdate = DateTime.now();
        await box.add(item);
      }

      progressText.value = "Municipios descargados con éxito";
    } catch (e) {
      progressText.value = "Error al descargar Municipios: $e";
    } finally {
      isDownloading.value = false;
    }
  }
}
