import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AreteInputController extends GetxController {
  final areteController = TextEditingController();
  final RxBool isScanned = false.obs;

  void setArete(String value, {bool scanned = false}) {
    areteController.text = value;
    isScanned.value = scanned;
  }

  void clear() {
    if (areteController.hasListeners) {
      areteController.clear();
    }
    isScanned.value = false;
  }

  @override
  void onClose() {
    // No dispondremos el controlador aquí para evitar el error
    // areteController.dispose();
    super.onClose();
  }

  Future<void> escanearArete() async {
    try {
      final result = await Get.toNamed('/scanner');
      if (result != null) {
        setArete(result, scanned: true);
        Get.snackbar('Éxito', 'Arete escaneado correctamente', backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al escanear arete: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
} 