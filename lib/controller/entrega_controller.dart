import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/utils/util.dart';

class EntregaController extends GetxController {
  // Observables
  var entregas = <Entregas>[].obs;
  var userLocation = Position(
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

  // Hive Box para Entregas
  final Box<Entregas> entregasBox = Hive.box<Entregas>('entregas');

  @override
  void onInit() {
    super.onInit();
    fetchUserLocation();
    fetchEntregas();
  }

  /// Obtiene la ubicación actual del usuario
  Future<void> fetchUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('El servicio de ubicación está deshabilitado.');
    }

    // Verificar permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación están denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Los permisos de ubicación están permanentemente denegados.');
    }

    // Obtener la posición actual del usuario
    userLocation.value = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Recalcular distancias con la nueva ubicación
    updateDistances();
  }

  /// Carga las entregas desde Hive
  Future<void> fetchEntregas() async {
    entregas.value = entregasBox.values.toList();
    updateDistances();
  }

  /// Agrega una nueva entrega a Hive
  Future<void> addEntrega(Entregas nuevaEntrega) async {
    await entregasBox.add(nuevaEntrega);
    fetchEntregas();
  }

  /// Actualiza una entrega existente en Hive
  Future<void> updateEntrega(int index, Entregas updatedEntrega) async {
    await entregasBox.putAt(index, updatedEntrega);
    fetchEntregas();
  }

  /// Elimina una entrega de Hive
  Future<void> deleteEntrega(int index) async {
    await entregasBox.deleteAt(index);
    fetchEntregas();
  }

  /// Refresca los datos (ubicación y entregas)
  Future<void> refreshData() async {
    await fetchUserLocation();
    await fetchEntregas();
  }

  void updateDistances() {
  final updatedEntregas = entregas.map((entrega) {
    final distance = calculateDistance(
      userLocation.value.latitude,
      userLocation.value.longitude,
      entrega.latitud, // Usamos latitud del nuevo modelo
      entrega.longitud, // Usamos longitud del nuevo modelo
    );

    // Actualizamos la distancia calculada
    return entrega.copyWith(
      distanciaCalculada: '${(distance / 1000).toStringAsFixed(2)} KM',
    );
  }).toList();

  // Actualizamos la lista de entregas
  entregas.value = updatedEntregas;
}


  /// Obtiene el número de entregas pendientes
  int get entregasPendientesCount => entregas.length;
}
