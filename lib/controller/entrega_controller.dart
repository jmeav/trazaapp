import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/controller/managebag_controller.dart';
import 'package:trazaapp/data/models/bovinos/bovino.dart';
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

  final Box<Entregas> entregasBox = Hive.box<Entregas>('entregas');

  @override
  void onInit() {
    super.onInit();
    fetchUserLocation();
    fetchEntregas();
  }

  @override
  void onReady() {
    super.onReady();
    refreshData();
  }

  /// Refresca los datos de ubicación y entregas
  Future<void> refreshData() async {
    await fetchUserLocation();
    await fetchEntregas();
  }

  /// Obtiene la ubicación actual del usuario
  Future<void> fetchUserLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('El servicio de ubicación está deshabilitado.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Los permisos de ubicación están denegados.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Los permisos de ubicación están permanentemente denegados.');
      }

      userLocation.value = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      updateDistances();
    } catch (e) {
      print('Error al obtener ubicación: $e');
    }
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

  /// Actualiza el estado de una entrega existente
  Future<void> updateEntregaEstado(String entregaId, String nuevoEstado) async {
    final index = entregas.indexWhere((entrega) => entrega.entregaId == entregaId);
    if (index != -1) {
      final entregaActualizada = entregas[index].copyWith(estado: nuevoEstado);
      await entregasBox.putAt(index, entregaActualizada);
      fetchEntregas();
    } else {
      print('Error: No se encontró la entrega con ID $entregaId.');
    }
  }

Future<void> deleteEntregaYBovinos(String entregaId) async {
  try {
    final entregaIndex = entregasBox.values.toList().indexWhere((e) => e.entregaId == entregaId);

    if (entregaIndex == -1) {
      Get.snackbar('Error', 'No se encontró la entrega.');
      return;
    }

    final entrega = entregasBox.getAt(entregaIndex)!;

    // Restaurar los datos del bag si la entrega proviene de él
    final bagController = Get.find<ManageBagController>();
    await bagController.restoreBag(entrega.cantidad, entrega.rangoInicial);

    // Eliminar bovinos asociados
    final bovinoBox = await Hive.openBox<Bovino>('bovinos');
    final bovinosToDelete = bovinoBox.values
        .where((bovino) => bovino.cue == entrega.cue)
        .toList();

    for (var bovino in bovinosToDelete) {
      await bovinoBox.delete(bovino.arete);
    }

    // Eliminar la entrega
    await entregasBox.deleteAt(entregaIndex);
    
    refreshData();
    Get.snackbar('Eliminado', 'Entrega eliminada correctamente.');
  } catch (e) {
    print('Error al eliminar entrega y bovinos: $e');
    Get.snackbar('Error', 'No se pudo eliminar la entrega.',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
  }
}



  /// Calcula y actualiza las distancias para cada entrega
  void updateDistances() {
    entregas.value = entregas.map((entrega) {
      try {
        final distance = calculateDistance(
          userLocation.value.latitude,
          userLocation.value.longitude,
          entrega.latitud,
          entrega.longitud,
        );

        return entrega.copyWith(
            distanciaCalculada: '${(distance / 1000).toStringAsFixed(2)} KM');
      } catch (e) {
        print('Error al calcular distancia: $e');
        return entrega;
      }
    }).toList();
  }

  /// Getters para listas y conteos
  List<Entregas> get entregasPendientes =>
      entregas.where((entrega) => entrega.estado == 'Pendiente').toList();

  List<Entregas> get entregasListas =>
      entregas.where((entrega) => entrega.estado == 'Lista').toList();

  int get entregasPendientesCount => entregasPendientes.length;

  int get entregasListasCount => entregasListas.length;
}
