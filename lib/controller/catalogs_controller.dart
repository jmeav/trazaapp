import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/models/departamentos/departamento.dart';
import 'package:trazaapp/data/models/establecimiento/establecimiento.dart';
import 'package:trazaapp/data/models/municipios/municipio.dart';
import 'package:trazaapp/data/models/productores/productor.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/data/models/bag/bag_operadora.dart';
import 'package:trazaapp/data/models/razas/raza.dart';
import 'package:trazaapp/data/models/motivosbajaarete/motivosbajaarete.dart';
import 'package:trazaapp/data/models/motivosbajabovino/motivosbajabovino.dart';
import 'package:trazaapp/data/repositories/catalogs/departamentos_repo.dart';
import 'package:trazaapp/data/repositories/catalogs/establecimientos_repo.dart';
import 'package:trazaapp/data/repositories/catalogs/municipios_repo.dart';
import 'package:trazaapp/data/repositories/catalogs/productores_repo.dart';
import 'package:trazaapp/data/repositories/catalogs/razas.dart';
import 'package:trazaapp/data/repositories/catalogs/motivosbajaarete_repo.dart';
import 'package:trazaapp/data/repositories/catalogs/motivosbajabovino_repo.dart';
import 'package:trazaapp/data/repositories/entregas/entregas_bag_repo.dart';
import 'package:trazaapp/data/repositories/entregas/entregas_repo.dart';
import 'package:trazaapp/presentation/homescreen/home.dart';

class CatalogosController extends GetxController {
  var isDownloading = false.obs;
  var progressText = ''.obs;
  var habilitadoOperadora = "".obs;

  var departamentos = <Departamento>[].obs;
  var municipios = <Municipio>[].obs;
  var establecimientos = <Establecimiento>[].obs;
  var productores = <Productor>[].obs;
  var entregas = <Entregas>[].obs;
  var razas = <Raza>[].obs;
  var bag = Rxn<Bag>();
  var motivosBajaArete = <MotivoBajaArete>[].obs;
  var motivosBajaBovino = <MotivoBajaBovino>[].obs;

  var municipiosFiltrados = <Municipio>[].obs;
  var establecimientosFiltrados = <Establecimiento>[].obs;

  var lastUpdateDepartamentos = ''.obs;
  var lastUpdateMunicipios = ''.obs;
  var lastUpdateEstablecimientos = ''.obs;
  var lastUpdateProductores = ''.obs;
  var lastUpdateEntregas = ''.obs;
  var lastUpdateRazas = ''.obs;
  var lastUpdateBag = ''.obs;
  var lastUpdateMotivosBajaArete = ''.obs;
  var lastUpdateMotivosBajaBovino = ''.obs;

  final DepartamentosRepository _departamentosRepo = DepartamentosRepository();
  final MunicipiosRepository _municipiosRepo = MunicipiosRepository();
  final EstablecimientosRepository _establecimientosRepo = EstablecimientosRepository();
  final ProductoresRepository _productoresRepo = ProductoresRepository();
  final EntregasRepository _entregasRepo = EntregasRepository();
  final BagRepository _bagRepo = BagRepository();
  final RazasRepository _razasRepo = RazasRepository();
  final MotivosBajaAreteRepository _motivosBajaAreteRepo = MotivosBajaAreteRepository();
  final MotivosBajaBovinoRepository _motivosBajaBovinoRepo = MotivosBajaBovinoRepository();
  var currentStep = 0.obs;
  final totalSteps = 9; // número fijo de catálogos
  var isForcedDownload = false.obs;


  @override
  void onInit() {
    super.onInit();
    try {
      _loadConfig();
      checkCatalogStatus();
    } catch (e) {
      print("Error en la inicialización del CatalogosController: $e");
    }
  }

