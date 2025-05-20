import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Ejemplo con image_picker
import 'package:image_picker/image_picker.dart';

// Ejemplo con file_picker
import 'package:file_picker/file_picker.dart';

import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/data/local/models/altaentrega/altaentrega.dart';
import 'package:trazaapp/data/local/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/local/models/bovinos/bovino.dart';
import 'package:trazaapp/data/local/models/entregas/entregas.dart';
import 'package:trazaapp/data/local/models/razas/raza.dart';
import 'package:trazaapp/presentation/widgets/custom_saving.dart';
import 'package:trazaapp/utils/utils.dart';

class FormBovinosController extends GetxController {
  var currentPage = 0.obs;
  var bovinoInfo = <String, Bovino>{}.obs;
  PageController pageController = PageController();
  var sendingData = false.obs;

  // Para llenado rápido
  var quickFillEdad = ''.obs;
  var quickFillSexo = ''.obs;
  var quickFillRaza = ''.obs;

  late Box<Bovino> bovinoBox;
  late Box<Entregas> entregasBox;
  late Box<AltaEntrega> altaEntregaBox;
  late String entregaId;
  var rangos = <String>[].obs;
  var razas = <Raza>[].obs;

  // Fotos finales (obligatorias)
  var fotoBovInicial = ''.obs;
  var fotoBovFinal = ''.obs;

  // PDF de la ficha (obligatorio)
  var fotoFicha = ''.obs;

  // Observaciones (opcional)
  var observaciones = ''.obs;
  var pdfFileName = ''.obs; // Nombre del PDF

  final catalogosController = Get.find<CatalogosController>();
  final CatalogosController catController = Get.put(CatalogosController());

