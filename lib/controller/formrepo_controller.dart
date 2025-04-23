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
        razaId: raza,
        traza: bovino.traza,
        estadoArete: bovino.estadoArete,
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

      // Leer el archivo PDF
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      // Verificar el tamaño del archivo
      final fileSizeInMB = bytes.length / (1024 * 1024);
      
      if (fileSizeInMB > 5) { // Si el archivo es mayor a 5MB
        Get.snackbar(
          'Error',
          'El archivo PDF es muy grande (${fileSizeInMB.toStringAsFixed(2)}MB). El tamaño máximo permitido es 5MB.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      } else if (fileSizeInMB > 2) { // Advertencia para archivos entre 2MB y 5MB
        Get.snackbar(
          'Advertencia',
          'El archivo PDF es grande (${fileSizeInMB.toStringAsFixed(2)}MB). Se recomienda comprimirlo manualmente antes de subirlo.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }

      // Convertir a base64
      final base64String = base64Encode(bytes);
      
      // Verificar el tamaño final después de la conversión
      final base64SizeInMB = base64String.length / (1024 * 1024);
      if (base64SizeInMB > 2.5) {
        Get.snackbar(
          'Error',
          'El archivo PDF es muy grande después de la conversión. Por favor, comprima el archivo antes de subirlo.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      fotoFicha.value = base64String;
    } catch (e) {
      print('Error picking PDF: $e');
      Get.snackbar('Error', 'No se pudo seleccionar el PDF.');
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
            razaId: '',
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

      // Crear AltaEntrega a partir de la reposición para que aparezca en la lista de altas pendientes
      try {
        // Usar el Box de AltaEntrega
        final altaEntregaBox = Hive.box<AltaEntrega>('altaentregas');
        
        // Convertir BovinoRepo a BovinoResumen para AltaEntrega
        final bovinosResumen = detalleBovinos.map((b) => BovinoResumen(
          arete: b.arete,
          edad: b.edad,
          sexo: b.sexo,
          raza: b.razaId,
          estadoArete: b.estadoArete,
          traza: b.traza,
          fechaNacimiento: b.fechaNacimiento,
          fotoArete: b.fotoArete,
          areteMadre: b.areteMadre,
          aretePadre: b.aretePadre,
          regMadre: b.regMadre,
          regPadre: b.regPadre,
        )).toList();
        
        // Crear una nueva alta con los datos de la reposición
        final altaEntrega = AltaEntrega(
          idAlta: uniqueRepoId,
          cupa: entrega.value!.cupa,
          cue: entrega.value!.cue,
          rangoInicial: rangoInicial.value,
          rangoFinal: rangoFinal.value,
          departamento: entrega.value!.departamento,
          municipio: entrega.value!.municipio,
          latitud: entrega.value!.latitud,
          longitud: entrega.value!.longitud,
          distanciaCalculada: entrega.value!.distanciaCalculada,
          fotoBovInicial: fotoBovInicial.value,
          fotoBovFinal: fotoBovFinal.value,
          fotoFicha: fotoFicha.value,
          fechaAlta: DateTime.now(),
          observaciones: observacionesController.text.trim(),
          estadoAlta: 'Lista',
          token: config.imei,
          tipoAlta: 'Reposición', // Indicar que es reposición
          codhabilitado: config.codHabilitado,
          idorganizacion: config.idOrganizacion,
          reposicion: true,
          detalleBovinos: bovinosResumen,
          aplicaEntrega: true, // Asumimos que aplica la entrega
        );
        
        // Guardar el alta
        await altaEntregaBox.put(uniqueRepoId, altaEntrega);
        print('✅ Alta de reposición creada con ID: $uniqueRepoId');
      } catch (e) {
        print('⚠️ Error al crear alta de reposición: $e');
        // Continuar con el flujo aunque falle la creación del alta
      }

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