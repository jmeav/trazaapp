import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/bag/bag_operadora.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/data/models/departamentos/departamento.dart';
import 'package:trazaapp/data/models/municipios/municipio.dart';
import 'package:trazaapp/data/models/establecimiento/establecimiento.dart';
import 'package:trazaapp/data/models/productores/productor.dart';
import 'package:trazaapp/presentation/homescreen/home.dart';
import 'package:trazaapp/presentation/scanner/scanner_view.dart';
import 'package:trazaapp/utils/util.dart';

class ManageBagController extends GetxController {
  // Controladores de texto
  final TextEditingController departamentoController = TextEditingController();
  final TextEditingController municipioController = TextEditingController();
  final TextEditingController cupaController = TextEditingController();
  final TextEditingController cueController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

  // Listas de datos
  var departamentos = <Departamento>[].obs;
  var municipios = <Municipio>[].obs;
  var establecimientos = <Establecimiento>[].obs;
  var productores = <Productor>[].obs;

  // Listas filtradas
  var municipiosFiltrados = <Municipio>[].obs;
  var establecimientosFiltrados = <Establecimiento>[].obs;

  // Estado de UI
  final RxInt cantidadDisponible = 0.obs;
  final RxString rangoAsignado = ''.obs;
  final RxString departamentoSeleccionado = ''.obs;
  final RxString municipioSeleccionado = ''.obs;
  late Bag bag;
  var queryEstablecimiento = ''.obs;
  var queryProductor = ''.obs;
  final RxList<int> aretesDisponibles = <int>[].obs; // Nueva gestión de aretes

  @override
  void onInit() {
    super.onInit();
    cargarCatalogos();
    _cargarAretesDisponibles(); // 🔹 Cargar los aretes correctamente
    loadBagData(); // 🔹 Refrescar la cantidad de aretes disponibles
  }

  /// Cargar los datos del Bag desde Hive
  Future<void> _cargarAretesDisponibles() async {
    final box = Hive.box<Bag>('bag');

    if (box.isNotEmpty) {
      bag = box.getAt(0)!;
      aretesDisponibles.value =
          List.generate(bag.cantidad, (index) => bag.rangoInicial + index)
              .where((arete) => !areteYaUsado(arete)) // 🔹 Filtrar los usados
              .toList();

      cantidadDisponible.value = aretesDisponibles.length;
      rangoAsignado.value = aretesDisponibles.isNotEmpty
          ? '${aretesDisponibles.first} - ${aretesDisponibles.last}'
          : 'Sin aretes disponibles';

      update();
    }
  }

  /// Verificar si un arete ya fue usado
  bool areteYaUsado(int arete) {
    final entregasBox = Hive.box<Entregas>('entregas');
    return entregasBox.values
        .any((e) => e.rangoInicial <= arete && arete <= e.rangoFinal);
  }

  /// Cargar catálogos al iniciar
  Future<void> cargarCatalogos() async {
    try {
      if (!Hive.isBoxOpen('departamentos'))
        await Hive.openBox<Departamento>('departamentos');
      if (!Hive.isBoxOpen('municipios'))
        await Hive.openBox<Municipio>('municipios');
      if (!Hive.isBoxOpen('establecimientos'))
        await Hive.openBox<Establecimiento>('establecimientos');
      if (!Hive.isBoxOpen('productores'))
        await Hive.openBox<Productor>('productores');

      departamentos
          .assignAll(Hive.box<Departamento>('departamentos').values.toList());
      municipios.assignAll(Hive.box<Municipio>('municipios').values.toList());
      establecimientos.assignAll(
          Hive.box<Establecimiento>('establecimientos').values.toList());
      productores.assignAll(Hive.box<Productor>('productores').values.toList());

      update();
    } catch (e) {
      print('Error al cargar catálogos: $e');
      Get.snackbar('Error', 'No se pudieron cargar los catálogos.');
    }
  }

  /// Cargar datos del bag y actualizar la UI
  Future<void> loadBagData() async {
    final box = Hive.box<Bag>('bag');
    if (box.isNotEmpty) {
      bag = box.getAt(0)!;
      cantidadDisponible.value = aretesDisponibles.length;
      rangoAsignado.value = aretesDisponibles.isNotEmpty
          ? '${aretesDisponibles.first} - ${aretesDisponibles.last}'
          : 'Sin aretes disponibles';

      print('🔄 Bag actualizado: cantidad=${cantidadDisponible.value}, '
          'rango=${rangoAsignado.value}');
    }
  }

