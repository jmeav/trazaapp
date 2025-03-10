import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/controller/managebag_controller.dart';
import 'package:trazaapp/data/models/bovinos/bovino.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/utils/util.dart';

class EntregaController extends GetxController {
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
    _listenLocationChanges(); // 🔹 Escuchar cambios en la ubicación en tiempo real
  }

  @override
  void onReady() {
    super.onReady();
    refreshData();
  }

  Future<void> refreshData() async {
    await fetchUserLocation();
    await fetchEntregas();
  }

  /// Obtiene la ubicación actual del usuario
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

  /// Escucha cambios en la ubicación en tiempo real
  void _listenLocationChanges() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // 🔹 Se actualiza cada 1 metro
      ),
    ).listen((Position position) {
      userLocation.value = position;
      updateDistances();
    });
  }

  /// Carga las entregas desde Hive
  Future<void> fetchEntregas() async {
    entregas.value = entregasBox.values.toList();
    updateDistances();
  }

  /// Agrega una nueva entrega a Hive
  Future<void> addEntrega(Entregas nuevaEntrega) async {
    final entregaCorregida = nuevaEntrega.copyWith(estado: 'Pendiente');
    await entregasBox.add(entregaCorregida);
    fetchEntregas();
  }

  /// Actualiza el estado de una entrega existente
  Future<void> updateEntregaEstado(String entregaId, String nuevoEstado) async {
    final index = entregas.indexWhere((entrega) => entrega.entregaId == entregaId);
    if (index != -1) {
      final entregaActualizada = entregas[index].copyWith(estado: nuevoEstado);
      await entregasBox.putAt(index, entregaActualizada);
      fetchEntregas();
    }
  }

  Future<void> deleteEntregaYBovinos(String entregaId) async {
    try {
      final entregaIndex = entregasBox.values.toList().indexWhere((e) => e.entregaId == entregaId);
      if (entregaIndex == -1) return;

      final entrega = entregasBox.getAt(entregaIndex)!;

      // Restaurar los datos del bag si la entrega proviene de él
      final bagController = Get.find<ManageBagController>();
      await bagController.restoreBag(entrega.cantidad, entrega.rangoInicial);

      // Eliminar bovinos asociados
      final bovinoBox = await Hive.openBox<Bovino>('bovinos');
      final bovinosToDelete = bovinoBox.values.where((bovino) => bovino.cue == entrega.cue).toList();

      for (var bovino in bovinosToDelete) {
        await bovinoBox.delete(bovino.arete);
      }

      // Eliminar la entrega
      await entregasBox.deleteAt(entregaIndex);

      refreshData();
      Get.snackbar('Eliminado', 'Entrega eliminada correctamente.');
    } catch (_) {}
  }

 void updateDistances() {
  entregas.value = entregas.map((entrega) {
    try {
      final distance = Geolocator.distanceBetween(
        userLocation.value.latitude,
        userLocation.value.longitude,
        entrega.latitud,
        entrega.longitud,
      );

      return entrega.copyWith(
          distanciaCalculada: '${distance.toStringAsFixed(2)} m');
    } catch (_) {
      return entrega;
    }
  }).toList();
}


  /// Getters para listas y conteos
  List<Entregas> get entregasPendientes =>
      entregas.where((entrega) => entrega.estado.trim().toLowerCase() == 'pendiente').toList();

  List<Entregas> get entregasListas =>
      entregas.where((entrega) => entrega.estado.trim().toLowerCase() == 'lista').toList();

  int get entregasPendientesCount => entregasPendientes.length;

  int get entregasListasCount => entregasListas.length;
}
