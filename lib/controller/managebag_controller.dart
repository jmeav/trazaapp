import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/bag/bag_operadora.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/data/models/departamentos/departamento.dart';
import 'package:trazaapp/data/models/municipios/municipio.dart';
import 'package:trazaapp/data/models/establecimiento/establecimiento.dart';
import 'package:trazaapp/data/models/productores/productor.dart';

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

  @override
  void onInit() {
    super.onInit();
    loadBagData();
    cargarCatalogos();
  }

  /// Cargar los datos del Bag desde Hive
  Future<void> loadBagData() async {
    final box = Hive.box<Bag>('bag');
    if (box.isNotEmpty) {
      bag = box.getAt(0)!;
      cantidadDisponible.value = bag.cantidad;
      rangoAsignado.value =
          '${bag.rangoInicial} - ${bag.rangoInicial + bag.cantidad - 1}';
    }
  }

  /// Cargar catálogos al iniciar
  Future<void> cargarCatalogos() async {
    try {
      if (!Hive.isBoxOpen('departamentos')) await Hive.openBox<Departamento>('departamentos');
      if (!Hive.isBoxOpen('municipios')) await Hive.openBox<Municipio>('municipios');
      if (!Hive.isBoxOpen('establecimientos')) await Hive.openBox<Establecimiento>('establecimientos');
      if (!Hive.isBoxOpen('productores')) await Hive.openBox<Productor>('productores');

      departamentos.assignAll(Hive.box<Departamento>('departamentos').values.toList());
      municipios.assignAll(Hive.box<Municipio>('municipios').values.toList());
      establecimientos.assignAll(Hive.box<Establecimiento>('establecimientos').values.toList());
      productores.assignAll(Hive.box<Productor>('productores').values.toList());

      update();
    } catch (e) {
      print('Error al cargar catálogos: $e');
      Get.snackbar('Error', 'No se pudieron cargar los catálogos.');
    }
  }

  /// Buscar establecimientos por municipio y nombre
  Future<List<Establecimiento>> buscarEstablecimientos(String query) async {
    if (query.isEmpty || municipioSeleccionado.value.isEmpty) return [];

    final box = Hive.box<Establecimiento>('establecimientos');
    return box.values
        .where((e) =>
            e.idMunicipio == municipioSeleccionado.value &&
            (e.nombreEstablecimiento.toLowerCase().contains(query.toLowerCase()) ||
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
  
 Future<void> asignarBag() async {
  final int cantidadAsignar = int.tryParse(cantidadController.text) ?? 0;

  if (cantidadAsignar <= 0 || cantidadAsignar > cantidadDisponible.value) {
    Get.snackbar('Error', 'Cantidad no válida.');
    return;
  }

  final int rangoInicial = bag.rangoInicial;
  final int rangoFinal = rangoInicial + cantidadAsignar - 1; // ✅ Corrección del rango


  // 🔹 Buscar el establecimiento por CUE (idEstablecimiento en el modelo)
  final Establecimiento? establecimientoSeleccionado = establecimientos.firstWhereOrNull(
    (e) => e.establecimiento.trim() == cueController.text.trim(),
  );

  // 🔹 Buscar el productor por CUPA
  final Productor? productorSeleccionado = productores.firstWhereOrNull(
    (p) => p.productor.trim() == cupaController.text.trim(),
  );

  
  // Convertir latitud y longitud a double
  final double latitud = double.tryParse(establecimientoSeleccionado?.latitud ?? '0.0') ?? 0.0;
  final double longitud = double.tryParse(establecimientoSeleccionado?.longitud ?? '0.0') ?? 0.0;

  final nuevaEntrega = Entregas(
    entregaId: DateTime.now().millisecondsSinceEpoch.toString(),
    cue: cueController.text,
    cupa: cupaController.text,
    estado: 'Pendiente',
    cantidad: cantidadAsignar,
    rangoInicial: rangoInicial,
    rangoFinal: rangoFinal,
    fechaEntrega: DateTime.now(),
    latitud: latitud,
    longitud: longitud,
    nombreProductor: productorSeleccionado?.nombreProductor ?? 'Desconocido',
    establecimiento: cueController.text.isNotEmpty ? cueController.text : 'No asignado',
    dias: 0,
    nombreEstablecimiento: establecimientoSeleccionado?.nombreEstablecimiento ?? 'No encontrado',
    existencia: cantidadAsignar,
    distanciaCalculada: null,
    lastUpdate: DateTime.now(),
  );

  final entregasBox = Hive.box<Entregas>('entregas');
  await entregasBox.add(nuevaEntrega);

  bag = bag.copyWith(
    rangoInicial: rangoFinal + 1,
    cantidad: bag.cantidad - cantidadAsignar,
  );

  final box = Hive.box<Bag>('bag');
  await box.putAt(0, bag);

  cantidadDisponible.value = bag.cantidad;
  rangoAsignado.value =
      '${bag.rangoInicial} - ${bag.rangoInicial + bag.cantidad - 1}';

  departamentoController.clear();
  municipioController.clear();
  cupaController.clear();
  cueController.clear();
  cantidadController.clear();

  Get.toNamed('/formbovinos', arguments: {
    'entregaId': nuevaEntrega.entregaId,
    'cue': nuevaEntrega.cue,
    'rangoInicial': nuevaEntrega.rangoInicial,
    'rangoFinal': nuevaEntrega.rangoFinal,
    'cantidad': nuevaEntrega.cantidad,
  });

  Get.snackbar('Éxito', 'Bovinos listos para registrar.');
}


  /// Restaurar Bag cuando se elimina una entrega
  Future<void> restoreBag(int cantidad, int rangoInicialEliminado) async {
    final box = Hive.box<Bag>('bag');

    if (box.isNotEmpty) {
      bag = box.getAt(0)!;

      // Restaurar la cantidad y ajustar el rangoInicial
      final nuevoBag = bag.copyWith(
        cantidad: bag.cantidad + cantidad,
        rangoInicial: bag.rangoInicial > rangoInicialEliminado
            ? rangoInicialEliminado
            : bag.rangoInicial,
      );

      await box.putAt(0, nuevoBag);

      // ✅ Recargar los datos del bag para actualizar la UI
      await loadBagData();
      print(
          'Bag restaurado: cantidad=${nuevoBag.cantidad}, rango=${rangoAsignado.value}');
    }
  }

}