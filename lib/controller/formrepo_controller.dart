import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/data/models/repo/repoentrega.dart';
import 'package:trazaapp/data/models/repo/bovinorepo.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/models/razas/raza.dart';
import 'package:trazaapp/data/models/altaentrega/altaentrega.dart';
import 'package:trazaapp/data/models/bovinos/bovino.dart';
import 'package:trazaapp/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:trazaapp/data/repositories/reposicion/reposicion_repo.dart';

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
  
  // Variable para manejar errores
  final error = Rxn<String>();

  // Controladores
  final observacionesController = TextEditingController();

  // Agregar la propiedad pdfFileName
  final RxString pdfFileName = ''.obs;

  // --- Nuevas variables para el resumen ---
  final repoParaResumen = Rxn<RepoEntrega>();

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      error.value = null;
      
      entregasBox = Hive.box<Entregas>('entregas');
      repoBox = Hive.box<RepoEntrega>('repoentregas');
      bovinosBox = Hive.box<BovinoRepo>('bovinosrepo');
      razasBox = Hive.box<Raza>('razas');
      configBox = Hive.box<AppConfig>('appconfig');

      // Obtener IDs de los argumentos
      final Map<String, dynamic> args = Get.arguments ?? {};
      entregaId = args['entregaId'] as String?;
      
      // Para una nueva reposición, generamos un ID único si no viene uno
      repoId = args['repoId'] as String? ?? 
               'repo_${DateTime.now().millisecondsSinceEpoch}';

      if (entregaId == null) {
        error.value = 'No se proporcionó el ID de entrega';
        isLoading.value = false;
        // Usamos microtask para mostrar el snackbar fuera del ciclo de build
        Future.microtask(() => _showErrorAndNavigateBack(error.value!));
        return;
      }

      // Cargar razas
      razas.value = razasBox.values.toList();

      // Cargar datos de la entrega
      final entregaData = entregasBox.get(entregaId);
      if (entregaData == null) {
        error.value = 'No se encontró la entrega con ID: $entregaId';
        isLoading.value = false;
        Future.microtask(() => _showErrorAndNavigateBack(error.value!));
        return;
      }
      
      entrega.value = entregaData;
      
      // Obtener rangos de los argumentos o usar los de la entrega
      rangoInicial.value = args['rangoInicial'] as int? ?? (entregaData.rangoFinal + 1);
      cantidad.value = args['cantidad'] as int? ?? entregaData.cantidad;
      rangoFinal.value = rangoInicial.value + cantidad.value - 1;
      
      // Crear bovinos para la reposición
      await _createBovinos();

      // Cargar bovinos de la reposición
      bovinosRepo.value = bovinosBox.values
          .where((bovino) => bovino.repoId == repoId)
          .toList();

      if (bovinosRepo.isEmpty) {
        error.value = 'Error al crear bovinos para reposición';
        isLoading.value = false;
        Future.microtask(() => _showErrorAndNavigateBack(error.value!));
        return;
      }

      // Observar cambios para validación
      ever(fotoBovInicial, (_) => _validateForm());
      ever(fotoBovFinal, (_) => _validateForm());
      ever(fotoFicha, (_) => _validateForm());

      observacionesController.addListener(() {
        _validateForm();
      });

    } catch (e) {
      error.value = 'Error al cargar los datos: ${e.toString()}';
      // Usamos microtask para mostrar el snackbar fuera del ciclo de build
      Future.microtask(() => _showErrorAndNavigateBack(error.value!));
    } finally {
      isLoading.value = false;
    }
  }
  
  // Método para mostrar error y navegar hacia atrás
  void _showErrorAndNavigateBack(String errorMessage) {
    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
    
    // Pequeña pausa antes de navegar hacia atrás
    Future.delayed(const Duration(milliseconds: 500), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.back();
    });
  }
  
  // Crear bovinos para la reposición
  Future<void> _createBovinos() async {
    try {
      // Creamos un arreglo con los bovinos para reposición
      final List<BovinoRepo> bovinosToCreate = [];
      
      for (int i = 0; i < cantidad.value; i++) {
        final areteNum = rangoInicial.value + i;
        final areteAnterior = '';
        
        final bovino = BovinoRepo(
          arete: areteNum.toString(),
          areteAnterior: areteAnterior,
          sexo: '',
          razaId: '',
          edad: 0,
          traza: 'CRUCE',
          estadoArete: 'Bueno',
          motivoEstadoAreteId: "0", // Explícitamente "0" para estado "Bueno"
          fechaNacimiento: DateTime.now(),
          repoEntregaId: repoId!,
          repoId: repoId!,
        );
        
        bovinosToCreate.add(bovino);
      }
      
      // Guardamos los bovinos en la base de datos
      for (final bovino in bovinosToCreate) {
        await bovinosBox.put(bovino.id, bovino);
      }
      
    } catch (e) {
      print('Error al crear bovinos: $e');
      rethrow;
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
    if (index >= 0 && index < bovinosRepo.length) {
      final bovino = bovinosRepo[index];
      bovinosRepo[index] = bovino.copyWith(areteAnterior: value);
      update(); // Force UI update
    }
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
    final updated = bovino.copyWith(razaId: value);
    bovinosBox.put(bovino.arete, updated);
    bovinosRepo[index] = updated;
  }

  void updateTraza(int index, String value) {
    final bovino = bovinosRepo[index];
    final updated = bovino.copyWith(
      traza: value,
      areteMadre: value != 'PURO' ? '' : bovino.areteMadre,
      aretePadre: value != 'PURO' ? '' : bovino.aretePadre,
      regMadre: value != 'PURO' ? '' : bovino.regMadre,
      regPadre: value != 'PURO' ? '' : bovino.regPadre,
    );
    bovinosRepo[index] = updated;
  }

  void updateEstadoArete(int index, String value) {
    final bovino = bovinosRepo[index];
    final updated = bovino.copyWith(
      estadoArete: value,
      motivoEstadoAreteId: value == 'Dañado' ? "249" : "0",
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
      // Asegurar que motivoEstadoAreteId concuerde con estadoArete
      final motivoId = bovino.estadoArete == 'Dañado' ? "249" : "0";
      
      final updated = BovinoRepo(
        arete: bovino.arete,
        edad: edad,
        sexo: sexo,
        razaId: raza,
        traza: bovino.traza,
        estadoArete: bovino.estadoArete,
        motivoEstadoAreteId: motivoId, // Usar el valor correcto según estadoArete
        fechaNacimiento: bovino.fechaNacimiento,
        areteAnterior: bovino.areteAnterior,
        fotoArete: bovino.fotoArete,
        areteMadre: bovino.areteMadre,
        aretePadre: bovino.aretePadre,
        regMadre: bovino.regMadre,
        regPadre: bovino.regPadre,
        repoEntregaId: bovino.repoEntregaId,
        repoId: bovino.repoId,
      );
      bovinosRepo[i] = updated;
      bovinosBox.put(updated.id, updated);
    }
    update();
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

      // Asegurar que motivoEstadoAreteId sea coherente con estadoArete
      final motivoId = bovino.estadoArete == 'Dañado' ? "249" : "0";
      final bovinoActualizado = bovino.copyWith(motivoEstadoAreteId: motivoId);

      // Guardar el bovino
      await bovinosBox.put(bovinoActualizado.id, bovinoActualizado);
      bovinosRepo.add(bovinoActualizado);

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

  // Método para seleccionar imágenes
  Future<void> pickImageUniversal({
    required String target, // 'arete', 'inicial', 'final'
    String? bovinoID,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();

      // Diálogo para elegir cámara o galería
      final source = await Get.dialog<ImageSource?>(
        AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: const Text('¿Cómo deseas obtener la imagen?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: ImageSource.camera),
              child: const Text('Cámara'),
            ),
            TextButton(
              onPressed: () => Get.back(result: ImageSource.gallery),
              child: const Text('Galería'),
            ),
          ],
        ),
      );
      if (source == null) return; // usuario canceló

      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 30, // Calidad de imagen reducida
        maxWidth: 800, // Ancho máximo
        maxHeight: 800, // Alto máximo
      );
      
      if (pickedFile == null) return; // no se seleccionó nada

      // Usar la nueva función de compresión
      final base64String = await Utils.imageToBase64(pickedFile.path);

      // Dependiendo del target, asignamos
      switch (target) {
        case 'arete':
          if (bovinoID == null) {
            throw Exception('BovinoID es requerido para target=arete');
          }
          final oldBov = bovinosRepo[int.parse(bovinoID)];
          final newBov = oldBov.copyWith(fotoArete: base64String);
          bovinosRepo[int.parse(bovinoID)] = newBov;
          break;

        case 'inicial':
          fotoBovInicial.value = base64String;
          break;

        case 'final':
          fotoBovFinal.value = base64String;
          break;

        default:
          throw Exception('target inválido: $target');
      }

    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar('Error', 'No se pudo seleccionar la foto para $target.');
    }
  }

  // Método para seleccionar PDF
  Future<void> pickPdfFicha() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.isEmpty) {
        return; // usuario canceló
      }

      final filePath = result.files.single.path;
      if (filePath == null) return;

      // Tomamos el nombre del archivo
      pdfFileName.value = result.files.single.name;

      // Usar el nuevo método de compresión
      final file = File(filePath);
      final compressedBase64 = await Utils.pdfToCompressedBase64(file);
      
      if (compressedBase64 == null) {
        Get.snackbar(
          'Error',
          'El archivo PDF es demasiado grande. Por favor, usa un PDF más pequeño o comprímelo manualmente.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Asignar el valor comprimido
      fotoFicha.value = compressedBase64;
      
      // Validar el formulario después de actualizar
      _validateForm();
      
    } catch (e) {
      print('Error picking PDF: $e');
      Get.snackbar('Error', 'No se pudo seleccionar el PDF: ${e.toString()}');
    }
  }

  // --- Método para cargar datos para el resumen --- 
  Future<void> cargarDatosParaResumen(String repoId) async {
     try {
        isLoading.value = true;
        // Asegurarse que las cajas estén abiertas (podrían estar cerradas si vienes de otra pantalla)
        if (!repoBox.isOpen) repoBox = await Hive.openBox<RepoEntrega>('repoentregas');
        if (!bovinosBox.isOpen) bovinosBox = await Hive.openBox<BovinoRepo>('bovinosrepo');
        
        final repo = repoBox.get(repoId);
        if (repo == null) {
          throw Exception('No se encontró la reposición con ID $repoId');
        }
        // Cargar también los bovinos asociados a esa reposición
        final bovinosDelRepo = bovinosBox.values.where((b) => b.repoId == repoId).toList();
        repoParaResumen.value = repo.copyWith(detalleBovinos: bovinosDelRepo);
     } catch(e) {
        print('Error cargando datos para resumen: $e');
        Get.snackbar('Error', 'No se pudieron cargar los datos para el resumen: $e');
        repoParaResumen.value = null; // Limpiar en caso de error
     } finally {
        isLoading.value = false;
     }
  }

  // --- guardarReposicion Modificado --- 
  Future<void> guardarReposicion() async {
      isLoading.value = true;
    try {
      if (entrega.value == null || repoId == null) {
        throw Exception('Datos de entrega o ID de reposición no disponibles');
      }

      final config = configBox.values.first;

      // 1. Crear/Actualizar RepoEntrega con estado 'Lista'
      final repoFinal = RepoEntrega(
        idRepo: repoId!, // Usar el ID existente o generado en onInit
        entregaIdOrigen: entrega.value!.entregaId,
        cupa: entrega.value!.cupa,
        cue: entrega.value!.cue,
        departamento: entrega.value!.departamento,
        municipio: entrega.value!.municipio,
        latitud: entrega.value!.latitud, // Usar lat/lon de la entrega original
        longitud: entrega.value!.longitud,
        distanciaCalculada: entrega.value!.distanciaCalculada,
        fechaRepo: DateTime.now(), // Fecha actual de guardado
        token: config.imei,
        codhabilitado: config.codHabilitado,
        idorganizacion: config.idOrganizacion,
        fotoBovInicial: fotoBovInicial.value,
        fotoBovFinal: fotoBovFinal.value,
        fotoFicha: fotoFicha.value,
        pdfEvidencia: fotoFicha.value, // Asumiendo que fotoFicha es la evidencia PDF
        observaciones: observacionesController.text.trim(),
        // Usar los bovinos actualizados en el controlador
        detalleBovinos: bovinosRepo.map((bov) => bov.copyWith(repoId: repoId, repoEntregaId: repoId)).toList(), 
        estadoRepo: 'Lista', // Marcar como lista para enviar
        rangoInicialRepo: rangoInicial.value,
        rangoFinalRepo: rangoFinal.value,
      );

      // 2. Guardar RepoEntrega y sus BovinoRepo asociados
      await repoBox.put(repoId!, repoFinal);
      // Guardar/Actualizar cada bovino asociado en su propia caja
      for (final bovino in repoFinal.detalleBovinos) {
        // Asegurar que los IDs de relación estén correctos antes de guardar
        final bovinoActualizado = bovino.copyWith(repoId: repoId, repoEntregaId: repoId);
        await bovinosBox.put(bovinoActualizado.id, bovinoActualizado);
      }

      // 3. NO actualizamos la entrega original aquí
      // La actualización a 'completada' se hará al "enviar" desde la pantalla de SendRepoView

      Get.snackbar(
        'Guardado',
        'Reposición guardada y lista para enviar.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navegar a la pantalla de envío de reposiciones
      Get.offNamed('/sendrepo');

    } catch (e) {
      print('❌ Error al guardar reposición: $e');
      Get.snackbar(
        'Error',
        'No se pudo guardar la reposición: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> enviarReposicion(String repoId) async {
    final envioReposicionRepository = EnvioReposicionRepository();
    final repo = repoBox.get(repoId);
    if (repo == null) {
      Get.snackbar('Error', 'No se encontró la reposición con ID: $repoId');
      return;
    }
    await envioReposicionRepository.enviarReposicion(repo.toJsonEnvio());
  }

  @override
  void onClose() {
    observacionesController.dispose();
    pageController.dispose();
    super.onClose();
  }
} 