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
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/remote/endpoints.dart';

class EntregaController extends GetxController {
  var entregas = <Entregas>[].obs;
  var isLoading = false.obs;
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
  final Box<AltaEntrega> altaEntregaBox = Hive.box<AltaEntrega>('altaentregas');
  
  // Unificamos las listas de altas
  final RxList<AltaEntrega> altasListas = <AltaEntrega>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserLocation();
    fetchEntregas();
    _listenLocationChanges();
    cargarAltasListas();
  }

  @override
  void onReady() {
    super.onReady();
    refreshData();
  }

  void cargarAltasListas() {
    altasListas.assignAll(
      altaEntregaBox.values
          .where((alta) => alta.estadoAlta.trim().toLowerCase() == 'lista')
          .toList(),
    );
  }

  Future<void> refreshData() async {
    await fetchUserLocation();
    await fetchEntregas();
    cargarAltasListas();
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
      cargarAltasListas();

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

    cargarAltasListas();
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
      cargarAltasListas();
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

  Future<void> enviarAlta(String idAlta) async {
    try {
      // Obtener la alta desde Hive
      final alta = altaEntregaBox.get(idAlta);
      if (alta == null) {
        throw Exception('No se encontró la alta con ID: $idAlta');
      }

      // Mostrar diálogo de carga
      Get.dialog(
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Enviando datos...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Config
      final configBox = Hive.box<AppConfig>('appConfig');
      final config = configBox.get('config');
      if (config == null) {
        throw Exception('No se encontró la configuración del usuario.');
      }

      // Enviar
      final response = await http.post(
        Uri.parse('$urlaltas?proceso=alta&codhabilitado=${alta.codhabilitado}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${config.token}',
        },
        body: jsonEncode(alta.toJsonEnvio()),
      );

      if (response.statusCode == 201) {
        // Actualizar estado
        final updatedAlta = alta.copyWith(estadoAlta: 'Enviada');
        await altaEntregaBox.put(alta.idAlta, updatedAlta);

        // Refrescar lista
        cargarAltasListas();

        Get.back(); // Cerrar diálogo de carga
        Get.snackbar(
          'Éxito',
          'Alta enviada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception(
            'Error al enviar alta: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      Get.back(); // Cerrar diálogo de carga
      Get.snackbar(
        'Error',
        'Error al enviar alta: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ Error en enviarAlta: $e');
    }
  }

  // Para gestión en campo
  List<Entregas> get entregasPendientes => entregas
      .where((entrega) => 
        entrega.estado.trim().toLowerCase() == 'pendiente' && 
        !entrega.reposicion)
      .toList();

  List<Entregas> get entregasListas => entregas
      .where((entrega) => 
        entrega.estado.trim().toLowerCase() == 'altalista' && 
        !entrega.reposicion)
      .toList();

  int get entregasPendientesCount => entregasPendientes.length;
  int get entregasConAltaListaCount => entregasListas.length;
  int get altasParaEnviarCount => altasListas.length;

  // Método para actualizar la entrega con información de reposición
  Future<void> configurarReposicion(String entregaId, int cantidadReposicion) async {
    try {
      final entrega = entregasBox.get(entregaId);
      if (entrega == null) {
        Get.snackbar('Error', 'No se encontró la entrega');
        return;
      }

      // Validar que la cantidad de reposición sea válida
      if (cantidadReposicion >= entrega.cantidad) {
        Get.snackbar(
          'Error',
          'La cantidad para reposición no puede ser mayor o igual al total',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Verificar si ya existe una reposición para esta entrega
      final bool tieneReposicionExistente = entregasBox.values.any(
        (e) => e.entregaId.startsWith('${entregaId}_repo')
      );

      if (tieneReposicionExistente) {
        Get.snackbar(
          'Error',
          'Ya existe una reposición para esta entrega',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Calcular el nuevo rango para la entrega original
      final nuevoRangoFinal = entrega.rangoFinal - cantidadReposicion;
      final nuevoRangoInicial = entrega.rangoInicial;

      // Crear la entrega de reposición
      final entregaReposicion = entrega.copyWith(
        entregaId: '${entrega.entregaId}_repo',
        reposicion: true,
        estadoReposicion: 'pendiente',
        cantidad: cantidadReposicion,
        rangoInicial: nuevoRangoFinal + 1,
        rangoFinal: entrega.rangoFinal,
        fechaEntrega: DateTime.now(),
      );

      // Actualizar la entrega original con el nuevo rango
      final entregaActualizada = entrega.copyWith(
        cantidad: entrega.cantidad - cantidadReposicion,
        rangoFinal: nuevoRangoFinal,
        estado: 'Pendiente',
      );

      // Guardar ambas entregas
      await entregasBox.put(entregaId, entregaActualizada);
      await entregasBox.put(entregaReposicion.entregaId, entregaReposicion);
      
      // Actualizar la lista observable de entregas
      await fetchEntregas();
      
      Get.snackbar(
        'Éxito',
        'Reposición configurada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Redirigir a la pantalla de captura de datos de la entrega ajustada
//   print('🔁 Navegando a formulario con argumentos');
// Get.toNamed('/form', arguments: {
//   'entregaId': entregaId,
//   'rangoInicial': nuevoRangoInicial,
//   'rangoFinal': nuevoRangoFinal,
//   'cantidad': entregaActualizada.cantidad,
// });
// print('✅ Navegación exitosa');

  
    } catch (e) {
      print('❌ Error al configurar reposición: $e');
      Get.snackbar(
        'Error',
        'No se pudo configurar la reposición',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Método para marcar una reposición como completada
  Future<void> completarReposicion(String entregaId) async {
    try {
      final entrega = entregasBox.get(entregaId);
      if (entrega == null) {
        Get.snackbar('Error', 'No se encontró la entrega');
        return;
      }

      final entregaActualizada = entrega.copyWith(
        estadoReposicion: 'completada',
      );

      await entregasBox.put(entregaId, entregaActualizada);
      await fetchEntregas();

      Get.snackbar(
        'Reposición completada',
        'La reposición se ha marcado como completada',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error al completar reposición: $e');
      Get.snackbar(
        'Error',
        'No se pudo completar la reposición',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Método para obtener las entregas con reposiciones pendientes
  List<Entregas> get entregasConReposicionPendiente => entregas
      .where((entrega) => 
        entrega.reposicion && 
        entrega.estadoReposicion.toLowerCase() == 'pendiente')
      .toList();

  // Método para obtener las entregas con reposiciones completadas
  List<Entregas> get entregasConReposicionCompletada => entregas
      .where((entrega) => 
        entrega.reposicion && 
        entrega.estadoReposicion.toLowerCase() == 'completada')
      .toList();
}
