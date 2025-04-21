import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:trazaapp/data/models/baja/baja_model.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/models/establecimiento/establecimiento.dart';
import 'package:trazaapp/data/models/productores/productor.dart';
import 'package:trazaapp/utils/utils.dart';

class BajaController extends GetxController {
  final areteController = TextEditingController();
  final motivoController = TextEditingController();
  final cueController = TextEditingController();
  final cupaController = TextEditingController();
  final fechaBajaController = TextEditingController();
  final evidenciaController = TextEditingController();

  final RxBool isAreteScanned = false.obs;
  final RxString selectedMotivo = ''.obs;
  final Rx<DateTime> fechaBaja = DateTime.now().obs;
  final RxString evidenciaBase64 = ''.obs;
  final RxString tipoEvidencia = ''.obs;
  final RxString pdfFileName = ''.obs;
  final RxString evidenciaFileName = ''.obs;
  final RxBool isLoading = true.obs;

  late Box<Baja> bajaBox;
  late Box<AppConfig> configBox;
  late Box<Establecimiento> establecimientoBox;
  late Box<Productor> productorBox;

  final List<String> motivos = [
    'Muerte natural',
    'Sacrificio',
    'Enfermedad',
    'Accidente',
    'Otro'
  ];

  final RxList<Baja> bajasPendientes = <Baja>[].obs;
  final RxBool isInitialized = false.obs;

