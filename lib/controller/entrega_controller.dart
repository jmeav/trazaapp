import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import 'package:trazaapp/controller/managebag_controller.dart';
import 'package:trazaapp/data/models/altaentrega/altaentrega.dart';
import 'package:trazaapp/data/models/bovinos/bovino.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/data/models/repo/repoentrega.dart';
import 'package:trazaapp/utils/util.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
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
      // Asegurarse que todas las cajas necesarias se abren aquí
      if (!entregasBox.isOpen) await Hive.openBox<Entregas>('entregas');
      if (!altaEntregaBox.isOpen) await Hive.openBox<AltaEntrega>('altaentregas');
      repoBox = await Hive.openBox<RepoEntrega>('repoentregas'); // repoBox se abre aquí
      
      await fetchUserLocation();
      await fetchEntregas();
      _listenLocationChanges();
      cargarAltasListas();
      cargarReposListas(); // Ahora se llama después de abrir repoBox
      isInitialized.value = true;
    } catch (e) {
       print("Error en onInit EntregaController: $e");
       // Considera mostrar un Get.snackbar de error aquí si la inicialización falla
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
             .where((repo) => repo.estadoRepo.trim().toLowerCase() == 'lista')
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
          print("Advertencia: entregasBox no está abierta en fetchEntregas.");
          return; 
        }
        final values = entregasBox.values.toList();

        // Eliminar duplicados por entregaId (conservando el último)
        final mapaUnico = <String, Entregas>{};
        for (var entrega in values) {
          mapaUnico[entrega.entregaId] = entrega;
        }

        entregas.assignAll(mapaUnico.values.toList());
        print("Entregas cargadas: ${entregas.length}");

        updateDistances();
    } catch (e) {
        print("Error en fetchEntregas: $e");
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

      // NO creamos un diálogo aquí para evitar duplicación
      // Ya que el código que llama a esta función (en send_view.dart) ya muestra su propio diálogo

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

        // NO cerramos ningún diálogo aquí
        // La función que llamó a este método debe encargarse de cerrar su propio diálogo

        Get.snackbar(
          'Éxito',
          'Alta enviada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return; // Retornamos éxito
      } else {
        throw Exception(
            'Error al enviar alta: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // NO cerramos ningún diálogo aquí
      // La función que llamó a este método debe encargarse de cerrar su propio diálogo
      
      Get.snackbar(
        'Error',
        'Error al enviar alta: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('❌ Error en enviarAlta: $e');
      throw e; // Re-lanzamos la excepción para que el llamador sepa que falló
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
        // Excluir las que ya tienen un RepoEntrega con estado 'lista'
        !_tieneRepoListaAsociada(entrega.entregaId)
      )
      .toList();

  // Método auxiliar para verificar si existe una RepoEntrega asociada con estado 'lista'
  bool _tieneRepoListaAsociada(String entregaId) {
    if (!repoBox.isOpen) return false; // Si no está abierto aún, asumir que no existe
    
    // Extraer el ID base de la entrega (quitar el sufijo _repo si existe)
    final idBase = entregaId.endsWith('_repo') 
        ? entregaId.substring(0, entregaId.length - 5)
        : entregaId;
    
    // Verificar si existe alguna RepoEntrega con este entregaIdOrigen y estado 'lista'
    return repoBox.values.any((repo) => 
        repo.entregaIdOrigen == idBase && 
        repo.estadoRepo.trim().toLowerCase() == 'lista'
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
    final envioReposicionRepository = EnvioReposicionRepository();
    final repo = repoBox.get(repoId);
    if (repo == null) {
      Get.snackbar('Error', 'No se encontró la reposición con ID: $repoId');
      return;
    }
    try {
      await envioReposicionRepository.enviarReposicion(repo.toJsonEnvio());
      // Si el envío fue exitoso, actualiza el estado localmente
      final repoActualizado = repo.copyWith(estadoRepo: 'Enviada');
      await repoBox.put(repoId, repoActualizado);
      // Recarga la lista para que desaparezca de "listas para enviar"
     cargarReposListas();
    } catch (e) {
      // El error ya se muestra en el repositorio
    }
  }

  // Reposiciones reales pendientes de enviar
  List<RepoEntrega> get reposicionesPendientes => repoBox.values
      .where((repo) => repo.estadoRepo.trim().toLowerCase() == 'pendiente' || repo.estadoRepo.trim().toLowerCase() == 'pendiente')
      .toList();
}
