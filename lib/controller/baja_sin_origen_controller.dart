import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/bajasinorigen/baja_sin_origen.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';

class BajaSinOrigenController extends GetxController {
  final RxString arete = ''.obs;
  final RxString evidenciaBase64 = ''.obs;
  final RxBool isGpsEnabled = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkGpsStatus();
  }

  Future<void> checkGpsStatus() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      isGpsEnabled.value = serviceEnabled;
    } catch (e) {
      isGpsEnabled.value = false;
    }
  }

  String generateUniqueId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    final randomPart = List.generate(
      5,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
    return '${randomPart}_bso';
  }

  Future<Position?> getCurrentLocation() async {
    try {
      if (!isGpsEnabled.value) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  Future<bool> guardarBaja() async {
    print('🔄 Iniciando guardado de baja sin origen...');
    
    if (arete.value.isEmpty) {
      print('❌ Error: Arete vacío');
      Get.snackbar('Error', 'El arete es obligatorio', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (evidenciaBase64.value.isEmpty) {
      print('❌ Error: Sin evidencia');
      Get.snackbar('Error', 'La evidencia (foto) es obligatoria', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (!isGpsEnabled.value) {
      print('❌ Error: GPS desactivado');
      Get.snackbar('Error', 'El GPS debe estar activado', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    isLoading.value = true;
    print('⏳ Obteniendo ubicación...');

    try {
      final position = await getCurrentLocation();
      if (position == null) {
        print('❌ Error: No se pudo obtener la ubicación');
        Get.snackbar('Error', 'No se pudo obtener la ubicación', backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }

      // Obtener configuración de la app
      final configBox = Hive.box<AppConfig>('appConfig');
      final config = configBox.get('config');
      
      if (config == null) {
        print('❌ Error: No se encontró la configuración');
        Get.snackbar('Error', 'No se encontró la configuración de la app', backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }

      print('📝 Creando objeto BajaSinOrigen...');
      final baja = BajaSinOrigen(
        id: generateUniqueId(),
        arete: arete.value,
        latitud: position.latitude,
        longitud: position.longitude,
        fecha: DateTime.now(),
        motivo: 'sin origen',
        evidencia: evidenciaBase64.value,
        estado: 'pendiente',
        token: config.token,
        codHabilitado: config.codHabilitado,
        idorganizacion: config.idOrganizacion,
      );

      print('💾 Guardando en Hive...');
      // Guardar en Hive
      final box = Hive.box<BajaSinOrigen>('bajassinorigen');
      await box.put(baja.id, baja);
      
      print('✅ Baja guardada exitosamente');
      isLoading.value = false;
      return true;
    } catch (e) {
      print('❌ Error al guardar la baja: $e');
      isLoading.value = false;
      Get.snackbar('Error', 'Error al guardar la baja: $e', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }
} 