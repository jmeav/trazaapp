import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/departamentos/departamento.dart';
import 'package:trazaapp/data/local/models/municipios/municipio.dart';
import 'package:trazaapp/data/local/models/establecimiento/establecimiento.dart';

class VerifyEstablishmentController extends GetxController {
  // Controladores de texto
  final TextEditingController departamentoController = TextEditingController();
  final TextEditingController municipioController = TextEditingController();
  final TextEditingController cueController = TextEditingController();

  // Listas de datos
  var departamentos = <Departamento>[].obs;
  var municipios = <Municipio>[].obs;
  var establecimientos = <Establecimiento>[].obs;

  // Listas filtradas
  var municipiosFiltrados = <Municipio>[].obs;

  // Estado de UI
  final RxString departamentoSeleccionado = ''.obs;
  final RxString municipioSeleccionado = ''.obs;
  var queryEstablecimiento = ''.obs;

  // Ubicación del usuario
  final Rx<Position> userLocation = Position(
    latitude: 0.0,
    longitude: 0.0,
    timestamp: DateTime.now(),
    accuracy: 0.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  ).obs;

  // Establecimiento seleccionado
  final Rx<Establecimiento?> establecimientoSeleccionado = Rx<Establecimiento?>(null);

  // Distancia calculada
  final RxString distanciaCalculada = 'Calculando...'.obs;

  // Estado para mostrar el mapa
  final RxBool mostrarMapa = false.obs;

  @override
  void onInit() {
    super.onInit();
    cargarCatalogos();
    fetchUserLocation();
  }

  /// Cargar catálogos al iniciar
  Future<void> cargarCatalogos() async {
    try {
      if (!Hive.isBoxOpen('departamentos')) await Hive.openBox<Departamento>('departamentos');
      if (!Hive.isBoxOpen('municipios')) await Hive.openBox<Municipio>('municipios');
      if (!Hive.isBoxOpen('establecimientos')) await Hive.openBox<Establecimiento>('establecimientos');

      departamentos.assignAll(Hive.box<Departamento>('departamentos').values.toList());
      municipios.assignAll(Hive.box<Municipio>('municipios').values.toList());
      establecimientos.assignAll(Hive.box<Establecimiento>('establecimientos').values.toList());

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

  /// Obtener la ubicación actual del usuario
  Future<void> fetchUserLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      userLocation.value = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      updateDistances();
    } catch (_) {}
  }

  /// Calcular la distancia entre el usuario y el establecimiento
  void updateDistances() {
    if (establecimientoSeleccionado.value != null) {
      final distancia = Geolocator.distanceBetween(
        userLocation.value.latitude,
        userLocation.value.longitude,
        double.parse(establecimientoSeleccionado.value!.latitud),
        double.parse(establecimientoSeleccionado.value!.longitud),
      );

      distanciaCalculada.value = '${(distancia / 1000).toStringAsFixed(2)} km';
    }
  }

  /// Seleccionar un establecimiento
  void seleccionarEstablecimiento(Establecimiento establecimiento) {
    establecimientoSeleccionado.value = establecimiento;
    updateDistances();
  }

  /// Validar ubicación y mostrar el mapa
  void validarUbicacion() {
    if (establecimientoSeleccionado.value != null) {
      mostrarMapa.value = true;
    } else {
      Get.snackbar(
        'Error',
        'Selecciona un establecimiento primero',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}