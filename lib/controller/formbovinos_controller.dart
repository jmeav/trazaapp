import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/data/models/bovino/bovino.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';

class FormBovinosController extends GetxController {
  var currentPage = 0.obs;
  var bovinoInfo = <String, Bovino>{}.obs;
  PageController pageController = PageController();
  var sendingData = false.obs;
  var quickFillEdad = ''.obs;
  var quickFillSexo = ''.obs;
  var quickFillRaza = ''.obs;

  late Box<Bovino> bovinoBox;
  late Box<Entregas> entregasBox;

  late String entregaId; // ID de la entrega seleccionada
  var rangos = <String>[].obs; // Lista de IDs generados para los bovinos

  @override
  void onInit() async {
    super.onInit();
    try {
      // Abrir las cajas Hive
      bovinoBox = await Hive.openBox<Bovino>('bovinos');
      entregasBox = await Hive.openBox<Entregas>('entregas');

      // Obtener los argumentos de la navegación
      final args = Get.arguments as Map<String, dynamic>;

      // Validar argumentos
      if (!args.containsKey('entregaId')) {
        throw Exception('Argumento "entregaId" no proporcionado.');
      }

      entregaId = args['entregaId'];

      // Buscar la entrega en la caja por su campo entregaId
      final entrega = entregasBox.values.firstWhere(
        (e) => e.entregaId == entregaId,
        orElse: () =>
            throw Exception('No se encontró la entrega con ID=$entregaId.'),
      );

      print('Entrega seleccionada: ID=$entregaId, Datos=${entrega.toJson()}');

      // Generar rangos de aretes
      final generatedRangos =
          generateRangos(entrega.rangoInicial, entrega.rangoFinal);
      rangos.assignAll(generatedRangos); // Asignar rangos de manera reactiva

      // Inicializar los datos de los bovinos
      for (var id in rangos) {
        bovinoInfo[id] = Bovino(
          arete: id,
          edad: 0,
          sexo: '',
          raza: '',
          estadoArete: 'Bueno',
          cue: entrega.cue,
          cupa: entrega.cupa,
        );
      }
    } catch (e) {
      print('Error al inicializar FormBovinosController: $e');
    }
  }

  /// Genera los IDs del rango basado en el rango inicial y final
  List<String> generateRangos(int rangoInicial, int rangoFinal) {
    return List<String>.generate(
      rangoFinal - rangoInicial + 1,
      (index) => (rangoInicial + index).toString(),
    );
  }

  void nextPage() {
    if (currentPage.value < bovinoInfo.keys.length - 1) {
      currentPage.value++;
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
      pageController.previousPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void applyQuickFill() {
    bovinoInfo.forEach((key, bovino) {
      // Validar y convertir la edad
      final edad = int.tryParse(quickFillEdad.value) ?? bovino.edad;
      final updatedBovino = bovino.copyWith(
        edad: quickFillEdad.value.isNotEmpty ? edad : bovino.edad,
        sexo:
            quickFillSexo.value.isNotEmpty ? quickFillSexo.value : bovino.sexo,
        raza:
            quickFillRaza.value.isNotEmpty ? quickFillRaza.value : bovino.raza,
      );
      bovinoInfo[key] = updatedBovino;
    });
    update(); // Notificar cambios
    Get.snackbar('Llenado Rápido', 'Datos aplicados correctamente.');
  }

  void clearQuickFill() {
    quickFillEdad.value = '';
    quickFillSexo.value = '';
    quickFillRaza.value = '';
    bovinoInfo.values.forEach((bovino) {
      bovino.edad = 0;
      bovino.sexo = '';
      bovino.raza = '';
    });
    Get.snackbar('Llenado Rápido', 'Datos borrados correctamente.');
  }

void saveBovinos() async {
  checkEntregasBox();
  try {
    // Validar que todos los campos estén completos
    for (var bovino in bovinoInfo.values) {
      if (bovino.edad <= 0 || bovino.sexo.isEmpty || bovino.raza.isEmpty) {
        throw Exception(
            'Faltan datos en el bovino con arete ${bovino.arete}.');
      }
    }

    sendingData.value = true;

    // Guardar los bovinos en la caja Hive
    for (var bovino in bovinoInfo.values) {
      await bovinoBox.put(bovino.arete, bovino);
    }

    // Usar updateEntregaEstado para actualizar el estado de la entrega
    final entrega = entregasBox.values.firstWhere(
      (e) => e.entregaId == entregaId,
      orElse: () => throw Exception('No se encontró la entrega con ID=$entregaId.'),
    );

    // Actualizar estado a "Lista"
    await Get.find<EntregaController>().updateEntregaEstado(entregaId, 'Lista');

    // Notificar éxito
    sendingData.value = false;
    Get.snackbar('Guardado', 'Los datos se guardaron correctamente.');
    Get.offNamed('/home');
  } catch (e) {
    // Manejo de errores
    sendingData.value = false;
    Get.snackbar('Error', 'Error al guardar: $e');
    print('Error en saveBovinos: $e');
  }
}


  void checkEntregasBox() {
    print('Contenido de entregasBox:');
    for (var entrega in entregasBox.values) {
      print('Entrega: ${entrega.toJson()}');
    }
  }
}
