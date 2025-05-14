import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:trazaapp/data/models/baja/baja_model.dart';
import 'package:trazaapp/data/models/baja/arete_baja.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/models/establecimiento/establecimiento.dart';
import 'package:trazaapp/data/models/productores/productor.dart';
import 'package:trazaapp/presentation/widgets/custom_saving.dart';
import 'package:trazaapp/utils/utils.dart';
import 'package:trazaapp/data/models/motivosbajabovino/motivosbajabovino.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/data/repositories/baja/baja_repo.dart';
import 'package:trazaapp/data/repositories/bajasinorigen/baja_sin_origen_repo.dart';
import 'package:trazaapp/controller/arete_input_controller.dart';
import 'package:trazaapp/data/models/bajasinorigen/baja_sin_origen.dart';

class BajaController extends GetxController {
  final motivoController = TextEditingController();
  final AreteInputController areteInput =
      Get.put(AreteInputController(), tag: 'areteInput');
  final cueController = TextEditingController();
  final cupaController = TextEditingController();
  final fechaBajaController = TextEditingController();
  final evidenciaController = TextEditingController();
  final cantidadController = TextEditingController();

  final RxString selectedMotivo = ''.obs;
  final Rx<DateTime> fechaBaja = DateTime.now().obs;
  final RxString evidenciaBase64 = ''.obs;
  final RxString tipoEvidencia = ''.obs;
  final RxString pdfFileName = ''.obs;
  final RxString evidenciaFileName = ''.obs;
  final RxBool isLoading = true.obs;
  final RxInt cantidadBajas = 1.obs;

  final RxList<AreteBaja> detalleAretes = <AreteBaja>[].obs;

  final RxInt currentAreteIndex = 0.obs;

  late Box<Baja> bajaBox;
  late Box<AppConfig> configBox;
  late Box<Establecimiento> establecimientoBox;
  late Box<Productor> productorBox;

  var motivos = <MotivoBajaBovino>[].obs;
  var selectedMotivoId = 0.obs;

  final RxList<Baja> bajasPendientes = <Baja>[].obs;
  final RxBool isInitialized = false.obs;