  @override
  void onInit() async {
    super.onInit();
    
    isLoading.value = true; // Iniciar cargando
    
    try {
      print('🔄 Inicializando BajaController...');
      // Inicializar las cajas de Hive
      bajaBox = await Hive.openBox<Baja>('bajas');
      configBox = await Hive.openBox<AppConfig>('appConfig');
      establecimientoBox = await Hive.openBox<Establecimiento>('establecimientos');
      productorBox = await Hive.openBox<Productor>('productores');
      
      // Configurar la fecha inicial
      fechaBajaController.text = _formatDate(fechaBaja.value);
      
      isInitialized.value = true;
      print('✅ BajaController inicializado correctamente');
      
      // Cargar bajas pendientes una vez que todo está inicializado
      cargarBajasPendientes();
    } catch (e) {
      print('❌ Error al inicializar BajaController: $e');
      Future.microtask(() {
        Get.snackbar(
          'Error',
          'Error al inicializar el controlador: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    }
  }

  @override
  void onReady() {
    super.onReady();
    print('🔄 BajaController está listo');
    // No cargar bajas pendientes aquí, ya se hace en onInit después de la inicialización
  }

  @override
  void onClose() {
    areteController.dispose();
    motivoController.dispose();
    cueController.dispose();
    cupaController.dispose();
    fechaBajaController.dispose();
    evidenciaController.dispose();
    super.onClose();
  }

  String generateBajaId() {
    final random = Random();
    final number = random.nextInt(100000).toString().padLeft(5, '0');
    return 'ABJSO$number';
  }

  void setAreteScanned(bool value) {
    isAreteScanned.value = value;
  }

  void setMotivo(String value) {
    selectedMotivo.value = value;
  }

  void setFechaBaja(DateTime date) {
    fechaBaja.value = date;
    fechaBajaController.text = _formatDate(date);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> loadEvidencia() async {
    try {
      final tipo = await Get.dialog<String>(
        AlertDialog(
          title: const Text('Seleccionar tipo de evidencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () => Get.back(result: 'foto'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar foto'),
                onTap: () => Get.back(result: 'foto'),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Seleccionar PDF'),
                onTap: () => Get.back(result: 'pdf'),
              ),
            ],
          ),
        ),
      );

      if (tipo == null) return;

      tipoEvidencia.value = tipo;

      if (tipo == 'foto') {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 50,
        );

        if (image != null) {
          final String base64Image = await Utils.imageToBase64(image.path);
          evidenciaBase64.value = base64Image;
          tipoEvidencia.value = 'foto';
          evidenciaFileName.value = image.name;
          evidenciaController.text = image.name;
        }
      } else {
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
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cargar la evidencia: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool validateForm() {
    if (areteController.text.isEmpty) {
      Get.snackbar('Error', 'El arete es obligatorio');
      return false;
    }
    if (selectedMotivo.value.isEmpty) {
      Get.snackbar('Error', 'El motivo es obligatorio');
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
      final config = configBox.get('config');
      if (config == null) {
        throw Exception('No se encontró la configuración del usuario.');
      }

      final baja = Baja(
        bajaId: generateBajaId(),
        arete: areteController.text,
        motivo: selectedMotivo.value,
        cue: cueController.text,
        cupa: cupaController.text,
        fechaRegistro: DateTime.now(),
        fechaBaja: fechaBaja.value,
        evidencia: evidenciaBase64.value,
        tipoEvidencia: tipoEvidencia.value,
        token: config.imei,
        codHabilitado: config.codHabilitado,
      );

      await bajaBox.add(baja);
      clearForm();
      
      Get.snackbar(
        'Éxito', 
        'Baja registrada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
      
      // Retraso mayor para permitir que todas las animaciones terminen antes de navegar
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.offAllNamed('/home'); // Usar offAllNamed para limpiar el stack de navegación
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
    areteController.clear();
    motivoController.clear();
    cueController.clear();
    cupaController.clear();
    fechaBajaController.clear();
    evidenciaController.clear();
    selectedMotivo.value = '';
    evidenciaBase64.value = '';
    tipoEvidencia.value = '';
    pdfFileName.value = '';
    evidenciaFileName.value = '';
    isAreteScanned.value = false;
    fechaBaja.value = DateTime.now();
    fechaBajaController.text = _formatDate(fechaBaja.value);
  }

  void cargarBajasPendientes() {
    if (!isInitialized.value) {
      print('⚠️ Intentando cargar bajas pendientes antes de inicializar. Operación ignorada.');
      return;
    }
    
    isLoading.value = true; // Iniciar carga
    
    try {
      // Verificar que bajaBox esté inicializada
      if (!bajaBox.isOpen) {
        print('❌ Error: bajaBox no está inicializada o no está abierta');
        isLoading.value = false; // Finalizar carga
        return;
      }
      
      final pendientes = bajaBox.values
          .where((baja) => baja.estado == 'pendiente')
          .toList();
           
      bajasPendientes.value = pendientes;
      
      print('📦 Bajas pendientes cargadas: ${bajasPendientes.length}');
      
      if (bajasPendientes.isEmpty) {
        print('⚠️ No hay bajas pendientes para enviar');
      }
    } catch (e) {
      print('❌ Error al cargar bajas pendientes: $e');
      // No usar Get.snackbar aquí para evitar errores durante la construcción
      // En su lugar, solo registrar el error
      Future.microtask(() {
        // Mostrar snackbar después del ciclo de construcción
        Get.snackbar(
          'Error',
          'Error al cargar bajas pendientes: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } finally {
      isLoading.value = false; // Finalizar carga sin importar si hay error
    }
  }

  Future<void> buscarEstablecimientoYProductor(String cue) async {
    final establecimiento = establecimientoBox.values
        .firstWhere((e) => e.establecimiento == cue,
            orElse: () => throw Exception('CUE no encontrado'));

    final productor = productorBox.values
        .firstWhere((p) => p.productor == establecimiento.productor,
            orElse: () => throw Exception('Productor no encontrado'));

    cueController.text = establecimiento.establecimiento;
    cupaController.text = productor.productor;
  }

  Future<void> escanearArete() async {
    try {
      final result = await Get.toNamed('/scanner');
      if (result != null) {
        areteController.text = result;
        setAreteScanned(true);
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

      // Simular retraso de red
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implementar el envío al backend
      // Por ahora, simulamos un envío exitoso cambiando el estado
      for (var i = 0; i < bajasPendientes.length; i++) {
        final baja = bajasPendientes[i];
        // Crear una nueva instancia con estado actualizado
        final bajaActualizada = baja.copyWith(estado: 'enviado');
        
        // Encontrar el índice en el Box de Hive
        final index = bajaBox.values.toList().indexWhere(
          (b) => b.bajaId == baja.bajaId
        );
        
        if (index != -1) {
          await bajaBox.putAt(index, bajaActualizada);
        }
      }
      
      Get.back(); // Cerrar el diálogo

      Get.snackbar(
        'Éxito', 
        'Bajas enviadas correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      cargarBajasPendientes();
    } catch (e) {
      Get.back(); // Cerrar el diálogo
      
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
} 