import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/controller/managebag_controller.dart';
import 'package:trazaapp/data/models/altaentrega/altaentrega.dart';
import 'package:trazaapp/data/models/bovinos/bovino.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/data/repositories/alta/alta_repo.dart';
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
  var altasListas = <AltaEntrega>[].obs;
  final Box<AltaEntrega> altaEntregaBox = Hive.box<AltaEntrega>('altaentregas');

  @override
  void onInit() {
    super.onInit();
    fetchUserLocation();
    fetchEntregas();
    _listenLocationChanges(); // 🔹 Escuchar cambios en la ubicación en tiempo real
    getAltasListas();
    cargarAltasParaEnviar();
  }

  @override
  void onReady() {
    super.onReady();
    refreshData();
  }

  void getAltasListas() {
    altasListas.assignAll(
      altaEntregaBox.values
          .where((alta) => alta.estadoAlta == 'Lista')
          .toList(),
    );
  }

  Future<void> refreshData() async {
    await fetchUserLocation();
    await fetchEntregas();
    getAltasListas();
     cargarAltasParaEnviar();
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
    final values = entregasBox.values.toList();

    // Eliminar duplicados por entregaId (conservando el último)
    final mapaUnico = <String, Entregas>{};
    for (var entrega in values) {
      mapaUnico[entrega.entregaId] = entrega;
    }

    entregas.assignAll(mapaUnico.values.toList());

    updateDistances();
  }

  /// Agrega una nueva entrega a Hive
  Future<void> addEntrega(Entregas nuevaEntrega) async {
    final entregaCorregida = nuevaEntrega.copyWith(estado: 'Pendiente');
    await entregasBox.put(entregaCorregida.entregaId, entregaCorregida);
    fetchEntregas();
  }

  Future<void> updateEntregaEstado(String entregaId, String nuevoEstado) async {
    final index =
        entregas.indexWhere((entrega) => entrega.entregaId == entregaId);
    if (index != -1) {
      final entregaActualizada = entregas[index].copyWith(estado: nuevoEstado);
      await entregasBox.put(entregaId, entregaActualizada);
      fetchEntregas(); // ✅ Recargar entregas para reflejar el cambio
    }
  }

  Future<void> deleteEntregaYBovinos(String entregaId) async {
    try {
      final entrega = entregasBox.get(entregaId);
      if (entrega == null) {
        Get.snackbar('Error', 'No se encontró la entrega a eliminar.');
        return;
      }

      // Restaurar cantidad al bolsón
      final bagController = Get.find<ManageBagController>();
      await bagController.restoreBag(entrega.cantidad, entrega.rangoInicial);

      // Eliminar bovinos asociados
      final bovinoBox = await Hive.openBox<Bovino>('bovinos');
      final bovinosToDelete = bovinoBox.values
          .where((bovino) => bovino.entregaId == entrega.entregaId)
          .toList();

      for (var bovino in bovinosToDelete) {
        await bovinoBox.delete(bovino.arete);
      }

      // Eliminar entrega correctamente usando su ID como key
      await entregasBox.delete(entregaId);

      // Actualizar lista observable y UI
      await fetchEntregas();
      getAltasListas();

      Get.snackbar(
        'Eliminado',
        'Entrega eliminada correctamente.',
        backgroundColor: AppColors.snackSuccess,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error al eliminar entrega: $e');
      Get.snackbar(
        'Error',
        'No se pudo eliminar la entrega.',
        backgroundColor: AppColors.snackError,
        colorText: Colors.white,
      );
    }
  }

  Future<void> eliminarAltaEntregaCompleta(String idAlta) async {
    final alta = altaEntregaBox.get(idAlta);
    if (alta == null) return;

    // Buscar la entrega relacionada
    Entregas? entrega;
    for (var e in entregasBox.values) {
      if (e.idAlta == idAlta) {
        entrega = e;
        break;
      }
    }

    // ✅ Restaurar Bag solo si era entrega manual
    if (entrega != null && entrega.tipo == 'manual') {
      final bagController = Get.find<ManageBagController>();
      await bagController.restoreBag(entrega.cantidad, entrega.rangoInicial);
    }

    // 🧹 Eliminar Alta
    await altaEntregaBox.delete(idAlta);

    // Eliminar la entrega asociada
    if (entrega != null) {
      await entregasBox.delete(entrega.entregaId);
    }

    // También limpiar bovinos locales si están asociados
    final bovinoBox = Hive.box<Bovino>('bovinos');
    final bovinos = bovinoBox.values
        .where((b) => b.entregaId == entrega?.entregaId)
        .toList();
    for (var bovino in bovinos) {
      await bovinoBox.delete(bovino.arete);
    }

    getAltasListas();
    fetchEntregas();

    Get.snackbar(
      "Alta eliminada",
      "La entrega fue eliminada correctamente.",
      backgroundColor: AppColors.snackSuccess,
      colorText: Colors.white,
    );
  }

  void updateDistances() {
    for (var i = 0; i < entregas.length; i++) {
      try {
        final entrega = entregas[i];
        final distance = Geolocator.distanceBetween(
          userLocation.value.latitude,
          userLocation.value.longitude,
          entrega.latitud,
          entrega.longitud,
        );

        final entregaActualizada = entrega.copyWith(
          distanciaCalculada: '${distance.toStringAsFixed(2)} m',
        );

        // 🔥 Guardar la entrega actualizada en Hive
        entregasBox.put(entrega.entregaId, entregaActualizada);

        // 🔄 Actualizar la lista observable
        entregas[i] = entregaActualizada;
      } catch (e) {
        print("❌ Error al calcular distancia: $e");
      }
    }
  }

  Future<void> eliminarAlta(String idAlta) async {
    try {
      // Buscar entrega asociada con ese idAlta
      final entregaList =
          entregasBox.values.where((e) => e.idAlta == idAlta).toList();
      if (entregaList.isEmpty) {
        Get.snackbar('Error', 'No se encontró la entrega asociada.');
        return;
      }

      final entrega = entregaList.first;

      // Eliminar la AltaEntrega de Hive
      await altaEntregaBox.delete(idAlta);

      // Restaurar la entrega a estado Pendiente sin idAlta
      final entregaRestaurada = entrega.copyWith(
        estado: 'Pendiente',
        idAlta: null,
      );

      await entregasBox.put(entrega.entregaId, entregaRestaurada);

      // Refrescar la UI
      getAltasListas();
      fetchEntregas();

      Get.snackbar(
        'Alta eliminada',
        'La entrega fue restaurada como pendiente.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error al eliminar alta: $e');
      Get.snackbar('Error', 'No se pudo eliminar la alta.');
    }
  }

 void getAltasParaEnviar() {
  altasParaEnviar.assignAll( // ✅ Correcto
    altaEntregaBox.values
      .where((alta) => alta.estadoAlta.trim().toLowerCase() == 'lista')
      .toList(),
  );
}


  Future<void> enviarAlta(String entregaId) async {
    try {
      final entrega = altaEntregaBox.get(entregaId);
      if (entrega == null || entrega.idAlta.isEmpty) {
        print("❌ No se encontró una alta válida para enviar.");
        Get.snackbar(
          'Error',
          'No se encontró la alta a enviar.',
          backgroundColor: AppColors.snackError,
          colorText: Colors.white,
        );
        return;
      }

      final altaEntrega = altaEntregaBox.get(entrega.idAlta);
      if (altaEntrega == null) {
        print("❌ No se encontró la alta con ID: ${entrega.idAlta}");
        Get.snackbar(
          'Error',
          'AltaEntrega no encontrada.',
          backgroundColor: AppColors.snackError,
          colorText: Colors.white,
        );
        return;
      }

      // 🔁 Enviar al backend
      await EnvioAltasRepository().enviarAlta(altaEntrega);

      // ✅ Actualizar estadoAlta a "Enviada"
      final altaActualizada = altaEntrega.copyWith(estadoAlta: 'Enviada');
      await altaEntregaBox.put(altaEntrega.idAlta, altaActualizada);

      // 🔄 Actualizar listas observables
      getAltasListas();
      getAltasParaEnviar();

      // ✅ Snackbar de éxito
      Get.snackbar(
        'Alta enviada',
        'La alta ${altaEntrega.idAlta} fue enviada con éxito.',
        backgroundColor: AppColors.snackSuccess,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error al enviar alta: $e');
      Get.snackbar(
        'Error',
        'Ocurrió un error al enviar la alta.',
        backgroundColor: AppColors.snackError,
        colorText: Colors.white,
      );
    }
  }

void cargarAltasParaEnviar() {
  altasParaEnviar.value = altaEntregaBox.values
      .where((alta) => alta.estadoAlta.trim().toLowerCase() == 'Lista')
      .toList();
}

// Para gestión en campo
  List<Entregas> get entregasPendientes => entregas
      .where((entrega) => entrega.estado.trim().toLowerCase() == 'pendiente')
      .toList();

  List<Entregas> get entregasListas => entregas
      .where((entrega) => entrega.estado.trim().toLowerCase() == 'altalista')
      .toList();

  int get entregasPendientesCount => entregasPendientes.length;

  int get entregasConAltaListaCount => entregasListas.length;

// Para envío de altas
 final RxList<AltaEntrega> altasParaEnviar = <AltaEntrega>[].obs;


  int get altasParaEnviarCount => altasParaEnviar.length;
}