  void resetForm() {
    // 🔹 Limpiar controladores de texto
    departamentoController.clear();
    municipioController.clear();
    cupaController.clear();
    cueController.clear();
    cantidadController.clear();

    // 🔹 Resetear los valores de los `DropdownButton`
    departamentoSeleccionado.value = '';
    municipioSeleccionado.value = '';

    // 🔹 Limpiar las consultas de `Autocomplete`
    queryEstablecimiento.value = '';
    queryProductor.value = '';

    // 🔹 Forzar actualización de la vista
    update();
  }

  Future<bool> asignarAretes(int cantidad) async {
    if (aretesDisponibles.isEmpty) {
      Get.snackbar('Error', 'No hay aretes disponibles');
      return false;
    }

    List<List<int>> rangosDisponibles = [];
    List<int> tempRango = [];

    for (int i = 0; i < aretesDisponibles.length; i++) {
      if (tempRango.isEmpty || tempRango.last + 1 == aretesDisponibles[i]) {
        tempRango.add(aretesDisponibles[i]);
      } else {
        rangosDisponibles.add(List.from(tempRango));
        tempRango = [aretesDisponibles[i]];
      }
    }
    if (tempRango.isNotEmpty) {
      rangosDisponibles.add(List.from(tempRango));
    }

    List<int>? rangoExacto;
    List<int>? mejorOpcion;
    List<int>? rangoResidual;

    for (var rango in rangosDisponibles) {
      if (rango.length == cantidad) {
        rangoExacto = rango;
        break;
      } else if (rango.length > cantidad) {
        mejorOpcion ??= rango;
      } else if (rango.length < cantidad) {
        rangoResidual ??= rango;
      }
    }

    if (rangoExacto != null) {
      return await asignarEntrega(
          rangoExacto); // ✅ Devolver `true` si se asignó con éxito
    }

    if (rangoResidual == null && mejorOpcion != null) {
      return await asignarEntrega(
          mejorOpcion.sublist(0, cantidad)); // ✅ Devolver `true`
    }

    if (mejorOpcion != null || rangoResidual != null) {
      int primerAreteDisponible = mejorOpcion?.first ?? -1;
      _mostrarDialogAlternativa(
        cantidad,
        primerAreteDisponible,
        rangoResidual,
      );
      return false; // ❌ No se completó la entrega inmediatamente
    }

    Get.snackbar('Error', 'No hay suficientes aretes consecutivos disponibles');
    return false;
  }

  void _mostrarDialogAlternativa(
      int cantidadSolicitada, int primerArete, List<int>? rangoResidual) {
    String mensaje = rangoResidual != null
        ? "Rango residual encontrado de ${rangoResidual.length} aretes.\n(${rangoResidual.first} a ${rangoResidual.last})\n"
        : "No hay un rango residual disponible.\n";

    if (primerArete != -1) {
      mensaje +=
          "El siguiente rango disponible comienza en $primerArete en adelante.\n";
    }

    mensaje += "¿Quieres usar uno de estos rangos o prefieres otra opción?";

    Get.defaultDialog(
      title: "Opciones de Asignación",
      middleText: mensaje,
      actions: [
        if (primerArete != -1)
          TextButton(
            onPressed: () {
              // 🔹 Solo asignar desde el NUEVO RANGO disponible, ignorando residuales
              List<int> nuevoRango = aretesDisponibles
                  .where((a) => a >= primerArete) // ✅ Ignoramos los residuos
                  .take(cantidadSolicitada)
                  .toList();

              asignarEntrega(nuevoRango);
              Get.back();
            },
            child: Text("Usar desde $primerArete"),
          ),
        TextButton(
          onPressed: () {
            Get.back();
            _mostrarExplicacionAlternativa(cantidadSolicitada, rangoResidual);
          },
          child: Text("No, buscar otra opción"),
        ),
      ],
    );
  }