  @override
  void onInit() async {
    super.onInit();
    try {
      bovinoBox = await Hive.box<Bovino>('bovinos');
      entregasBox = await Hive.box<Entregas>('entregas');
      altaEntregaBox = await Hive.box<AltaEntrega>('altaentregas');

      razas.assignAll(catalogosController.razas);
      if (razas.isEmpty) {
        Get.snackbar(
          'Catálogo vacío',
          'Debe descargar el catálogo de razas antes de continuar.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        Future.delayed(const Duration(seconds: 3), () {
          Get.offAllNamed('/home');
        });
        return;
      }

      final args = Get.arguments as Map<String, dynamic>?;
      if (args == null) {
        throw Exception('Argumentos no proporcionados.');
      }

      if (!args.containsKey('aretes') || args['aretes'] is! List) {
        throw Exception(
            'Argumento "aretes" (List<String>) no proporcionado o no es una lista.');
      }
      final List<dynamic> aretesDynamic = args['aretes'] as List<dynamic>;
      final List<String> aretesRecibidos =
          aretesDynamic.map((e) => e.toString()).toList();
      rangos.assignAll(aretesRecibidos);

      final entregaArg = args['entrega'] as Entregas?;
      if (entregaArg == null) {
        throw Exception('Argumento "entrega" no proporcionado.');
      }
      entregaId = entregaArg.entregaId;

      for (var id in rangos) {
        bovinoInfo[id] = Bovino(
          arete: id,
          edad: 0,
          sexo: '',
          estadoArete: 'Bueno',
          cue: entregaArg.cue,
          cupa: entregaArg.cupa,
          traza: 'CRUCE',
          entregaId: entregaId,
          fotoArete: '',
          areteMadre: '',
          aretePadre: '',
          regMadre: '',
          regPadre: '',
          razaId: '',
        );
      }
      print(
          "🐄 FormBovinosController inicializado con ${rangos.length} aretes exactos.");
    } catch (e) {
      print('Error al inicializar FormBovinosController: $e');
    }
  }

  void nextPage() {
    if (currentPage.value < bovinoInfo.keys.length - 1) {
      currentPage.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void applyQuickFill() {
    bovinoInfo.forEach((key, bovino) {
      final edad = int.tryParse(quickFillEdad.value) ?? bovino.edad;
      final razaValida = razas.any((r) => r.id == quickFillRaza.value)
          ? quickFillRaza.value
          : '';

      final updatedBovino = bovino.copyWith(
        edad: quickFillEdad.value.isNotEmpty ? edad : bovino.edad,
        sexo:
            quickFillSexo.value.isNotEmpty ? quickFillSexo.value : bovino.sexo,
        razaId: razaValida,
      );
      bovinoInfo[key] = updatedBovino;
    });
    update();
  }

  void clearQuickFill() {
    quickFillEdad.value = '';
    quickFillSexo.value = '';
    quickFillRaza.value = '';
    bovinoInfo.values.forEach((bovino) {
      bovino.edad = 0;
      bovino.sexo = '';
      bovino.razaId = '';
    });
    Get.snackbar('Llenado Rápido', 'Datos borrados correctamente.');
  }

  /// Generar un código único de 5 caracteres para `idAlta`
  String generateUniqueAltaId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(
      5,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  /// ================
  ///   VALIDACIÓN
  /// ================
  /// Revisa si todo lo obligatorio está presente
  bool validateBeforeSave() {
    // 1) Foto inicial y final
    if (fotoBovInicial.value.isEmpty) {
      Get.snackbar(
        'Falta información',
        'Debes tomar la foto inicial antes de finalizar',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (fotoBovFinal.value.isEmpty) {
      Get.snackbar(
        'Falta información',
        'Debes tomar la foto final antes de finalizar',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // 2) PDF de la ficha
    if (fotoFicha.value.isEmpty) {
      Get.snackbar(
        'Falta documento',
        'Debes adjuntar el PDF de la ficha antes de finalizar',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // 3) Revisar cada bovino
    for (var bovino in bovinoInfo.values) {
      // Hallar índice de la página en PageView
      final index = rangos.indexOf(bovino.arete);

      // Si el arete está "Bueno", se exigen edad, sexo, raza
      if (bovino.estadoArete == 'Bueno') {
        if (bovino.edad <= 0) {
          _showErrorAndJumpToPage(
            'Falta la edad en el bovino ${bovino.arete}',
            index,
          );
          return false;
        }
        if (bovino.sexo.isEmpty) {
          _showErrorAndJumpToPage(
            'Falta el sexo en el bovino ${bovino.arete}',
            index,
          );
          return false;
        }
        if (bovino.razaId.isEmpty) {
          _showErrorAndJumpToPage(
            'Falta la raza en el bovino ${bovino.arete}',
            index,
          );
          return false;
        }

        // Si la traza es PURO => areteMadre y aretePadre obligatorios
        if (bovino.traza == 'PURO') {
          if (bovino.areteMadre.isEmpty) {
            _showErrorAndJumpToPage(
              'Bovino ${bovino.arete} es PURO: falta arete de madre.',
              index,
            );
            return false;
          }
          if (bovino.aretePadre.isEmpty) {
            _showErrorAndJumpToPage(
              'Bovino ${bovino.arete} es PURO: falta arete de padre.',
              index,
            );
            return false;
          }
        }
      } else {
        // Arete "Dañado" o "Perdido" => solo exigir fotoArete
        if (bovino.fotoArete.isEmpty) {
          _showErrorAndJumpToPage(
            'El bovino con arete ${bovino.arete} está ${bovino.estadoArete} y requiere foto del arete.',
            index,
          );
          return false;
        }
      }
    }
    return true; // Si pasa todo, estamos bien
  }

  void _showErrorAndJumpToPage(String message, int pageIndex) {
    // Saltamos a la página de ese bovino
    currentPage.value = pageIndex;
    pageController.jumpToPage(pageIndex);

    // Mostramos el error
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Llamado cuando estás en la última pantalla y quieres guardar todo
  Future<void> saveFinalData() async {
    // Si ya estamos enviando datos, no permitir otro envío
    if (sendingData.value) {
      return;
    }

    try {
      sendingData.value = true;
      
      // Primero, validamos
      if (!validateBeforeSave()) {
        sendingData.value = false;
        return;
      }

      final entrega = entregasBox.values.firstWhere(
        (e) => e.entregaId == entregaId,
        orElse: () => throw Exception('Entrega no encontrada.'),
      );

      // Config
      final configBox = Hive.box<AppConfig>('appConfig');
      final config = configBox.get('config');
      if (config == null) {
        throw Exception('No se encontró la configuración del usuario.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        entrega.latitud,
        entrega.longitud,
      );
      final distanciaCalculada = distance.toStringAsFixed(2);

      // Generar un ID único
      final uniqueAltaId = generateUniqueAltaId();

      // Crear lista de BovinoResumen
      final detalleBovinos = bovinoInfo.values.map((bovino) {
        return BovinoResumen(
          arete: bovino.arete,
          edad: bovino.edad,
          sexo: bovino.sexo,
          raza: bovino.razaId,
          traza: bovino.traza,
          estadoArete: bovino.estadoArete,
          fechaNacimiento:
              DateTime.now().subtract(Duration(days: bovino.edad * 30)),
          fotoArete: bovino.fotoArete,
          areteMadre: bovino.areteMadre,
          aretePadre: bovino.aretePadre,
          regMadre: bovino.regMadre,
          regPadre: bovino.regPadre,
          motivoEstadoAreteId: bovino.estadoArete == 'Dañado'
              ? '249'
              : (bovino.estadoArete == 'No Utilizado' ? '-1' : '0'),
        );
      }).toList();

      // Crear AltaEntrega
      final altaEntrega = AltaEntrega(
        idAlta: uniqueAltaId,
        rangoInicial: entrega.rangoInicial,
        rangoFinal: entrega.rangoFinal,
        rangoInicialExt: entrega.rangoInicialExt ?? '',
        rangoFinalExt: entrega.rangoFinalExt ?? '',
        cupa: entrega.cupa,
        cue: entrega.cue,
        departamento: entrega.departamento,
        municipio: entrega.municipio,
        latitud: position.latitude,
        longitud: position.longitude,
        distanciaCalculada: distanciaCalculada,
        fechaAlta: DateTime.now(),
        tipoAlta: config.habilitadoOperadora == "0" ? "1" : "2",
        aplicaEntrega: entrega.tipo == 'manual',
        token: config.imei,
        codhabilitado: config.codHabilitado,
        idorganizacion: config.idOrganizacion,
        fotoBovInicial: fotoBovInicial.value,
        fotoBovFinal: fotoBovFinal.value,
        fotoFicha: fotoFicha.value,
        reposicion: false,
        observaciones: observaciones.value,
        detalleBovinos: detalleBovinos,
        estadoAlta: 'Lista',
      );

      // Guardar en Hive
      await altaEntregaBox.put(uniqueAltaId, altaEntrega);

      // Actualizar la entrega
      final entregaActualizada = entrega.copyWith(
        estado: 'altalista',
        idAlta: uniqueAltaId,
      );
      await entregasBox.put(entregaId, entregaActualizada);

      // Refrescar
      final entregaController = Get.find<EntregaController>();
      await entregaController.fetchEntregas();
      entregaController.cargarAltasListas();

      Get.snackbar(
        'Éxito',
        'Información registrada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', 'Error al guardar AltaEntrega: $e');
      print('❌ Error en saveFinalData: $e');
      throw e; // Re-lanzar excepción para que sea capturada por la vista
    } finally {
      sendingData.value = false;
    }
  }

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
          final oldBov = bovinoInfo[bovinoID]!;
          final newBov = oldBov.copyWith(fotoArete: base64String);
          bovinoInfo[bovinoID] = newBov;
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

      // Get.snackbar('OK', 'Foto seleccionada correctamente para $target.');
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar('Error', 'No se pudo seleccionar la foto para $target.');
    }
  }

  // ===============================
  // Seleccionar PDF (fotoFicha)
  // ===============================
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

      if (fileSizeInMB > 5) {
        // Si el archivo es mayor a 5MB
        Get.snackbar(
          'Error',
          'El archivo PDF es muy grande (${fileSizeInMB.toStringAsFixed(2)}MB). El tamaño máximo permitido es 5MB.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      } else if (fileSizeInMB > 2) {
        // Advertencia para archivos entre 2MB y 5MB
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
      //   Get.snackbar('OK', 'PDF seleccionado: ${pdfFileName.value}');
    } catch (e) {
      print('Error picking PDF: $e');
      Get.snackbar('Error', 'No se pudo seleccionar el PDF.');
    }
  }
}
