import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/data/models/repo/repoentrega.dart';
import 'package:trazaapp/data/models/repo/bovinorepo.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/models/razas/raza.dart';
import 'package:trazaapp/utils/utils.dart';

class FormRepoController extends GetxController {
  late Box<Entregas> entregasBox;
  late Box<RepoEntrega> repoBox;
  late Box<BovinoRepo> bovinosBox;
  late Box<Raza> razasBox;
  late Box<AppConfig> configBox;

  final pageController = PageController();
  final currentPage = 0.obs;
  final isLoading = true.obs;

  final bovinosRepo = <BovinoRepo>[].obs;
  final razas = <Raza>[].obs;

  String? entregaId;
  String? repoId;

  final entrega = Rxn<Entregas>();
  final repoEntrega = Rxn<RepoEntrega>();
  final bovinosRepoOriginal = <BovinoRepo>[].obs;

  // Variables para el PageView
  final rangoInicial = 0.obs;
  final rangoFinal = 0.obs;
  final cantidad = 0.obs;
  final fotoBovInicial = ''.obs;
  final fotoBovFinal = ''.obs;
  final fotoFicha = ''.obs;
  final isValid = false.obs;

  // Controladores
  final observacionesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      entregasBox = Hive.box<Entregas>('entregas');
      repoBox = Hive.box<RepoEntrega>('repoentregas');
      bovinosBox = Hive.box<BovinoRepo>('bovinosrepo');
      razasBox = Hive.box<Raza>('razas');
      configBox = Hive.box<AppConfig>('appconfig');

      // Obtener IDs de los argumentos
      final Map<String, dynamic> args = Get.arguments ?? {};
      entregaId = args['entregaId'] as String?;
      repoId = args['repoId'] as String?;

      if (entregaId == null || repoId == null) {
        throw Exception('No se proporcionaron los IDs necesarios');
      }

      // Cargar razas
      razas.value = razasBox.values.toList();

      // Cargar bovinos de la reposición
      final repo = repoBox.get(repoId);
      if (repo == null) {
        throw Exception('No se encontró la reposición');
      }

      bovinosRepo.value = bovinosBox.values
          .where((bovino) => bovino.repoId == repoId)
          .toList();

      if (bovinosRepo.isEmpty) {
        throw Exception('No hay bovinos en esta reposición');
      }

      // Cargar datos originales
      entrega.value = entregasBox.get(entregaId);
      repoEntrega.value = repoBox.get(repoId);
      bovinosRepoOriginal.value = bovinosBox.values
          .where((b) => b.repoEntregaId == repoId)
          .toList();

      // Calcular rangos y cantidad para reposición
      final cantidadReposicion = entrega.value!.cantidad ~/ 3;
      rangoInicial.value = entrega.value!.rangoFinal - cantidadReposicion + 1;
      rangoFinal.value = entrega.value!.rangoFinal;
      cantidad.value = cantidadReposicion;

      // Observar cambios para validación
      ever(fotoBovInicial, (_) => _validateForm());
      ever(fotoBovFinal, (_) => _validateForm());
      ever(fotoFicha, (_) => _validateForm());

