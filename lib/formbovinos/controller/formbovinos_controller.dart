import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class FormBovinosController extends GetxController {
  var currentPage = 0.obs;
  var bovinoInfo = <String, BovinoData>{}.obs;
  PageController pageController = PageController();

  var quickFillEdad = ''.obs;
  var quickFillSexo = ''.obs;
  var quickFillRaza = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    final rango = args['rango'];
    final rangos = calculateRangos(rango);

    for (var id in rangos) {
      bovinoInfo[id] = BovinoData(arete: id);
    }
  }

  List<String> calculateRangos(String rango) {
    final parts = rango.split('-');
    final start = int.tryParse(parts[0].substring(parts[0].length - 4)) ?? 0;
    final end = int.tryParse(parts[1].substring(parts[1].length - 4)) ?? 0;
    return List<String>.generate(end - start + 1, (index) {
      final id = start + index;
      return parts[0].substring(0, parts[0].length - 4) + id.toString().padLeft(4, '0');
    });
  }

  void nextPage() {
    final currentBovino = bovinoInfo.values.toList()[currentPage.value];
    if (currentBovino.areteColocado.value && 
        (currentBovino.edad.value.isEmpty || 
        currentBovino.sexo.value.isEmpty || 
        currentBovino.raza.value.isEmpty)) {
      Get.snackbar('Campos incompletos', 'Por favor, llena todos los campos antes de continuar.');
    } else {
      if (currentPage.value < bovinoInfo.keys.length - 1) {
        currentPage.value++;
        pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
      }
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
      pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void applyQuickFill() {
    bovinoInfo.values.forEach((bovino) {
      if (quickFillEdad.value.isNotEmpty) {
        bovino.edad.value = quickFillEdad.value;
      }
      if (quickFillSexo.value.isNotEmpty) {
        bovino.sexo.value = quickFillSexo.value;
      }
      if (quickFillRaza.value.isNotEmpty) {
        bovino.raza.value = quickFillRaza.value;
      }
    });
  }

  void clearQuickFill() {
    quickFillEdad.value = '';
    quickFillSexo.value = '';
    quickFillRaza.value = '';
    bovinoInfo.values.forEach((bovino) {
      bovino.edad.value = '';
      bovino.sexo.value = '';
      bovino.raza.value = '';
    });
  }
}

class BovinoData {
  BovinoData({required this.arete});
  final String arete;
  var edad = ''.obs;
  var sexo = ''.obs;
  var raza = ''.obs;
  var areteColocado = true.obs; // Default to true
}