  /// 🔹 **Explica cómo hacer 2 entregas individuales si el usuario dice que no**
  void _mostrarExplicacionAlternativa(
      int cantidadSolicitada, List<int>? rangoResidual) {
    if (rangoResidual == null) {
      Get.snackbar(
        "Opción alternativa",
        "Puedes buscar un nuevo rango o esperar a liberar aretes.",
      );
      return;
    }

    int cantidadResidual = rangoResidual.length;
    int cantidadFaltante = cantidadSolicitada - cantidadResidual;
    Get.snackbar(
      duration: Duration(seconds: 10),
      "Opción alternativa",
      "Puedes hacer 2 entregas separadas:\n"
          "➡️ Una de ${cantidadResidual} con el rango ${rangoResidual.first} a ${rangoResidual.last}\n"
          "➡️ Otra de ${cantidadFaltante} con el siguiente rango disponible.\n"
          "para completar tu entrega de $cantidadSolicitada aretes.",
    );
  }

  String resolveDepartamento(String? idDept) {
    final dep = Hive.box<Departamento>('departamentos').values.firstWhere(
        (d) => d.idDepartamento == idDept,
        orElse: () => Departamento(
            idDepartamento: idDept ?? '', departamento: 'Desconocido'));
    return dep.departamento;
  }

  String resolveMunicipio(String? idMun) {
    final mun = Hive.box<Municipio>('municipios').values.firstWhere(
        (m) => m.idMunicipio == idMun,
        orElse: () => Municipio(
            idMunicipio: idMun ?? '',
            municipio: 'Desconocido',
            idDepartamento: ''));
    return mun.municipio;
  }

