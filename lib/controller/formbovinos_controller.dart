import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/controller/entrega_controller.dart';
import 'package:trazaapp/data/models/altaentrega/altaentrega.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
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
  late Box<AltaEntrega> altaEntregaBox; // ✅ Agregado aquí
  late String entregaId;
  var rangos = <String>[].obs;
  var razas = <Raza>[].obs;

  // 📌 NUEVOS CAMPOS PARA RECOLECTAR AL FINAL
  var fotoBovInicial = ''.obs;
  var fotoBovFinal = ''.obs;
  var observaciones = ''.obs;

  final catalogosController = Get.find<CatalogosController>();
  final CatalogosController controller = Get.put(CatalogosController());

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

    for (var id in rangos) {
      bovinoInfo[id] = Bovino(
        arete: id,
        edad: 0,
        sexo: '',
        raza: '',
        estadoArete: 'Bueno',
        cue: entrega.cue,
        cupa: entrega.cupa,
        traza: 'CRUCE', // ✅ Valor por defecto
        entregaId: entregaId,
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

  /// 📌 Genera un código único de 5 caracteres para `idAlta`
  String generateUniqueAltaId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(5, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }

  void saveBovinos() async {
    try {
      for (var bovino in bovinoInfo.values) {
        if (bovino.edad <= 0 || bovino.sexo.isEmpty || bovino.raza.isEmpty) {
          throw Exception(
              'Faltan datos en el bovino con arete ${bovino.arete}.');
        }
      }

      sendingData.value = true;

      for (var bovino in bovinoInfo.values) {
        final bovinoActualizado = bovino.copyWith(entregaId: entregaId);
        await bovinoBox.put(bovinoActualizado.arete, bovinoActualizado);
      }

      sendingData.value = false;

      // 📌 NUEVO PASO: Navegar a la pantalla de fotos y observaciones
      Get.toNamed('/finalizarEntrega', arguments: {"entregaId": entregaId});
    } catch (e) {
      sendingData.value = false;
      Get.snackbar('Error', 'Error al guardar: $e');
      print('Error en saveBovinos: $e');
    }
  }
void saveFinalData() async {
  try {
    final entrega = entregasBox.values.firstWhere(
      (e) => e.entregaId == entregaId,
      orElse: () => throw Exception('Entrega no encontrada.'),
    );

    // ✅ Accedemos a la configuración del usuario desde Hive
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

    final distanciaCalculada = '${distance.toStringAsFixed(2)}';

    // ✅ Generar un ID único para esta alta
    final uniqueAltaId = generateUniqueAltaId();

    // 📌 Crear lista de BovinoResumen
    final detalleBovinos = bovinoInfo.values.map((bovino) {
      return BovinoResumen(
        arete: bovino.arete,
        edad: bovino.edad,
        sexo: bovino.sexo,
        raza: bovino.raza,
        traza: bovino.traza,
        estadoArete: bovino.estadoArete,
        fechaNacimiento: DateTime.now().subtract(Duration(days: bovino.edad * 30)),
      );
    }).toList();

    // 📌 Crear el objeto AltaEntrega
    final altaEntrega = AltaEntrega(
      idAlta: uniqueAltaId,
      rangoInicial: entrega.rangoInicial,
      rangoFinal: entrega.rangoFinal,
      cupa: entrega.cupa,
      cue: entrega.cue,
      departamento: entrega.departamento,
      municipio: entrega.municipio,
      latitud: entrega.latitud,
      longitud: entrega.longitud,
      distanciaCalculada: distanciaCalculada,
      fechaAlta: DateTime.now(),
      tipoAlta: "operadora", // o "productor", según corresponda
      token: config.imei,
      codhabilitado: config.codHabilitado,
      idorganizacion: config.idOrganizacion,
      fotoBovInicial: fotoBovInicial.value,
      fotoBovFinal: fotoBovFinal.value,
      reposicion: false,
      observaciones: observaciones.value,
      detalleBovinos: detalleBovinos,
      estadoAlta: 'Lista',
    );

    // 📌 Guardar en Hive
    await altaEntregaBox.put(uniqueAltaId, altaEntrega);

    // 📌 Actualizar entrega original con el ID y estado
    final entregaActualizada = entrega.copyWith(
      estado: 'altalista', // <- aquí el cambio clave
      idAlta: uniqueAltaId,
    );
    await entregasBox.put(entregaId, entregaActualizada);

    // 📌 Refrescar el estado general
    final entregaController = Get.find<EntregaController>();
    await entregaController.fetchEntregas();
    entregaController.getAltasListas();

    // 📌 Aviso y navegación
    Get.snackbar('Guardado', 'AltaEntrega creada y guardada.');
    Get.offAllNamed('/home');
  } catch (e) {
    Get.snackbar('Error', 'Error al guardar AltaEntrega: $e');
    print('❌ Error en saveFinalData: $e');
  }
}

  void checkEntregasBox() {
    print('Contenido de entregasBox:');
    for (var entrega in entregasBox.values) {
      print('Entrega: ${entrega.toJson()}');
    }
  }
}
