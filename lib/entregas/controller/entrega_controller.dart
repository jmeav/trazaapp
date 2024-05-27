import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trazaapp/entregas/model/entregas.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:trazaapp/utils/util.dart';
import 'dart:math' as math;

class EntregaController extends GetxController {
  var entregas = <Entrega>[].obs;
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

  @override
  void onInit() {
    super.onInit();
    fetchUserLocation();
    fetchEntregas();
  }

  Future<void> fetchUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('El servicio de ubicación está deshabilitado.');
    }

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

    userLocation.value = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Imprimir la ubicación del usuario
    print('Ubicación del usuario: Latitud ${userLocation.value.latitude}, Longitud ${userLocation.value.longitude}');

    // Actualizar las distancias con la nueva ubicación
    updateDistances();
  }

  Future<void> fetchEntregas() async {
    final String response = await rootBundle.loadString('assets/entregas.json');
    final List<dynamic> data = await json.decode(response);

    entregas.value = data.map((json) => Entrega.fromJson(json)).toList();

    // Actualizar distancias después de cargar las entregas
    updateDistances();
  }

  void updateDistances() {
    final updatedEntregas = entregas.map((entrega) {
      final distance = calculateDistance(
        userLocation.value.latitude,
        userLocation.value.longitude,
        entrega.coordenadas.latitud,
        entrega.coordenadas.longitud,
      );

      return entrega.copyWith(
        distanciaCalculada: (distance / 1000).toStringAsFixed(2) + 'KM',
      );
    }).toList();

    entregas.value = updatedEntregas;
  }

  int get entregasPendientesCount => entregas.length;
}