      observacionesController.addListener(() {
        _validateForm();
      });

    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cargar los datos: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() {
    if (currentPage.value < bovinosRepo.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void updateAreteAnterior(int index, String value) {
    final bovino = bovinosRepo[index];
    final updated = bovino.copyWith(areteAnterior: value);
    bovinosBox.put(bovino.arete, updated);
    bovinosRepo[index] = updated;
  }

  void updateEdad(int index, int value) {
    final bovino = bovinosRepo[index];
    final updated = bovino.copyWith(edad: value);
    bovinosBox.put(bovino.arete, updated);
    bovinosRepo[index] = updated;
  }

  void updateSexo(int index, String value) {
    final bovino = bovinosRepo[index];
    final updated = bovino.copyWith(sexo: value);
    bovinosBox.put(bovino.arete, updated);
    bovinosRepo[index] = updated;
  }

  void updateRaza(int index, String value) {
    final bovino = bovinosRepo[index];
    final updated = bovino.copyWith(raza: value);
    bovinosBox.put(bovino.arete, updated);
    bovinosRepo[index] = updated;
  }

  void updateTraza(int index, String value) {
    final bovino = bovinosRepo[index];
    final updated = bovino.copyWith(traza: value);
    bovinosBox.put(bovino.arete, updated);
    bovinosRepo[index] = updated;
  }

  void updateEstadoArete(int index, String value) {
    final bovino = bovinosRepo[index];
    final updated = bovino.copyWith(
      estadoArete: value,
      fotoArete: value == 'Bueno' ? '' : bovino.fotoArete,
    );
    bovinosBox.put(bovino.arete, updated);
    bovinosRepo[index] = updated;
  }

  void updateAreteMadre(int index, String value) {
    final bovino = bovinosRepo[index];
    final updated = bovino.copyWith(areteMadre: value);
    bovinosBox.put(bovino.arete, updated);
    bovinosRepo[index] = updated;
  }

  void updateAretePadre(int index, String value) {
    final bovino = bovinosRepo[index];
    final updated = bovino.copyWith(aretePadre: value);
    bovinosBox.put(bovino.arete, updated);
    bovinosRepo[index] = updated;
  }

  void updateRegMadre(int index, String value) {
    final bovino = bovinosRepo[index];
    final updated = bovino.copyWith(regMadre: value);
    bovinosBox.put(bovino.arete, updated);
    bovinosRepo[index] = updated;
  }

  void updateRegPadre(int index, String value) {
    final bovino = bovinosRepo[index];
    final updated = bovino.copyWith(regPadre: value);
    bovinosBox.put(bovino.arete, updated);
    bovinosRepo[index] = updated;
  }

  Future<void> tomarFotoArete(int index) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );

      if (image != null) {
        final base64Image = await Utils.imageToBase64(image.path);
        final bovino = bovinosRepo[index];
        final updated = bovino.copyWith(fotoArete: base64Image);
        bovinosBox.put(bovino.arete, updated);
        bovinosRepo[index] = updated;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al tomar la foto: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void applyQuickFill({
    required int edad,
    required String sexo,
    required String raza,
  }) {
    for (var i = 0; i < bovinosRepo.length; i++) {
      final bovino = bovinosRepo[i];
      final updated = BovinoRepo(
        arete: bovino.arete,
        edad: edad,
        sexo: sexo,
        raza: raza,
        traza: bovino.traza,
        estadoArete: bovino.estadoArete,
        fechaNacimiento: bovino.fechaNacimiento,
        areteAnterior: bovino.areteAnterior,
        fotoArete: bovino.fotoArete,
        areteMadre: bovino.areteMadre,
        aretePadre: bovino.aretePadre,
        regMadre: bovino.regMadre,
        regPadre: bovino.regPadre,
        repoEntregaId: bovino.repoEntregaId, repoId: '',
      );
      bovinosRepo[i] = updated;
      bovinosBox.put(updated.id, updated);
    }
    Get.snackbar(
      'Llenado Rápido',
      'Se aplicaron los valores a todos los bovinos',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> saveBovino(BovinoRepo bovino) async {
    try {
      isLoading.value = true;
      
      // Si el arete está dañado, requerir foto
      if (bovino.estadoArete == 'Dañado' && bovino.fotoArete.isEmpty) {
        Get.snackbar('Error', 'Debe tomar una foto del arete dañado');
        return;
      }

      // Guardar el bovino
      await bovinosBox.put(bovino.id, bovino);
      bovinosRepo.add(bovino);

      // Verificar si ya se completaron todos los bovinos
      if (bovinosRepo.length == repoEntrega.value?.cantidad) {
        await _completarReposicion();
      }

      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Error al guardar el bovino: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _completarReposicion() async {
    if (repoEntrega.value == null) return;

    try {
      // Actualizar RepoEntrega
      final updatedRepo = repoEntrega.value!.copyWith(
        estadoRepo: 'Completada',
      );
      await repoBox.put(updatedRepo.idRepo, updatedRepo);
      repoEntrega.value = updatedRepo;

      // Actualizar la entrega original
      if (entrega.value != null) {
        final updatedEntrega = entrega.value!.copyWith(
          estadoReposicion: 'completada',
          idReposicion: updatedRepo.idRepo,
        );
        await entregasBox.put(updatedEntrega.entregaId, updatedEntrega);
        entrega.value = updatedEntrega;
      }

      Get.snackbar(
        'Éxito',
        'Reposición completada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error al completar reposición: $e');
      Get.snackbar(
        'Error',
        'No se pudo completar la reposición',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _validateForm() {
    isValid.value = fotoBovInicial.value.isNotEmpty &&
        fotoBovFinal.value.isNotEmpty &&
        fotoFicha.value.isNotEmpty &&
        observacionesController.text.trim().isNotEmpty;
  }

  Future<void> pickImageUniversal({required String target}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );

      if (image == null) return;

      final String base64Image = await Utils.imageToBase64(image.path);

      switch (target) {
        case 'inicial':
          fotoBovInicial.value = base64Image;
          break;
        case 'final':
          fotoBovFinal.value = base64Image;
          break;
        case 'ficha':
          fotoFicha.value = base64Image;
          break;
      }
    } catch (e) {
      print('❌ Error al tomar foto: $e');
      Get.snackbar('Error', 'No se pudo tomar la foto');
    }
  }

  Future<void> guardarReposicion() async {
    try {
      isLoading.value = true;

      if (entrega.value == null) {
        throw Exception('No se encontró la entrega original');
      }

      final config = configBox.values.first;
      final uniqueRepoId = DateTime.now().millisecondsSinceEpoch.toString();

      // Crear RepoEntrega primero
      final repoEntrega = RepoEntrega(
        idRepo: uniqueRepoId,
        entregaIdOrigen: entrega.value!.entregaId,
        cupa: entrega.value!.cupa,
        cue: entrega.value!.cue,
        departamento: entrega.value!.departamento,
        municipio: entrega.value!.municipio,
        latitud: entrega.value!.latitud,
        longitud: entrega.value!.longitud,
        distanciaCalculada: entrega.value!.distanciaCalculada,
        fechaRepo: DateTime.now(),
        token: config.imei,
        pdfEvidencia: fotoFicha.value,
        observaciones: observacionesController.text.trim(),
        detalleBovinos: [],  // Se llenará después
        estadoRepo: 'Lista',
        fotoBovInicial: fotoBovInicial.value,
        fotoBovFinal: fotoBovFinal.value,
        fotoFicha: fotoFicha.value,
        codhabilitado: config.codHabilitado,
        idorganizacion: config.idOrganizacion,
        rangoInicialRepo: rangoInicial.value,
        rangoFinalRepo: rangoFinal.value,
      );

      // Guardar RepoEntrega primero para obtener su ID
      await repoBox.put(uniqueRepoId, repoEntrega);

      // Crear lista de bovinos para reposición
      final detalleBovinos = List.generate(
        cantidad.value,
        (index) {
          final nuevoArete = (rangoInicial.value + index).toString();
          // El areteAnterior será el arete original que se está reemplazando
          final areteAnterior = (entrega.value!.rangoInicial + index).toString();
          
          return BovinoRepo(
            arete: nuevoArete,
            areteAnterior: areteAnterior,
            sexo: '',
            raza: '',
            edad: 0,
            traza: 'CRUCE',
            estadoArete: 'Bueno',
            fechaNacimiento: DateTime.now(),
            repoEntregaId: uniqueRepoId,
            repoId: uniqueRepoId,
          );
        },
      );

      // Actualizar RepoEntrega con la lista de bovinos
      final repoEntregaActualizada = repoEntrega.copyWith(
        detalleBovinos: detalleBovinos,
      );
      await repoBox.put(uniqueRepoId, repoEntregaActualizada);

      // Preparar datos para envío al servidor
      final datosEnvio = repoEntregaActualizada.toJsonEnvio();
      print('📦 Datos para envío: $datosEnvio');

      // Actualizar estado de reposición en la entrega original
      final entregaActualizada = entrega.value!.copyWith(
        estadoReposicion: 'completada',
        idReposicion: uniqueRepoId,
      );
      await entregasBox.put(entrega.value!.entregaId, entregaActualizada);

      Get.snackbar(
        'Éxito',
        'Reposición guardada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed('/home');
    } catch (e) {
      print('❌ Error al guardar reposición: $e');
      Get.snackbar(
        'Error',
        'No se pudo guardar la reposición',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    observacionesController.dispose();
    pageController.dispose();
    super.onClose();
  }
} 