  void _loadConfig() {
    try {
      if (!Hive.isBoxOpen('appConfig')) {
        print("La caja appConfig no está abierta aún");
        return;
      }
      var box = Hive.box<AppConfig>('appConfig');
      var config = box.get('config');
      if (config != null) {
        habilitadoOperadora.value = config.habilitadoOperadora;
      }
    } catch (e) {
      print("Error al cargar la configuración en CatalogosController: $e");
    }
  }

  void checkCatalogStatus() {
    try {
      // Imprimir estado de cajas
      print("Estado de cajas Hive:");
      print("- Departamentos: " + (Hive.isBoxOpen('departamentos') ? "abierta" : "cerrada"));
      print("- Municipios: " + (Hive.isBoxOpen('municipios') ? "abierta" : "cerrada"));
      print("- Establecimientos: " + (Hive.isBoxOpen('establecimientos') ? "abierta" : "cerrada"));
      print("- Productores: " + (Hive.isBoxOpen('productores') ? "abierta" : "cerrada"));
      print("- Entregas: " + (Hive.isBoxOpen('entregas') ? "abierta" : "cerrada"));
      print("- Razas: " + (Hive.isBoxOpen('razas') ? "abierta" : "cerrada"));
      print("- MotivosBajaArete: " + (Hive.isBoxOpen('motivosbajaarete') ? "abierta" : "cerrada"));
      print("- MotivosBajaBovino: " + (Hive.isBoxOpen('motivosbajabovino') ? "abierta" : "cerrada"));
      print("- Bag: " + (Hive.isBoxOpen('bag') ? "abierta" : "cerrada"));

      if (!Hive.isBoxOpen('departamentos') || 
          !Hive.isBoxOpen('municipios') || 
          !Hive.isBoxOpen('establecimientos') ||
          !Hive.isBoxOpen('productores') ||
          !Hive.isBoxOpen('entregas') ||
          !Hive.isBoxOpen('razas') ||
          !Hive.isBoxOpen('motivosbajaarete') ||
          !Hive.isBoxOpen('motivosbajabovino') ||
          !Hive.isBoxOpen('bag')) {
        print("Algunas cajas no están abiertas aún");
        return;
      }

      var boxDep = Hive.box<Departamento>('departamentos');
      var boxMun = Hive.box<Municipio>('municipios');
      var boxEst = Hive.box<Establecimiento>('establecimientos');
      var boxProd = Hive.box<Productor>('productores');
      var boxEnt = Hive.box<Entregas>('entregas');
      var boxRaz = Hive.box<Raza>('razas');
      var boxMotBajaArete = Hive.box<MotivoBajaArete>('motivosbajaarete');
      var boxMotBajaBovino = Hive.box<MotivoBajaBovino>('motivosbajabovino');
      var boxBag = Hive.box<Bag>('bag');

      // Imprimir cantidad de elementos
      print("Cantidad de elementos en cada caja:");
      print("- Departamentos: ${boxDep.length}");
      print("- Municipios: ${boxMun.length}");
      print("- Establecimientos: ${boxEst.length}");
      print("- Productores: ${boxProd.length}");
      print("- Entregas: ${boxEnt.length}");
      print("- Razas: ${boxRaz.length}");
      print("- MotivosBajaArete: ${boxMotBajaArete.length}");
      print("- MotivosBajaBovino: ${boxMotBajaBovino.length}");
      print("- Bag: ${boxBag.length}");

      departamentos.assignAll(boxDep.values.toList());
      municipios.assignAll(boxMun.values.toList());
      establecimientos.assignAll(boxEst.values.toList());
      productores.assignAll(boxProd.values.toList());
      entregas.assignAll(boxEnt.values.toList());
      razas.assignAll(boxRaz.values.toList());
      motivosBajaArete.assignAll(boxMotBajaArete.values.toList());
      motivosBajaBovino.assignAll(boxMotBajaBovino.values.toList());
      
      // Imprimir detalles sobre los valores cargados
      print('MotivosBajaArete IDs cargados: ${motivosBajaArete.map((m) => m.id).toList()}');
      print('MotivosBajaBovino IDs cargados: ${motivosBajaBovino.map((m) => m.id).toList()}');
      
      print('MotivosBajaArete detalles:');
      for (var motivo in motivosBajaArete) {
        print('ID: ${motivo.id}, Nombre: ${motivo.nombre}');
      }
      
      print('MotivosBajaBovino detalles:');
      for (var motivo in motivosBajaBovino) {
        print('ID: ${motivo.id}, Nombre: ${motivo.nombre}');
      }
      
      bag.value = boxBag.isNotEmpty ? boxBag.getAt(0) : null;

      // Imprimir estado después de cargar
      print("Estado después de cargar:");
      print("- Departamentos: ${departamentos.length}");
      print("- Municipios: ${municipios.length}");
      print("- Establecimientos: ${establecimientos.length}");
      print("- Productores: ${productores.length}");
      print("- Entregas: ${entregas.length}");
      print("- Razas: ${razas.length}");
      print("- MotivosBajaArete: ${motivosBajaArete.length}");
      print("- MotivosBajaBovino: ${motivosBajaBovino.length}");
      print("- Bag: ${bag.value != null ? 'cargado' : 'no cargado'}");

      _loadLastUpdates();
    } catch (e) {
      print("Error al verificar el estado de los catálogos: $e");
      
      // Intentar abrir cajas específicas si hay error
      try {
        if (!Hive.isBoxOpen('motivosbajaarete')) {
          Hive.openBox<MotivoBajaArete>('motivosbajaarete');
          print("Caja motivosbajaarete abierta después del error");
        }
        if (!Hive.isBoxOpen('motivosbajabovino')) {
          Hive.openBox<MotivoBajaBovino>('motivosbajabovino');
          print("Caja motivosbajabovino abierta después del error");
        }
      } catch (boxError) {
        print("Error al intentar abrir cajas después del error principal: $boxError");
      }
    }
  }