  Future<bool> asignarEntrega(List<int> asignados) async {
    if (asignados.isEmpty) {
      Get.snackbar("Error", "No se pudo asignar la entrega.");
      return false;
    }

    aretesDisponibles.removeWhere((a) => asignados.contains(a));

    final Establecimiento? establecimientoSeleccionado =
        establecimientos.firstWhereOrNull(
            (e) => e.establecimiento.trim() == cueController.text.trim());

    final Productor? productorSeleccionado = productores.firstWhereOrNull(
        (p) => p.productor.trim() == cupaController.text.trim());

    final double latitud =
        double.tryParse(establecimientoSeleccionado?.latitud ?? '0.0') ?? 0.0;
    final double longitud =
        double.tryParse(establecimientoSeleccionado?.longitud ?? '0.0') ?? 0.0;

    final nuevaEntrega = Entregas(
      entregaId: (100000 + Random().nextInt(900000)).toString(),
      fechaEntrega: DateTime.now(),
      cupa: cupaController.text,
      cue: cueController.text,
      rangoInicial: asignados.first,
      rangoFinal: asignados.last,
      cantidad: asignados.length,
      nombreProductor: productorSeleccionado?.nombreProductor ?? 'Desconocido',
      establecimiento:
          cueController.text.isNotEmpty ? cueController.text : 'No asignado',
      dias: 0,
      nombreEstablecimiento:
          establecimientoSeleccionado?.nombreEstablecimiento ?? 'No encontrado',
      latitud: latitud,
      longitud: longitud,
      existencia: asignados.length,
      distanciaCalculada: null,
      estado: 'pendiente',
      lastUpdate: DateTime.now(),
      tipo: 'manual',
      fotoBovInicial: '',
      fotoBovFinal: '',
      reposicion: false,
      observaciones: '',
      departamento:
          resolveDepartamento(establecimientoSeleccionado?.idDepartamento),
      municipio: resolveMunicipio(establecimientoSeleccionado?.idMunicipio),
    );

    final entregasBox = Hive.box<Entregas>('entregas');
    await entregasBox.put(nuevaEntrega.entregaId, nuevaEntrega); // ✅

    final box = Hive.box<Bag>('bag');
    await box.putAt(0, bag);

    cantidadDisponible.value = aretesDisponibles.length;
    rangoAsignado.value = aretesDisponibles.isNotEmpty
        ? '${aretesDisponibles.first} - ${aretesDisponibles.last}'
        : 'Sin aretes disponibles';

    update();
    resetForm();

    Get.snackbar(
      'Éxito',
      'Entrega registrada correctamente.',
      backgroundColor: AppColors.snackSuccess,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // ✅ Esperar antes de cerrar la pantalla
    await Future.delayed(const Duration(seconds: 1));

    // ✅ Cerrar la pantalla y limpiar los datos completamente
    Get.offUntil(
      GetPageRoute(
        page: () =>
            HomeView(), // 🔹 Reemplaza esto con la pantalla de inicio a la que quieres volver
      ),
      (route) =>
          false, // 🔹 Esto se asegura de que elimina todas las pantallas hasta la de inicio
    );

    return true;
  }

  /// Restaurar Bag cuando se elimina una entrega
  Future<void> restoreBag(int cantidad, int rangoInicialEliminado) async {
    final box = Hive.box<Bag>('bag');

    if (box.isNotEmpty) {
      bag = box.getAt(0)!;

      // Restaurar la cantidad y agregar los aretes eliminados de nuevo al stock
      aretesDisponibles
          .addAll(List.generate(cantidad, (i) => rangoInicialEliminado + i));
      aretesDisponibles.sort(); // Ordenar para evitar saltos

      cantidadDisponible.value = aretesDisponibles.length;
      rangoAsignado.value = aretesDisponibles.isNotEmpty
          ? '${aretesDisponibles.first} - ${aretesDisponibles.last}'
          : 'Sin aretes disponibles';

      await box.putAt(0, bag);

      print('Bag restaurado: cantidad=${cantidadDisponible.value}, '
          'rango=${rangoAsignado.value}');
    }
  }

  Future<void> eliminarEntrega(String entregaId) async {
    final entregasBox = Hive.box<Entregas>('entregas');
    final entrega = entregasBox.get(entregaId);

    if (entrega == null) {
      Get.snackbar('Error', 'No se encontró la entrega.');
      return;
    }

    // Devolver aretes al stock
    aretesDisponibles.addAll(
        List.generate(entrega.cantidad, (i) => entrega.rangoInicial + i));
    aretesDisponibles.sort();

    await entregasBox.delete(entregaId); // ✅ Elimina por clave

    // Actualizar UI
    cantidadDisponible.value = aretesDisponibles.length;
    rangoAsignado.value = aretesDisponibles.isNotEmpty
        ? '${aretesDisponibles.first} - ${aretesDisponibles.last}'
        : 'Sin aretes disponibles';

    update();

    Get.snackbar(
      'Éxito',
      'Entrega eliminada y aretes devueltos al stock.',
      backgroundColor: AppColors.snackSuccess,
      colorText: Colors.white,
    );
  }

  /// Buscar establecimientos por municipio y nombre
  Future<List<Establecimiento>> buscarEstablecimientos(String query) async {
    if (query.isEmpty || municipioSeleccionado.value.isEmpty) return [];

    final box = Hive.box<Establecimiento>('establecimientos');
    return box.values
        .where((e) =>
            e.idMunicipio == municipioSeleccionado.value &&
            (e.nombreEstablecimiento
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                e.establecimiento.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }

  /// Buscar productores por nombre o código
  Future<List<Productor>> buscarProductores(String query) async {
    if (query.isEmpty) return [];

    final box = Hive.box<Productor>('productores');
    return box.values
        .where((p) =>
            p.nombreProductor.toLowerCase().contains(query.toLowerCase()) ||
            p.productor.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Filtrar municipios por departamento
  void filtrarMunicipios(String? idDepartamento) {
    if (idDepartamento == null || idDepartamento.isEmpty) {
      municipiosFiltrados.assignAll(municipios);
    } else {
      municipiosFiltrados.assignAll(
        municipios.where((m) => m.idDepartamento == idDepartamento).toList(),
      );
    }
    update();
  }

  /// Escanear código de barras
  Future<void> scanCode(String type) async {
    final result = await Get.to(() => ScannerView());
    if (result != null) {
      if (type == 'cue') {
        // Buscar el establecimiento por código
        final establecimiento = establecimientos.firstWhereOrNull(
          (e) => e.establecimiento.trim() == result.trim()
        );
        
        if (establecimiento != null) {
          cueController.text = establecimiento.establecimiento;
          // Actualizar departamento y municipio
          departamentoSeleccionado.value = establecimiento.idDepartamento;
          filtrarMunicipios(establecimiento.idDepartamento);
          municipioSeleccionado.value = establecimiento.idMunicipio;
          update();
        } else {
          Get.snackbar(
            'Error',
            'Establecimiento no encontrado',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else if (type == 'cupa') {
        // Buscar el productor por código
        final productor = productores.firstWhereOrNull(
          (p) => p.productor.trim() == result.trim()
        );
        
        if (productor != null) {
          cupaController.text = productor.productor;
          update();
        } else {
          Get.snackbar(
            'Error',
            'Productor no encontrado',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    }
  }
}
