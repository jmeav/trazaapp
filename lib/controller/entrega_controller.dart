import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import 'package:trazaapp/controller/managebag_controller.dart';
import 'package:trazaapp/data/local/models/reposicion/repoentrega.dart';
import 'package:trazaapp/data/local/models/reposicion/bovinorepo.dart';
import 'package:trazaapp/data/local/models/altaentrega/altaentrega.dart';
import 'package:trazaapp/data/local/models/bovinos/bovino.dart';
import 'package:trazaapp/data/local/models/entregas/entregas.dart';
import 'package:trazaapp/utils/util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:trazaapp/data/local/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/remote/endpoints.dart';
import 'package:trazaapp/data/repositories/reposicion/reposicion_repo.dart';

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
  late Box<RepoEntrega> repoBox;
  
  // Unificamos las listas de altas
  final RxList<AltaEntrega> altasListas = <AltaEntrega>[].obs;
  final RxList<RepoEntrega> reposListas = <RepoEntrega>[].obs;

  final RxBool isInitialized = false.obs;

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;
    try {
      print('🚀 Iniciando EntregaController...');
      
      // Inicializar repoBox primero
      print('📦 Abriendo caja repoentregas...');
      repoBox = await Hive.openBox<RepoEntrega>('repoentregas');
      
      // Ensure entregasBox is open
      if (!entregasBox.isOpen) {
         print("Advertencia: entregasBox no está abierta en onInit. Intentando abrir...");
         await Hive.openBox<Entregas>('entregas'); 
      }

      // Obtener la configuración actual
      final configBox = Hive.box<AppConfig>('appConfig');
      final config = configBox.get('config');
      
      if (config != null && config.cleanIds.isNotEmpty) {
        print('🧹 Limpiando entregas marcadas para eliminación...');
        print('📋 IDs a eliminar: ${config.cleanIds.join(', ')}');
        
        // Eliminar las entregas marcadas
        await entregasBox.deleteAll(config.cleanIds);
        await entregasBox.flush();
        
        // Limpiar la lista de IDs
        final configActualizado = config.copyWith(cleanIds: []);
        await configBox.put('config', configActualizado);
        await configBox.flush();
        
        print('✅ Entregas eliminadas y lista de IDs limpiada');
      }

      // Limpiar entregas que coincidan con reposiciones procesadas
      print('🧹 Limpiando entregas con reposiciones procesadas...');
      final reposProcesadas = repoBox.values.where((repo) => 
        repo.estadoRepo.toLowerCase() == 'procesado'
      ).toList();
      
      for (var repo in reposProcesadas) {
        // Eliminar la entrega con ID _repo
        final entregaRepoId = '${repo.entregaIdOrigen}_repo';
        final entregaRepo = entregasBox.get(entregaRepoId);
        if (entregaRepo != null) {
          print('🗑️ Eliminando entrega de reposición: $entregaRepoId');
          await entregasBox.delete(entregaRepoId);
        }

        // Actualizar estado de la entrega original
        final entregaOriginal = entregasBox.get(repo.entregaIdOrigen);
        if (entregaOriginal != null) {
          print('📝 Actualizando estado de entrega original: ${repo.entregaIdOrigen}');
          final entregaActualizada = entregaOriginal.copyWith(
            estado: 'procesado',
            estadoReposicion: 'procesado'
          );
          await entregasBox.put(repo.entregaIdOrigen, entregaActualizada);
        }
      }
      await entregasBox.flush();
      print('✅ Proceso de limpieza y actualización de estados completado');

      // Now load the remaining deliveries into the observable list
      await fetchUserLocation();
      await fetchEntregas();
      _listenLocationChanges();
      cargarAltasListas();
      cargarReposListas();
      
      print('📊 Estado final de las cajas después de cargar:');
      print('- Entregas: ' + entregasBox.length.toString() + ' elementos');
      print('- Altas: ${altaEntregaBox.length} elementos');
      print('- Repos: ${repoBox.length} elementos');
      
      isInitialized.value = true;
      print('✅ EntregaController inicializado correctamente');
    } catch (e) {
      print("❌ Error en onInit EntregaController: $e");
      try {
        if (!repoBox.isOpen) {
          repoBox = await Hive.openBox<RepoEntrega>('repoentregas');
        }
        if (!entregasBox.isOpen) {
          await Hive.openBox<Entregas>('entregas');
        }
        await fetchEntregas();
        cargarAltasListas();
        cargarReposListas();
        isInitialized.value = true;
        print('✅ EntregaController recuperado después del error');
      } catch (e2) {
        print("❌ Error en recuperación: $e2");
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  void cargarAltasListas() {
    try {
       if (!altaEntregaBox.isOpen) {
          print("Advertencia: altaEntregaBox no está abierta en cargarAltasListas.");
          return;
       }
       altasListas.assignAll(
         altaEntregaBox.values
             .where((alta) => alta.estadoAlta.trim().toLowerCase() == 'lista')
             .toList(),
       );
       print("Altas listas cargadas: ${altasListas.length}");
    } catch (e) {
       print("Error cargando altas listas: $e");
    }
  }

  void cargarReposListas() {
    // No es necesario verificar isOpen aquí si garantizamos que se llama después de onInit
    try {
       reposListas.assignAll(
         repoBox.values
             .where((repo) => 
               repo.estadoRepo.trim().toLowerCase() == 'lista' && 
               repo.estadoRepo.trim().toLowerCase() != 'enviada'
             )
             .toList(),
       );
       print("Reposiciones listas cargadas: ${reposListas.length}");
    } catch (e) {
       print("Error cargando reposiciones listas: $e");
       // Podrías limpiar la lista o mostrar un error
       reposListas.clear(); 
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
       await fetchUserLocation();
       await fetchEntregas();
       cargarAltasListas();
       cargarReposListas();
    } catch (e) {
       print("Error en refreshData: $e");
    } finally {
       isLoading.value = false;
    }
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
    try {
        if (!entregasBox.isOpen) {
          print("❌ Advertencia: entregasBox no está abierta en fetchEntregas.");
          return; 
        }
        print('📥 Iniciando fetchEntregas...');
        print('📊 Estado inicial de entregasBox: ${entregasBox.length} elementos');
        
        final values = entregasBox.values.toList();
        print('📋 Valores encontrados en entregasBox: ${values.length}');
        
        // Imprimir detalles de cada entrega (debugging)
        // for (var entrega in values) {
        //   print('📄 Entrega encontrada:');
        //   print('  - ID: ${entrega.entregaId}');
        //   print('  - Estado: ${entrega.estado}');
        //   print('  - Reposición: ${entrega.reposicion}');
        //   print('  - Estado Reposición: ${entrega.estadoReposicion}');
        // }

        // Eliminar duplicados por entregaId (conservando el último)
        final mapaUnico = <String, Entregas>{};
        for (var entrega in values) {
          mapaUnico[entrega.entregaId] = entrega;
        }
        print('🔄 Entregas únicas después de eliminar duplicados: ${mapaUnico.length}');

        // Filter out reposiciones marked as 'enviada'
        final filteredEntregas = mapaUnico.values.where((entrega) => 
            !(entrega.reposicion && entrega.estadoReposicion.toLowerCase() == 'enviada')
        ).toList();
        
        entregas.assignAll(filteredEntregas);
        print("✅ Entregas cargadas (filtrando enviadas): ${entregas.length}");

        updateDistances();
    } catch (e) {
        print("❌ Error en fetchEntregas: $e");
    }
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
     // Primero restaurar bag si aplica
     final entregaParaEliminar = entregasBox.get(entregaId);
     if (entregaParaEliminar != null && entregaParaEliminar.tipo == 'manual') {
        try {
          final bagController = Get.find<ManageBagController>();
          await bagController.restoreBag(entregaParaEliminar.cantidad, entregaParaEliminar.rangoInicial);
        } catch (e) {
          print("Error restaurando bag al eliminar entrega $entregaId: $e");
        }
     }

    // Eliminar bovinos asociados (si existen)
    try {
        final bovinoBox = await Hive.openBox<Bovino>('bovinos');
        final bovinosToDelete = bovinoBox.values
            .where((bovino) => bovino.entregaId == entregaId)
            .toList();
        for (var bovino in bovinosToDelete) {
            await bovinoBox.delete(bovino.arete);
        }
         print("Bovinos asociados a $entregaId eliminados: ${bovinosToDelete.length}");
    } catch (e) {
        print("Error eliminando bovinos asociados a $entregaId: $e");
    }

    try {
        // Usar firstWhereOrNull ya está bien porque importamos collection
        final repoAsociado = repoBox.values.firstWhereOrNull((repo) => repo.entregaIdOrigen == entregaId);
        if (repoAsociado != null) {
           // Asegurar que repoBox esté abierta antes de eliminar
           if (!repoBox.isOpen) repoBox = await Hive.openBox<RepoEntrega>('repoentregas');
           await repoBox.delete(repoAsociado.idRepo);
           print("RepoEntrega ${repoAsociado.idRepo} asociada a $entregaId eliminada.");
        }
        // Eliminar entrega correctamente usando su ID como key
        await entregasBox.delete(entregaId);

        // Actualizar lista observable y UI
        await fetchEntregas();
        cargarAltasListas();
        cargarReposListas();

        Get.snackbar(
          'Eliminado',
          'Entrega eliminada correctamente.',
          backgroundColor: AppColors.snackSuccess,
          colorText: Colors.white,
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
     if (!entregasBox.isOpen) {
        print("Advertencia: entregasBox no está abierta en updateDistances.");
        return;
     }
      for (var i = 0; i < entregas.length; i++) {
         try {
           final entrega = entregas[i];
           // Evitar calcular si lat/lon no son válidos (ej. 0.0)
           if (userLocation.value.latitude == 0.0 || userLocation.value.longitude == 0.0 || entrega.latitud == 0.0 || entrega.longitud == 0.0) {
             // Asignar un valor por defecto o mantener el existente
              // entregas[i] = entrega.copyWith(distanciaCalculada: 'N/A');
              continue; // Saltar al siguiente
           }

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
           print("❌ Error al calcular distancia para ${entregas[i].entregaId}: $e");
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

        // Get.snackbar(
        //   'Éxito',
        //   'Alta enviada correctamente',
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );
        return;
      } else {
        try {
          var jsonResponse = jsonDecode(response.body);
          if (response.statusCode == 500 && 
              jsonResponse['error'] == 'Error en la base de datos' &&
              jsonResponse['detalle'].toString().contains('Duplicate entry')) {
            throw Exception('DUPLICATE_ENTRY');
          }
          throw Exception(jsonResponse['detalle'] ?? 'Error al enviar alta');
        } catch (e) {
          if (e.toString() == 'Exception: DUPLICATE_ENTRY') {
            rethrow;
          }
          if (response.body.contains('<html>')) {
            throw Exception("SERVER_ERROR");
          }
          throw Exception("UNKNOWN_ERROR");
        }
      }
    } catch (e) {
      String mensajeError = 'Error al enviar la alta';
      String tituloError = 'Error';
      
      if (e.toString().contains('DUPLICATE_ENTRY')) {
        tituloError = 'Error de Duplicado';
        mensajeError = 'Esta alta ya fue enviada anteriormente';
        
        // Si es un error de duplicado, eliminamos la alta
        await altaEntregaBox.delete(idAlta);
        await altaEntregaBox.flush();
        cargarAltasListas();
      } else if (e.toString().contains('CONNECTION_ERROR')) {
        tituloError = 'Error de Conexión';
        mensajeError = 'No hay conexión a internet. Por favor, verifica tu conexión e intenta nuevamente';
      } else if (e.toString().contains('SERVER_ERROR')) {
        tituloError = 'Error del Servidor';
        mensajeError = 'El servidor ha rechazado la solicitud. Por favor, contacta al administrador';
      }
      
      rethrow;
    }
  }
  
  // Para gestión en campo
  List<Entregas> get entregasPendientes => entregas
      .where((entrega) => 
        // Solo incluir entregas en estado pendiente y que no sean reposiciones ni fullrepo
        (entrega.estado.trim().toLowerCase() == 'pendiente'
          && !entrega.reposicion && entrega.estado.trim().toLowerCase() != 'fullrepo') ||
        // También incluir entregas con idAlta que todavía están en estado pendiente
        (entrega.idAlta != null && entrega.estado.trim().toLowerCase() == 'pendiente' && !entrega.reposicion && entrega.estado.trim().toLowerCase() != 'fullrepo')
      )
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
      if (cantidadReposicion <= 0 || cantidadReposicion > entrega.cantidad) {
        Get.snackbar(
          'Error',
          'La cantidad para reposición debe ser mayor a 0 y menor o igual al total',
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

      // Dividir los aretes asignados
      final nuevosAretesReposicion = List<int>.from(entrega.aretesAsignados.take(cantidadReposicion));
      final nuevosAretesOriginal = List<int>.from(entrega.aretesAsignados.skip(cantidadReposicion));

      // Crear la entrega de reposición
      final entregaReposicion = entrega.copyWith(
        entregaId: '${entrega.entregaId}_repo',
        reposicion: true,
        estadoReposicion: 'pendiente',
        cantidad: cantidadReposicion,
        rangoInicial: nuevoRangoFinal + 1,
        rangoFinal: entrega.rangoFinal,
        fechaEntrega: DateTime.now(),
        aretesAsignados: nuevosAretesReposicion,
      );

      // Actualizar la entrega original con el nuevo rango
      final nuevaCantidad = entrega.cantidad - cantidadReposicion;
      final entregaActualizada = entrega.copyWith(
        cantidad: nuevaCantidad,
        rangoFinal: nuevoRangoFinal,
        estado: (nuevaCantidad == 0 && entrega.idAlta == null) ? 'fullrepo' : 'Pendiente',
        aretesAsignados: nuevosAretesOriginal,
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
        entrega.estadoReposicion.toLowerCase() == 'pendiente' &&
        // Excluir las que ya tienen un RepoEntrega con estado 'lista' o 'enviada'
        !_tieneRepoListaOEnviadaAsociada(entrega.entregaId)
      )
      .toList();

  // Método auxiliar para verificar si existe una RepoEntrega asociada con estado 'lista' o 'enviada'
  bool _tieneRepoListaOEnviadaAsociada(String entregaId) {
    if (!repoBox.isOpen) return false; // Si no está abierto aún, asumir que no existe
    
    // Extraer el ID base de la entrega (quitar el sufijo _repo si existe)
    final idBase = entregaId.endsWith('_repo') 
        ? entregaId.substring(0, entregaId.length - 5)
        : entregaId;
    
    // Verificar si existe alguna RepoEntrega con este entregaIdOrigen y estado 'lista' o 'enviada'
    return repoBox.values.any((repo) => 
        repo.entregaIdOrigen == idBase && 
        (repo.estadoRepo.trim().toLowerCase() == 'lista' || repo.estadoRepo.trim().toLowerCase() == 'enviada')
    );
  }

  // Método para obtener las entregas con reposiciones completadas
  List<Entregas> get entregasConReposicionCompletada => entregas
      .where((entrega) => 
        entrega.reposicion && 
        entrega.estadoReposicion.toLowerCase() == 'completada')
      .toList();

  Future<void> marcarRepoEnviada(String repoId) async {
    isLoading.value = true;
    try {
      // Asegurar que las cajas estén abiertas
      if (!repoBox.isOpen) repoBox = await Hive.openBox<RepoEntrega>('repoentregas');
      if (!entregasBox.isOpen) await Hive.openBox<Entregas>('entregas'); // Asegurar que entregasBox esté abierta

      final repo = repoBox.get(repoId);
      if (repo == null) {
        throw Exception('Reposición con ID $repoId no encontrada.');
      }

      // 1. Actualizar estado de RepoEntrega
      final repoActualizado = repo.copyWith(estadoRepo: 'Enviada');
      await repoBox.put(repoId, repoActualizado);
      print("Repo $repoId marcada como Enviada.");

      // 2. Actualizar estado de la Entrega original
      final entregaOriginal = entregasBox.get(repo.entregaIdOrigen);
      if (entregaOriginal != null) {
        final entregaActualizada = entregaOriginal.copyWith(
          estadoReposicion: 'completada',
        );
        await entregasBox.put(entregaOriginal.entregaId, entregaActualizada);
        print("Entrega original ${entregaOriginal.entregaId} actualizada a reposicion completada.");
      } else {
        print("Advertencia: No se encontró la entrega original ${repo.entregaIdOrigen} para actualizar estado.");
      }

      // 3. Recargar listas
      cargarReposListas();
      await fetchEntregas();

      Get.snackbar('Enviada', 'Reposición marcada como enviada.', snackPosition: SnackPosition.BOTTOM);

    } catch (e) {
      print('Error al marcar repo como enviada: $e');
      Get.snackbar('Error', 'No se pudo marcar la reposición como enviada: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
       isLoading.value = false;
    }
  }

  Future<void> eliminarRepoLista(String repoId) async {
     isLoading.value = true;
     try {
       // Asegurar que repoBox esté abierta
        if (!repoBox.isOpen) repoBox = await Hive.openBox<RepoEntrega>('repoentregas');

        final repo = repoBox.get(repoId);
        if (repo == null) {
          print("Advertencia: No se encontró Repo $repoId para eliminar.");
          isLoading.value = false; // Salir y quitar indicador de carga
          return;
        }

       // Eliminar el RepoEntrega
        await repoBox.delete(repoId);
        print("Repo $repoId eliminada.");

        // Recargar lista
        cargarReposListas();

        Get.snackbar('Eliminada', 'Reposición $repoId eliminada.', snackPosition: SnackPosition.BOTTOM);

     } catch (e) {
        print('Error al eliminar repo lista: $e');
        Get.snackbar('Error', 'No se pudo eliminar la reposición: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
     } finally {
       isLoading.value = false;
     }
  }

  Future<void> enviarReposicion(String repoId) async {
    print('🔍 Iniciando envío de reposición con ID: $repoId');
    
    // Verificar si hay altas pendientes
    if (altasListas.isNotEmpty) {
      print('❌ No se puede enviar la reposición porque hay altas pendientes de envío');
      Get.snackbar(
        'Error',
        'No se puede enviar la reposición porque hay altas pendientes de envío. Por favor, envíe primero las altas pendientes.',
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red.withOpacity(0.2),
        colorText: Colors.red,
      );
      return;
    }

    final envioReposicionRepository = EnvioReposicionRepository();
    final repo = repoBox.get(repoId);
    if (repo == null) {
      print('❌ No se encontró la reposición con ID: $repoId');
      Get.snackbar('Error', 'No se encontró la reposición con ID: $repoId');
      return;
    }

    try {
      print('📤 Enviando reposición al servidor...');
      await envioReposicionRepository.enviarReposicion(repo.toJsonEnvio());
      print('✅ Reposición enviada exitosamente al servidor');
      
// Eliminar todas las entregas relacionadas
      await _eliminarEntregasRelacionadas(repoId, repo.entregaIdOrigen);
      // Actualizar estado de la reposición a "procesado"
      final repoActualizado = repo.copyWith(estadoRepo: 'procesado');
      await repoBox.put(repoId, repoActualizado);
      await repoBox.flush();
      print('✅ Estado de reposición actualizado a "procesado"');

      // Agregar IDs a la lista de limpieza
      await _agregarIdsParaLimpieza(repo.entregaIdOrigen);
      
      Get.snackbar(
        'Éxito',
        'Reposición enviada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error en enviarReposicion: $e');
      
      String mensajeError = 'Error al enviar la reposición';
      String tituloError = 'Error';
      
      if (e.toString().contains('DUPLICATE_ENTRY')) {
        tituloError = 'Error de Duplicado';
        mensajeError = 'Esta reposición ya fue enviada anteriormente';
        
        // Eliminar todas las entregas relacionadas
      await _eliminarEntregasRelacionadas(repoId, repo.entregaIdOrigen);
        // Si es un error de duplicado, también agregamos los IDs para limpieza
        await _agregarIdsParaLimpieza(repo.entregaIdOrigen);

          // Actualizar estado de la reposición a "procesado"
      final repoActualizado = repo.copyWith(estadoRepo: 'procesado');
      await repoBox.put(repoId, repoActualizado);
      await repoBox.flush();
      print('✅ Estado de reposición actualizado a "procesado"');

      } else if (e.toString().contains('CONNECTION_ERROR')) {
        tituloError = 'Error de Conexión';
        mensajeError = 'No hay conexión a internet. Por favor, verifica tu conexión e intenta nuevamente';
      } else if (e.toString().contains('SERVER_ERROR')) {
        tituloError = 'Error del Servidor';
        mensajeError = 'El servidor ha rechazado la solicitud. Por favor, contacta al administrador';
      } else {
        mensajeError = 'Ocurrió un error inesperado: ${e.toString()}';
      }
      
      Get.snackbar(
        tituloError,
        mensajeError,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
      );

      if (!e.toString().contains('DUPLICATE_ENTRY') && !e.toString().contains('CONNECTION_ERROR')) {
        rethrow;
      }
    }
  }

  // Método auxiliar para agregar IDs a la lista de limpieza
  Future<void> _agregarIdsParaLimpieza(String entregaIdOrigen) async {
    try {
      final configBox = Hive.box<AppConfig>('appConfig');
      final config = configBox.get('config');
      
      if (config != null) {
        final idsParaLimpiar = List<String>.from(config.cleanIds);
        // Agregar el ID original y el ID de la reposición
        idsParaLimpiar.add(entregaIdOrigen);
        idsParaLimpiar.add('${entregaIdOrigen}_repo');
        
        // Actualizar la configuración
        final configActualizado = config.copyWith(cleanIds: idsParaLimpiar);
        await configBox.put('config', configActualizado);
        await configBox.flush();
        
        print('✅ IDs agregados para limpieza: $entregaIdOrigen y ${entregaIdOrigen}_repo');
      }
    } catch (e) {
      print('❌ Error al agregar IDs para limpieza: $e');
    }
  }

  // Reposiciones reales pendientes de enviar
  List<RepoEntrega> get reposicionesPendientes => repoBox.values
      .where((repo) => repo.estadoRepo.trim().toLowerCase() == 'pendiente' || repo.estadoRepo.trim().toLowerCase() == 'pendiente')
      .toList();

  // Método para actualizar un bovino en reposición
  Future<void> actualizarBovinoRepo(String repoId, String areteId, String sexo, int edad) async {
    try {
      final repoBox = Hive.box<RepoEntrega>('repoentregas');
      final bovinosBox = Hive.box<BovinoRepo>('bovinosrepo');
      
      // Obtener la reposición
      final repo = repoBox.get(repoId);
      if (repo == null) {
        throw Exception('No se encontró la reposición');
      }
      
      // Buscar el bovino por arete
      BovinoRepo? bovino;
      for (var b in bovinosBox.values) {
        if (b.repoId == repoId && b.arete == areteId) {
          bovino = b;
          break;
        }
      }
      
      if (bovino == null) {
        throw Exception('No se encontró el bovino');
      }
      
      // Actualizar los datos del bovino
      final bovinoActualizado = bovino.copyWith(
        sexo: sexo,
        edad: edad,
      );
      
      // Guardar en Hive
      await bovinosBox.put(bovino.id, bovinoActualizado);
      
      // Actualizar la lista local de reposiciones
      final index = reposListas.indexWhere((r) => r.idRepo == repoId);
      if (index >= 0) {
        // Obtener la lista de bovinos
        List<BovinoRepo> bovinosActualizados = List<BovinoRepo>.from(reposListas[index].detalleBovinos);
        
        // Buscar el bovino por arete en la lista
        for (int i = 0; i < bovinosActualizados.length; i++) {
          if (bovinosActualizados[i].arete == areteId) {
            bovinosActualizados[i] = bovinoActualizado;
            break;
          }
        }
        
        // Actualizar la reposición con la lista actualizada
        reposListas[index] = reposListas[index].copyWith(detalleBovinos: bovinosActualizados);
      }
      
      Get.snackbar(
        'Éxito',
        'Bovino actualizado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error al actualizar bovino en reposición: $e');
      Get.snackbar(
        'Error',
        'No se pudo actualizar el bovino: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  // Método para actualizar un bovino en alta
  Future<void> actualizarBovinoAlta(String altaId, String areteId, String sexo, int edad) async {
    try {
      final altaBox = Hive.box<AltaEntrega>('altaentregas');
      
      // Obtener el alta
      final alta = altaBox.get(altaId);
      if (alta == null) {
        throw Exception('No se encontró el alta');
      }
      
      // Crear una lista nueva con los bovinos actualizados
      List<BovinoResumen> bovinosActualizados = [];
      bool bovinoEncontrado = false;
      
      for (var bovino in alta.detalleBovinos) {
        if (bovino.arete == areteId) {
          // Crear un bovino actualizado
          BovinoResumen bovinoActualizado = BovinoResumen(
            arete: bovino.arete,
            edad: edad,
            sexo: sexo,
            raza: bovino.raza,
            traza: bovino.traza,
            estadoArete: bovino.estadoArete,
            fechaNacimiento: DateTime.now().subtract(Duration(days: edad * 30)),
            fotoArete: bovino.fotoArete,
            areteMadre: bovino.areteMadre,
            aretePadre: bovino.aretePadre,
            regMadre: bovino.regMadre,
            regPadre: bovino.regPadre,
            motivoEstadoAreteId: bovino.motivoEstadoAreteId,
          );
          bovinosActualizados.add(bovinoActualizado);
          bovinoEncontrado = true;
        } else {
          bovinosActualizados.add(bovino);
        }
      }
      
      if (!bovinoEncontrado) {
        throw Exception('No se encontró el bovino con arete $areteId');
      }
      
      // Crear una alta actualizada
      final altaActualizada = alta.copyWith(
        detalleBovinos: bovinosActualizados,
      );
      
      // Guardar en Hive
      await altaBox.put(altaId, altaActualizada);
      
      // Actualizar la lista local
      final index = altasListas.indexWhere((a) => a.idAlta == altaId);
      if (index >= 0) {
        altasListas[index] = altaActualizada;
      }
      
      Get.snackbar(
        'Éxito',
        'Bovino actualizado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error al actualizar bovino en alta: $e');
      Get.snackbar(
        'Error',
        'No se pudo actualizar el bovino: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  // Método auxiliar para eliminar entregas relacionadas
  Future<void> _eliminarEntregasRelacionadas(String repoId, String entregaIdOrigen) async {
    print('🗑️ Eliminando entregas relacionadas...');

    // Asegurar que las cajas estén abiertas
    if (!repoBox.isOpen) repoBox = await Hive.openBox<RepoEntrega>('repoentregas');
    if (!entregasBox.isOpen) await Hive.openBox<Entregas>('entregas');

    // Eliminar la reposición de la caja 'repoentregas'
    await repoBox.delete(repoId);
    await repoBox.flush();
    print('✅ Reposición (' + repoId + ') eliminada de repoBox');

    // Eliminar la entrega de reposición de la caja 'entregas'
    final entregaRepoId = '${entregaIdOrigen}_repo';
    final entregaRepo = entregasBox.get(entregaRepoId);
    if (entregaRepo != null) {
      print('🗑️ Eliminando entrega de reposición (' + entregaRepoId + ') de entregasBox...');
      await entregasBox.delete(entregaRepoId);
      print('✅ Entrega de reposición eliminada');
    } else {
       print('▶️ Entrega de reposición (' + entregaRepoId + ') no encontrada en entregasBox. No se eliminó.');
    }

    // Eliminar la entrega original de la caja 'entregas'
    final entregaOriginal = entregasBox.get(entregaIdOrigen);
    if (entregaOriginal != null) {
      print('🗑️ Eliminando entrega original (' + entregaIdOrigen + ') de entregasBox...');
      await entregasBox.delete(entregaIdOrigen);
      print('✅ Entrega original eliminada');
    } else {
        print('▶️ Entrega original (' + entregaIdOrigen + ') no encontrada en entregasBox. No se eliminó.');
    }

    await entregasBox.flush(); // Ensure changes to entregasBox are written

    // Recargar listas para actualizar la UI
    print('🔄 Recargando listas...');
    cargarReposListas();
    await fetchEntregas();

    // Verificación final
    print('📊 Estado final de las cajas después de eliminación:');
    print('- Entregas en entregasBox: ${entregasBox.length}');
    print('- Reposiciones en repoBox: ${repoBox.length}');

    print('✅ Proceso de eliminación completado');
  }
}