  Future<void> _loadLastUpdates() async {
    try {
      if (!Hive.isBoxOpen('catalog_updates')) {
        await Hive.openBox('catalog_updates');
      }
      var updatesBox = Hive.box('catalog_updates');
      lastUpdateDepartamentos.value = updatesBox.get('Departamentos', defaultValue: 'Nunca');
      lastUpdateMunicipios.value = updatesBox.get('Municipios', defaultValue: 'Nunca');
      lastUpdateEstablecimientos.value = updatesBox.get('Establecimientos', defaultValue: 'Nunca');
      lastUpdateProductores.value = updatesBox.get('Productores', defaultValue: 'Nunca');
      lastUpdateEntregas.value = updatesBox.get('Entregas', defaultValue: 'Nunca');
      lastUpdateRazas.value = updatesBox.get('Razas', defaultValue: 'Nunca');
      lastUpdateMotivosBajaArete.value = updatesBox.get('MotivosBajaArete', defaultValue: 'Nunca');
      lastUpdateMotivosBajaBovino.value = updatesBox.get('MotivosBajaBovino', defaultValue: 'Nunca');
      lastUpdateBag.value = updatesBox.get('Bag', defaultValue: 'Nunca');
    } catch (e) {
      print("Error al cargar las últimas actualizaciones: $e");
    }
  }

Future<void> downloadAllCatalogsSequential({
  required String token,
  required String codhabilitado,
}) async {
  isDownloading.value = true;
  currentStep.value = 0;

  await downloadDepartamentos(token: token, codhabilitado: codhabilitado);
  currentStep.value++;

  await downloadMunicipios(token: token, codhabilitado: codhabilitado);
  currentStep.value++;

  await downloadEstablecimientos(token: token, codhabilitado: codhabilitado);
  currentStep.value++;

  await downloadProductores(token: token, codhabilitado: codhabilitado);
  currentStep.value++;

  if (departamentos.isNotEmpty && municipios.isNotEmpty) {
    await downloadBag(token: token, codhabilitado: codhabilitado);
  }
  currentStep.value++;

  if (departamentos.isNotEmpty && municipios.isNotEmpty) {
    await downloadEntregas(token: token, codhabilitado: codhabilitado);
  }
  currentStep.value++;

  await downloadRazas(token: token, codhabilitado: codhabilitado);
  currentStep.value++;

  await downloadMotivosBajaArete(token: token, codhabilitado: codhabilitado);
  currentStep.value++;

  await downloadMotivosBajaBovino(token: token, codhabilitado: codhabilitado);
  currentStep.value++;

  isDownloading.value = false;

  await Future.delayed(const Duration(seconds: 1));
  Get.offUntil(GetPageRoute(page: () => HomeView()), (route) => false);
}