  @override
  void onInit() async {
    super.onInit();

    isLoading.value = true;
    isInitialized.value = false;

    try {
      print('🔄 Inicializando BajaController...');

      // Asegurarnos que las cajas estén abiertas
      if (!Hive.isBoxOpen('bajas')) {
        bajaBox = await Hive.openBox<Baja>('bajas');
      } else {
        bajaBox = Hive.box<Baja>('bajas');
      }

      if (!Hive.isBoxOpen('appConfig')) {
        configBox = await Hive.openBox<AppConfig>('appConfig');
      } else {
        configBox = Hive.box<AppConfig>('appConfig');
      }

      if (!Hive.isBoxOpen('establecimientos')) {
        establecimientoBox =
            await Hive.openBox<Establecimiento>('establecimientos');
      } else {
        establecimientoBox = Hive.box<Establecimiento>('establecimientos');
      }

      if (!Hive.isBoxOpen('productores')) {
        productorBox = await Hive.openBox<Productor>('productores');
      } else {
        productorBox = Hive.box<Productor>('productores');
      }

      _initVariables();

      // Intentar cargar los motivos hasta 3 veces con un retraso entre intentos
      int intentos = 0;
      bool motivosCargados = false;

      while (intentos < 3 && !motivosCargados) {
        try {
          await _loadMotivosBajaBovino();
          motivosCargados = true;
        } catch (e) {
          print('❌ Intento ${intentos + 1} fallido al cargar motivos: $e');
          intentos++;
          if (intentos < 3) {
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      }

      if (!motivosCargados) {
        throw Exception(
            'No se pudieron cargar los motivos después de 3 intentos');
      }

      isInitialized.value = true;
      print('✅ BajaController inicializado correctamente');

      cargarBajasPendientes();
    } catch (e) {
      print('❌ Error al inicializar BajaController: $e');
      isInitialized.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void _initVariables() {
    // Inicializar fechas y campos relacionados
    fechaBaja.value = DateTime.now();
    fechaBajaController.text = _formatDate(fechaBaja.value);

    // Inicializar cantidad
    cantidadController.text = "1";
    cantidadBajas.value = 1;

    // Inicializar motivos
    selectedMotivo.value = '';
    selectedMotivoId.value = 0;

    // Otros valores iniciales
    currentAreteIndex.value = 0;
  }

  @override
  void onReady() {
    super.onReady();
    print('🔄 BajaController está listo');
  }

  @override
  void onClose() {
    // No dispondremos los controladores aquí para evitar el error
    // motivoController.dispose();
    // cueController.dispose();
    // cupaController.dispose();
    // fechaBajaController.dispose();
    // evidenciaController.dispose();
    // cantidadController.dispose();
    super.onClose();
  }

  void reinicializarControladores() {
    // Reinicializar los controladores si es necesario
    if (motivoController.hasListeners) {
      motivoController.clear();
    }
    if (cueController.hasListeners) {
      cueController.clear();
    }
    if (cupaController.hasListeners) {
      cupaController.clear();
    }
    if (fechaBajaController.hasListeners) {
      fechaBajaController.clear();
    }
    if (evidenciaController.hasListeners) {
      evidenciaController.clear();
    }
    if (cantidadController.hasListeners) {
      cantidadController.clear();
    }
  }

  String generateBajaId() {
    // Genera 5 caracteres alfanuméricos aleatorios
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(
      5,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  void setMotivo(int id, String nombre) {
    selectedMotivoId.value = id;
    selectedMotivo.value = nombre;
  }

  void setFechaBaja(DateTime date) {
    fechaBaja.value = date;
    fechaBajaController.text = _formatDate(date);
  }

  void setCantidadBajas(int cantidad) {
    cantidadBajas.value = cantidad;
    cantidadController.text = cantidad.toString();

    detalleAretes.clear();
    currentAreteIndex.value = 0;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void agregarArete(String arete, String motivoId) {
    final bajaId = generateBajaId();

    detalleAretes.add(AreteBaja(
      arete: arete,
      motivoId: motivoId,
      bajaId: bajaId,
    ));
  }

  void guardarAreteActual() {
    final areteText = areteInput.areteController.text.trim();

    if (areteText.isEmpty) {
      Get.snackbar(
        'Error',
        'Debe ingresar un número de arete.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedMotivoId.value == 0) {
      Get.snackbar(
        'Error',
        'Debe seleccionar un motivo de baja.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final areteBaja = AreteBaja(
      arete: areteText,
      motivoId: selectedMotivoId.value.toString(),
      bajaId: 'temp',
    );

    final index = currentAreteIndex.value;
    if (index < detalleAretes.length) {
      detalleAretes[index] = areteBaja;
    } else {
      detalleAretes.add(areteBaja);
    }

    areteInput.clear();
    selectedMotivoId.value = 0;
    selectedMotivo.value = '';

    if (index < cantidadBajas.value - 1) {
      currentAreteIndex.value++;
      cargarAreteActual();
    } else {
      Get.snackbar(
        'Éxito',
        'Último arete guardado.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void cargarAreteActual() {
    if (currentAreteIndex.value < detalleAretes.length) {
      final arete = detalleAretes[currentAreteIndex.value];
      areteInput.areteController.text = arete.arete;

      final motivoIdInt = int.tryParse(arete.motivoId) ?? 0;
      selectedMotivoId.value = motivoIdInt;

      final motivo = motivos.firstWhereOrNull((m) => m.id == motivoIdInt);
      selectedMotivo.value = motivo?.nombre ?? '';
    } else {
      areteInput.clear();
      selectedMotivo.value = motivos.isNotEmpty ? motivos.first.nombre : '';
      selectedMotivoId.value = motivos.isNotEmpty ? motivos.first.id : 0;
    }
  }

  void siguienteArete() {
    if (currentAreteIndex.value < cantidadBajas.value - 1) {
      currentAreteIndex.value++;
      cargarAreteActual();
    }
  }

  void anteriorArete() {
    if (currentAreteIndex.value > 0) {
      currentAreteIndex.value--;
      cargarAreteActual();
    }
  }

  Future<void> loadEvidencia() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final filePath = result.files.single.path;
        if (filePath == null) return;

        pdfFileName.value = result.files.single.name;
        final file = File(filePath);
        final bytes = await file.readAsBytes();

        final fileSizeInMB = bytes.length / (1024 * 1024);

        if (fileSizeInMB > 5) {
          Get.snackbar(
            'Error',
            'El archivo PDF es muy grande (${fileSizeInMB.toStringAsFixed(2)}MB). Máximo 5MB.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        final base64String = base64Encode(bytes);
        final base64SizeInMB = base64String.length / (1024 * 1024);

        if (base64SizeInMB > 2.5) {
          Get.snackbar(
            'Error',
            'El archivo es demasiado grande después de la conversión.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        evidenciaBase64.value = base64String;
        tipoEvidencia.value = 'pdf';
        evidenciaFileName.value = pdfFileName.value;
        evidenciaController.text = pdfFileName.value;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cargar la evidencia: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool validateForm() {
    if (detalleAretes.isEmpty || detalleAretes.length != cantidadBajas.value) {
      Get.snackbar('Error', 'Debe registrar todos los aretes');
      return false;
    }

    if (cueController.text.isEmpty) {
      Get.snackbar('Error', 'El CUE es obligatorio');
      return false;
    }

    if (cupaController.text.isEmpty) {
      Get.snackbar('Error', 'La CUPA es obligatoria');
      return false;
    }

    if (evidenciaBase64.value.isEmpty) {
      Get.snackbar('Error', 'La evidencia es obligatoria');
      return false;
    }

    if (tipoEvidencia.value.isEmpty) {
      Get.snackbar('Error', 'Debe seleccionar tipo de evidencia');
      return false;
    }

    return true;
  }

  Future<void> saveBaja() async {
    if (!validateForm()) return;

    try {
      Get.dialog(
        const SavingLoadingDialog(),
        barrierDismissible: false,
      );
      final config = configBox.get('config');
      if (config == null) {
        throw Exception('No se encontró la configuración del usuario.');
      }

      final bajaId = generateBajaId();

      final updatedAretes =
          detalleAretes.map((arete) => arete.copyWith(bajaId: bajaId)).toList();

      final baja = Baja(
        bajaId: bajaId,
        cue: cueController.text,
        cupa: cupaController.text,
        fechaRegistro: DateTime.now(),
        fechaBaja: fechaBaja.value,
        evidencia: evidenciaBase64.value,
        tipoEvidencia: tipoEvidencia.value,
        token: config.imei,
        codHabilitado: config.codHabilitado,
        detalleAretes: updatedAretes,
        idorganizacion: config.idOrganizacion,
      );

      await bajaBox.put(bajaId, baja);
      clearForm();

      Get.snackbar(
        'Éxito',
        'Baja de ${updatedAretes.length} aretes registrada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );

      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.offAllNamed('/home');
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al guardar la baja: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void clearForm() {
    motivoController.clear();
    cueController.clear();
    cupaController.clear();
    fechaBajaController.clear();
    evidenciaController.clear();
    cantidadController.text = "1";
    selectedMotivo.value = '';
    evidenciaBase64.value = '';
    tipoEvidencia.value = '';
    pdfFileName.value = '';
    evidenciaFileName.value = '';
    fechaBaja.value = DateTime.now();
    fechaBajaController.text = _formatDate(fechaBaja.value);
    cantidadBajas.value = 1;
    detalleAretes.clear();
    currentAreteIndex.value = 0;
    areteInput.clear();
    selectedMotivo.value = '';
    selectedMotivoId.value = 0;
  }

  void cargarBajasPendientes() {
    if (!isInitialized.value) {
      print(
          '⚠️ Intentando cargar bajas pendientes antes de inicializar. Operación ignorada.');
      return;
    }

    isLoading.value = true;

    try {
      if (!bajaBox.isOpen) {
        print('❌ Error: bajaBox no está inicializada o no está abierta');
        isLoading.value = false;
        return;
      }

      // Cargar bajas regulares
      final pendientes =
          bajaBox.values.where((baja) => baja.estado == 'pendiente').toList();

      bajasPendientes.value = pendientes;

      print(
          '📦 Bajas regulares pendientes cargadas: ${bajasPendientes.length}');

      // Cargar bajas sin origen
      final boxBajasSinOrigen = Hive.box<BajaSinOrigen>('bajassinorigen');
      final bajasSinOrigenPendientes = boxBajasSinOrigen.values
          .where((baja) => baja.estado == 'pendiente')
          .toList();

      print(
          '📦 Bajas sin origen pendientes cargadas: ${bajasSinOrigenPendientes.length}');

      if (bajasPendientes.isEmpty && bajasSinOrigenPendientes.isEmpty) {
        print('⚠️ No hay bajas pendientes para enviar');
      }
    } catch (e) {
      print('❌ Error al cargar bajas pendientes: $e');
      Future.microtask(() {
        Get.snackbar(
          'Error',
          'Error al cargar bajas pendientes: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> buscarEstablecimientoYProductor(String cue) async {
    final establecimiento = establecimientoBox.values.firstWhere(
        (e) => e.establecimiento == cue,
        orElse: () => throw Exception('CUE no encontrado'));

    final productor = productorBox.values.firstWhere(
        (p) => p.productor == establecimiento.productor,
        orElse: () => throw Exception('Productor no encontrado'));

    cueController.text = establecimiento.establecimiento;
    cupaController.text = productor.productor;
  }

  Future<void> escanearArete() async {
    try {
      final result = await Get.toNamed('/scanner');
      if (result != null) {
        areteInput.areteController.text = result;
        Get.snackbar(
          'Éxito',
          'Arete escaneado correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al escanear arete: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> enviarBajasPendientes() async {
    if (bajasPendientes.isEmpty) {
      Get.snackbar(
        'Información',
        'No hay bajas pendientes para enviar',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      await Future.delayed(const Duration(seconds: 2));

      for (var i = 0; i < bajasPendientes.length; i++) {
        final baja = bajasPendientes[i];
        final bajaActualizada = baja.copyWith(estado: 'enviado');

        final index =
            bajaBox.values.toList().indexWhere((b) => b.bajaId == baja.bajaId);

        if (index != -1) {
          await bajaBox.putAt(index, bajaActualizada);
        }
      }

      Get.back();

      Get.snackbar(
        'Éxito',
        'Bajas enviadas correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      cargarBajasPendientes();
    } catch (e) {
      Get.back();

      Get.snackbar(
        'Error',
        'Error al enviar las bajas: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<List<Establecimiento>> buscarEstablecimientos(String query) async {
    if (query.isEmpty) return [];

    final box = Hive.box<Establecimiento>('establecimientos');
    final establecimientos = box.values.toList();

    return establecimientos.where((establecimiento) {
      final nombreLower = establecimiento.nombreEstablecimiento.toLowerCase();
      final cueLower = establecimiento.establecimiento.toLowerCase();
      final queryLower = query.toLowerCase();

      return nombreLower.contains(queryLower) || cueLower.contains(queryLower);
    }).toList();
  }

  Future<List<Productor>> buscarProductores(String query) async {
    if (query.isEmpty) return [];

    final box = Hive.box<Productor>('productores');
    final productores = box.values.toList();

    return productores.where((productor) {
      final nombreLower = productor.nombreProductor.toLowerCase();
      final cupaLower = productor.productor.toLowerCase();
      final queryLower = query.toLowerCase();

      return nombreLower.contains(queryLower) || cupaLower.contains(queryLower);
    }).toList();
  }

  Future<void> _loadMotivosBajaBovino() async {
    try {
      if (!Hive.isBoxOpen('motivosbajabovino')) {
        await Hive.openBox<MotivoBajaBovino>('motivosbajabovino');
      }

      final catalogsController = Get.find<CatalogosController>();

      print(
          'Catálogo controller - motivos bovino: ${catalogsController.motivosBajaBovino.length}');

      // Si el catálogo está vacío, intentar cargar desde la caja local
      if (catalogsController.motivosBajaBovino.isEmpty) {
        var box = Hive.box<MotivoBajaBovino>('motivosbajabovino');
        if (box.isNotEmpty) {
          print('Cargando motivos desde caja local: ${box.length} motivos');
          motivos.assignAll(box.values.toList());
        } else {
          print(
              '⚠️ No hay motivos disponibles ni en el catálogo ni en la caja local');
          throw Exception(
              'No hay motivos de baja bovino disponibles. Por favor, actualice los catálogos desde el menú principal.');
        }
      } else {
        motivos.assignAll(catalogsController.motivosBajaBovino);
        print(
            'Motivos de baja bovino cargados desde catálogo: ${motivos.length}');
      }

      // Seleccionar el primer motivo válido
      if (motivos.isNotEmpty) {
        for (var motivo in motivos) {
          if (motivo.id > 0 && motivo.nombre.isNotEmpty) {
            selectedMotivo.value = motivo.nombre;
            selectedMotivoId.value = motivo.id;
            print(
                'Seleccionado motivo válido: ${motivo.nombre} (ID: ${motivo.id})');
            return;
          }
        }
      }

      // Si no se encontró ningún motivo válido
      selectedMotivo.value = '';
      selectedMotivoId.value = 0;
      print('⚠️ No se encontraron motivos válidos');
    } catch (e) {
      print('❌ Error cargando los motivos de baja: $e');
      selectedMotivo.value = '';
      selectedMotivoId.value = 0;
      throw e;
    }
  }

  Future<void> eliminarBaja(String bajaId) async {
    try {
      final index =
          bajaBox.values.toList().indexWhere((b) => b.bajaId == bajaId);
      if (index != -1) {
        await bajaBox.deleteAt(index);
        cargarBajasPendientes(); // Recargar la lista de pendientes
        Get.snackbar('Eliminada', 'Baja $bajaId eliminada correctamente.',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar(
          'Error',
          'No se encontró la baja con ID $bajaId para eliminar.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al eliminar la baja: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> enviarBaja(String bajaId) async {
    final envioBajaRepository = EnvioBajaRepository();
    final baja = bajaBox.get(bajaId);
    if (baja == null) {
      Get.snackbar('Error', 'No se encontró la baja con ID: $bajaId');
      return;
    }
    await envioBajaRepository.enviarBaja(baja.toJsonEnvio());
    // Marcar como enviada y actualizar en Hive
    final bajaEnviada = baja.copyWith(estado: 'enviada');
    await bajaBox.put(bajaId, bajaEnviada);
    cargarBajasPendientes();
  }

  Future<void> enviarBajaSinOrigen(String id) async {
    try {
      print('🔄 Iniciando envío de baja sin origen con ID: $id');

      final boxBajasSinOrigen = Hive.box<BajaSinOrigen>('bajassinorigen');
      final baja = boxBajasSinOrigen.get(id);

      if (baja == null) {
        print('❌ No se encontró la baja sin origen con ID: $id');
        Get.snackbar('Error', 'No se encontró la baja sin origen con ID: $id');
        return;
      }

      print('📤 Preparando envío de baja sin origen:');
      print('Arete: ${baja.arete}');
      print('Fecha: ${baja.fecha}');
      print('Estado actual: ${baja.estado}');

      final envioBajaSinOrigenRepository = EnvioBajaSinOrigenRepository();
      final jsonEnvio = baja.toJsonEnvio();

      print('📦 Datos a enviar:');
      print(jsonEncode(jsonEnvio));

      await envioBajaSinOrigenRepository.enviarBajaSinOrigen(jsonEnvio);

      // Marcar como enviada y actualizar en Hive
      final bajaEnviada = baja.copyWith(estado: 'enviada');
      await boxBajasSinOrigen.put(id, bajaEnviada);

      print('✅ Baja sin origen enviada y actualizada correctamente');

      // Recargar la lista de bajas pendientes
      cargarBajasPendientes();
    } catch (e) {}
  }

  Future<void> eliminarBajaSinOrigen(String id) async {
    try {
      final boxBajasSinOrigen = Hive.box<BajaSinOrigen>('bajassinorigen');
      await boxBajasSinOrigen.delete(id);
      cargarBajasPendientes(); // Recargar la lista de pendientes
      Get.snackbar('Eliminada', 'Baja sin origen eliminada correctamente.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al eliminar la baja sin origen: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
