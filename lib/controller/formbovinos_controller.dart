import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/data/models/bovinos/bovino.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/data/models/razas/raza.dart';

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
  late String entregaId;
  var rangos = <String>[].obs;
  var razas = <Raza>[].obs; // Lista de razas obtenidas del catálogo

  final catalogosController = Get.find<CatalogosController>(); // Usamos el catálogo existente
  final CatalogosController controller = Get.put(CatalogosController()); // ⬅️ Agregar esto

  @override
  void onInit() async {
    super.onInit();
    try {
      // Abrir las cajas Hive
      bovinoBox = await Hive.openBox<Bovino>('bovinos');
      entregasBox = await Hive.openBox<Entregas>('entregas');

      // Cargar razas desde el catálogo
      razas.assignAll(catalogosController.razas);

      // Obtener los argumentos de la navegación
      final args = Get.arguments as Map<String, dynamic>;
      if (!args.containsKey('entregaId')) {
        throw Exception('Argumento "entregaId" no proporcionado.');
      }

      entregaId = args['entregaId'];

      final entrega = entregasBox.values.firstWhere(
        (e) => e.entregaId == entregaId,
        orElse: () =>
            throw Exception('No se encontró la entrega con ID=$entregaId.'),
      );

      final generatedRangos =
          generateRangos(entrega.rangoInicial, entrega.rangoFinal);
      rangos.assignAll(generatedRangos);

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
          traza: '',
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
      final edad = int.tryParse(quickFillEdad.value) ?? bovino.edad;
      final razaValida = razas.any((r) => r.nombre == quickFillRaza.value)
          ? quickFillRaza.value
          : '';

      final updatedBovino = bovino.copyWith(
        edad: quickFillEdad.value.isNotEmpty ? edad : bovino.edad,
        sexo:
            quickFillSexo.value.isNotEmpty ? quickFillSexo.value : bovino.sexo,
        raza: razaValida,
      );
      bovinoInfo[key] = updatedBovino;
    });
    update();
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
    try {
      // Validar que todos los campos estén completos
      for (var bovino in bovinoInfo.values) {
        if (bovino.edad <= 0 || bovino.sexo.isEmpty || bovino.raza.isEmpty) {
          throw Exception(
              'Faltan datos en el bovino con arete ${bovino.arete}.');
        }
      }

      sendingData.value = true;

      // Guardar los bovinos en Hive
      for (var bovino in bovinoInfo.values) {
        await bovinoBox.put(bovino.arete, bovino);
      }

      // Buscar la entrega en Hive
      final entregaIndex = entregasBox.values
          .toList()
          .indexWhere((e) => e.entregaId == entregaId);

      if (entregaIndex != -1) {
        final entrega = entregasBox.getAt(entregaIndex)!;
        final entregaActualizada = entrega.copyWith(estado: 'Lista');
        await entregasBox.putAt(entregaIndex, entregaActualizada);
      }

      sendingData.value = false;
      Get.snackbar('Guardado', 'Los datos se guardaron correctamente.');
      Get.offNamed('/home');
    } catch (e) {
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