  Future<void> downloadRazas({
    required String token,
    required String codhabilitado,
  }) async {
    await _downloadCatalog(
      title: "Razas",
      fetchFunction: (t, c) => _razasRepo.fetchRazas(token: t, codhabilitado: c),
      box: Hive.box<Raza>('razas'),
      list: razas,
      lastUpdate: lastUpdateRazas,
      token: token,
      codhabilitado: codhabilitado,
    );
  }

  Future<void> _downloadCatalog<T>({
    required String title,
    required Future<List<T>> Function(String, String) fetchFunction,
    required Box<T> box,
    required RxList<T> list,
    required RxString lastUpdate,
    required String token,
    required String codhabilitado,
  }) async {
    try {
      isDownloading.value = true;
      progressText.value = "Descargando $title...";
      var data = await fetchFunction(token, codhabilitado);
      await box.clear();
      await box.addAll(data);
      list.assignAll(data);
      var updatesBox = await Hive.openBox('catalog_updates');
      await updatesBox.put(title, DateTime.now().toIso8601String());
      lastUpdate.value = DateTime.now().toIso8601String();
      progressText.value = "$title descargado con éxito";
    } catch (e) {
      progressText.value = "Error al descargar $title: $e";
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> downloadDepartamentos({
    required String token,
    required String codhabilitado,
  }) async {
    await _downloadCatalog(
      title: "Departamentos",
      fetchFunction: (t, c) => _departamentosRepo.fetchDepartamentos(token: t, codhabilitado: c),
      box: Hive.box<Departamento>('departamentos'),
      list: departamentos,
      lastUpdate: lastUpdateDepartamentos,
      token: token,
      codhabilitado: codhabilitado,
    );
  }

  Future<void> downloadMunicipios({
    required String token,
    required String codhabilitado,
  }) async {
    await _downloadCatalog(
      title: "Municipios",
      fetchFunction: (t, c) => _municipiosRepo.fetchMunicipios(token: t, codhabilitado: c),
      box: Hive.box<Municipio>('municipios'),
      list: municipios,
      lastUpdate: lastUpdateMunicipios,
      token: token,
      codhabilitado: codhabilitado,
    );
  }

  Future<void> downloadEstablecimientos({
    required String token,
    required String codhabilitado,
  }) async {
    await _downloadCatalog(
      title: "Establecimientos",
      fetchFunction: (t, c) => _establecimientosRepo.fetchEstablecimientos(token: t, codhabilitado: c),
      box: Hive.box<Establecimiento>('establecimientos'),
      list: establecimientos,
      lastUpdate: lastUpdateEstablecimientos,
      token: token,
      codhabilitado: codhabilitado,
    );
  }

  Future<void> downloadProductores({
    required String token,
    required String codhabilitado,
  }) async {
    await _downloadCatalog(
      title: "Productores",
      fetchFunction: (t, c) => _productoresRepo.fetchProductores(token: t, codhabilitado: c),
      box: Hive.box<Productor>('productores'),
      list: productores,
      lastUpdate: lastUpdateProductores,
      token: token,
      codhabilitado: codhabilitado,
    );
  }

  Future<void> downloadEntregas({
    required String token,
    required String codhabilitado,
  }) async {
    await _downloadCatalog(
      title: "Entregas",
      fetchFunction: (t, c) => _entregasRepo.fetchEntregas(token: t, codhabilitado: c),
      box: Hive.box<Entregas>('entregas'),
      list: entregas,
      lastUpdate: lastUpdateEntregas,
      token: token,
      codhabilitado: codhabilitado,
    );
  }

  Future<void> downloadBag({
    required String token,
    required String codhabilitado,
  }) async {
    try {
      isDownloading.value = true;
      progressText.value = "Descargando Bag...";
      
      print("🔄 Iniciando descarga de Bag en CatalogsController");
      
      // Usar fetchAllBags para obtener todos los rangos
      List<Bag> bagsData = await _bagRepo.fetchAllBags(token: token, codhabilitado: codhabilitado);
      
      if (bagsData.isEmpty) {
        progressText.value = "No se encontraron Bags disponibles";
        return;
      }
      
      print("✅ Bags descargados: ${bagsData.length} con el primer bag teniendo ${bagsData[0].rangosAdicionales.length} rangos adicionales");
      
      // El método fetchAllBags ya guarda el bag en Hive, solo necesitamos actualizar la UI
      bag.value = bagsData[0];
      
      // Actualizar última vez actualizado
      var updatesBox = await Hive.openBox('catalog_updates');
      await updatesBox.put("Bag", DateTime.now().toIso8601String());
      lastUpdateBag.value = DateTime.now().toIso8601String();
      
      progressText.value = "Bag descargado con éxito";
      print("✅ Descarga de Bag finalizada con éxito");
    } catch (e) {
      print("❌ Error en downloadBag: $e");
      progressText.value = "Error al descargar Bag: $e";
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> downloadMotivosBajaArete({
    required String token,
    required String codhabilitado,
  }) async {
    try {
      print('Iniciando descarga de motivos de baja arete...');
      if (!Hive.isBoxOpen('motivosbajaarete')) {
        print('Abriendo caja motivosbajaarete...');
        await Hive.openBox<MotivoBajaArete>('motivosbajaarete');
      }
      
      var box = Hive.box<MotivoBajaArete>('motivosbajaarete');
      
      await _downloadCatalog(
        title: "MotivosBajaArete",
        fetchFunction: (t, c) => _motivosBajaAreteRepo.fetchMotivosBajaArete(token: t, codhabilitado: c),
        box: box,
        list: motivosBajaArete,
        lastUpdate: lastUpdateMotivosBajaArete,
        token: token,
        codhabilitado: codhabilitado,
      );
      print('Finalizada descarga de motivos de baja arete: ${motivosBajaArete.length} registros');
    } catch (e) {
      print('Error al descargar motivos de baja arete: $e');
      rethrow;
    }
  }

  Future<void> downloadMotivosBajaBovino({
    required String token,
    required String codhabilitado,
  }) async {
    try {
      print('🔄 Iniciando descarga de motivos de baja bovino...');
      progressText.value = 'Descargando motivos de baja bovino...';
      
      final motivosBovino = await _motivosBajaBovinoRepo.fetchMotivosBajaBovino(
        token: token,
        codhabilitado: codhabilitado,
      );
      
      if (motivosBovino.isNotEmpty) {
        // Actualizar la lista en memoria
        motivosBajaBovino.assignAll(motivosBovino);
        
        // Guardar fecha de actualización
        if (!Hive.isBoxOpen('catalog_updates')) {
          await Hive.openBox('catalog_updates');
        }
        var updatesBox = Hive.box('catalog_updates');
        await updatesBox.put('MotivosBajaBovino', DateTime.now().toString());
        lastUpdateMotivosBajaBovino.value = DateTime.now().toString();
        
        print('✅ Motivos de baja bovino descargados exitosamente: ${motivosBovino.length} registros');
      } else {
        print('⚠️ No se encontraron motivos de baja bovino para descargar');
        throw Exception('No se encontraron motivos de baja bovino para descargar');
      }
    } catch (e) {
      print('❌ Error al descargar motivos de baja bovino: $e');
      throw Exception('Error al descargar motivos de baja bovino: $e');
    }
  }
}