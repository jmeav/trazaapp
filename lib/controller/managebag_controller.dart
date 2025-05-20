import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/bag/bag_operadora.dart';
import 'package:trazaapp/data/local/models/entregas/entregas.dart';
import 'package:trazaapp/data/local/models/departamentos/departamento.dart';
import 'package:trazaapp/data/local/models/municipios/municipio.dart';
import 'package:trazaapp/data/local/models/establecimiento/establecimiento.dart';
import 'package:trazaapp/data/local/models/productores/productor.dart';
import 'package:trazaapp/presentation/homescreen/home.dart';
import 'package:trazaapp/presentation/scanner/scanner_view.dart';
import 'package:trazaapp/utils/util.dart';

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
  final RxList<int> aretesDisponibles = <int>[].obs; // Nueva gestión de aretes

  // Variables para rangos mixtos
  final RxBool permitirRangosMixtos = true.obs;
  final RxBool mostrarRangosDisponibles = false.obs;
  final RxList<List<int>> rangosConsecutivos = <List<int>>[].obs;

  @override
  void onInit() {
    super.onInit();
    cargarCatalogos();
    _cargarAretesDisponibles();
    loadBagData(); // 🔹 Refrescar la cantidad de aretes disponibles
  }

  /// Cargar los datos del Bag desde Hive
  Future<void> _cargarAretesDisponibles() async {
    final box = Hive.box<Bag>('bag');
    if (box.isEmpty) return;

      bag = box.getAt(0)!;
    print("📦 Cargando aretes desde Bag:");
    print("  Rango Principal Inicial: ${bag.rangoInicial}, Cant: ${bag.cantidad}, Exist: ${bag.existencia}");

    List<int> todosLosAretes = [];

    // Agregar aretes del rango principal
    if (bag.existencia > 0) {
      int rangoInicialDisponible = bag.rangoInicial + (bag.cantidad - bag.existencia);
      print("  Calculando Rango Principal Disponible: $rangoInicialDisponible (inicio ${bag.rangoInicial} + (total ${bag.cantidad} - existe ${bag.existencia}))");
      todosLosAretes.addAll(
          List.generate(bag.existencia, (i) => rangoInicialDisponible + i));
      print("    -> Agregados ${bag.existencia} aretes: $rangoInicialDisponible - ${rangoInicialDisponible + bag.existencia - 1}");
    }

    // Agregar aretes de rangos adicionales
    for (var rango in bag.rangosAdicionales) {
      print("  Rango Adicional ID ${rango.id}: ${rango.rangoInicial}, Cant: ${rango.cantidad}, Exist: ${rango.existencia}");
      if (rango.existencia > 0) {
        int rangoInicialDisponible = rango.rangoInicial + (rango.cantidad - rango.existencia);
        print("    Calculando Rango Adicional Disponible: $rangoInicialDisponible (inicio ${rango.rangoInicial} + (total ${rango.cantidad} - existe ${rango.existencia}))");
        todosLosAretes.addAll(
            List.generate(rango.existencia, (i) => rangoInicialDisponible + i));
        print("      -> Agregados ${rango.existencia} aretes: $rangoInicialDisponible - ${rangoInicialDisponible + rango.existencia - 1}");
      }
    }

    // Filtrar los aretes que ya fueron usados (esto podría ser redundante si la existencia se maneja bien)
    // Considerar eliminar este filtro si confiamos en la existencia
    final entregasBox = Hive.box<Entregas>('entregas');
    List<int> aretesUsados = [];
    for (var entrega in entregasBox.values) {
      if (entrega.aretesAsignados != null) {
        aretesUsados.addAll(entrega.aretesAsignados);
      }
    }
    
    aretesDisponibles.value = todosLosAretes
        .where((arete) => !aretesUsados.contains(arete))
        .toSet() // Usar Set para eliminar duplicados si los hubiera
              .toList();
    
    aretesDisponibles.sort(); // Asegurar que estén ordenados

      cantidadDisponible.value = aretesDisponibles.length;
      rangoAsignado.value = aretesDisponibles.isNotEmpty
          ? '${aretesDisponibles.first} - ${aretesDisponibles.last}'
          : 'Sin aretes disponibles';

    _calcularRangosConsecutivos();

    print("🔄 Aretes disponibles cargados y filtrados: ${aretesDisponibles.length}");
    print("📊 Rangos consecutivos calculados: ${rangosConsecutivos.length}");
    // for (var rango in rangosConsecutivos) {
    //   print("  • ${rango.first}-${rango.last} (${rango.length})");
    // }

      update();
  }

  /// Verificar si un arete ya fue usado
  bool areteYaUsado(int arete) {
    final entregasBox = Hive.box<Entregas>('entregas');
    return entregasBox.values
        .any((e) => e.rangoInicial <= arete && arete <= e.rangoFinal);
  }

  /// Calcular rangos consecutivos disponibles
  void _calcularRangosConsecutivos() {
    if (aretesDisponibles.isEmpty) {
      rangosConsecutivos.clear();
      return;
    }

    List<List<int>> rangos = [];
    List<int> rangoActual = [aretesDisponibles.first];

    for (int i = 1; i < aretesDisponibles.length; i++) {
      if (aretesDisponibles[i] == aretesDisponibles[i - 1] + 1) {
        // Es consecutivo, añadir al rango actual
        rangoActual.add(aretesDisponibles[i]);
      } else {
        // No es consecutivo, cerrar el rango actual y empezar uno nuevo
        rangos.add(List.from(rangoActual));
        rangoActual = [aretesDisponibles[i]];
      }
    }

    // Añadir el último rango
    if (rangoActual.isNotEmpty) {
      rangos.add(List.from(rangoActual));
    }

    rangosConsecutivos.value = rangos;
  }

  /// Cargar catálogos al iniciar
  Future<void> cargarCatalogos() async {
    try {
      if (!Hive.isBoxOpen('departamentos'))
        await Hive.openBox<Departamento>('departamentos');
      if (!Hive.isBoxOpen('municipios'))
        await Hive.openBox<Municipio>('municipios');
      if (!Hive.isBoxOpen('establecimientos'))
        await Hive.openBox<Establecimiento>('establecimientos');
      if (!Hive.isBoxOpen('productores'))
        await Hive.openBox<Productor>('productores');

      departamentos
          .assignAll(Hive.box<Departamento>('departamentos').values.toList());
      municipios.assignAll(Hive.box<Municipio>('municipios').values.toList());
      establecimientos.assignAll(
          Hive.box<Establecimiento>('establecimientos').values.toList());
      productores.assignAll(Hive.box<Productor>('productores').values.toList());

      update();
    } catch (e) {
      print('Error al cargar catálogos: $e');
      Get.snackbar('Error', 'No se pudieron cargar los catálogos.');
    }
  }

  /// Cargar datos del bag y actualizar la UI
  Future<void> loadBagData() async {
    final box = Hive.box<Bag>('bag');
    if (box.isNotEmpty) {
      bag = box.getAt(0)!;
      cantidadDisponible.value = aretesDisponibles.length;
      rangoAsignado.value = aretesDisponibles.isNotEmpty
          ? '${aretesDisponibles.first} - ${aretesDisponibles.last}'
          : 'Sin aretes disponibles';

      print('🔄 Bag actualizado: cantidad=${cantidadDisponible.value}, '
          'rango=${rangoAsignado.value}');
    }
  }

  void resetForm() {
    // 🔹 Limpiar controladores de texto
    departamentoController.clear();
    municipioController.clear();
    cupaController.clear();
    cueController.clear();
    cantidadController.clear();

    // 🔹 Resetear los valores de los `DropdownButton`
    departamentoSeleccionado.value = '';
    municipioSeleccionado.value = '';

    // 🔹 Limpiar las consultas de `Autocomplete`
    queryEstablecimiento.value = '';
    queryProductor.value = '';

    // 🔹 Forzar actualización de la vista
    update();
  }

  // Método para seleccionar exactamente la cantidad de aretes requeridos, aunque implique partir un rango adicional
  List<int> _seleccionarAretesExactos(int cantidad) {
    List<int> seleccionados = [];
    int cantidadRestante = cantidad;
    for (var rango in rangosConsecutivos) {
      if (cantidadRestante == 0) break;
      if (rango.length <= cantidadRestante) {
        seleccionados.addAll(rango);
        cantidadRestante -= rango.length;
      } else {
        seleccionados.addAll(rango.sublist(0, cantidadRestante));
        cantidadRestante = 0;
      }
    }
    return seleccionados;
  }

  Future<bool> asignarAretes(int cantidad) async {
    if (aretesDisponibles.isEmpty) {
      Get.snackbar('Error', 'No hay aretes disponibles');
      return false;
    }

    if (cantidad > aretesDisponibles.length) {
      Get.snackbar('Error', 'No hay suficientes aretes disponibles (${aretesDisponibles.length} disponibles)');
      return false;
    }

    // Buscar rango consecutivo exacto
    List<int>? rangoConsecutivoOptimo = _buscarRangoConsecutivoOptimo(cantidad);
    if (rangoConsecutivoOptimo != null) {
      return await asignarEntrega(rangoConsecutivoOptimo, false);
      } else {
      // Seleccionar exactamente la cantidad de aretes, aunque implique partir un rango adicional
      List<int> aretesExactos = _seleccionarAretesExactos(cantidad);
      if (aretesExactos.length != cantidad) {
        Get.snackbar('Error', 'No se pueden asignar los aretes solicitados');
        return false;
      }
      return await asignarEntrega(aretesExactos, true);
    }
  }

  List<int>? _buscarRangoConsecutivoOptimo(int cantidad) {
    // Buscar un rango consecutivo que satisfaga exactamente la cantidad
    for (var rango in rangosConsecutivos) {
      if (rango.length == cantidad) {
        return rango;
      }
    }
    
    // Si no hay rango exacto, buscar el rango consecutivo más pequeño que satisface la cantidad
    for (var rango in rangosConsecutivos.where((r) => r.length >= cantidad)) {
      return rango.sublist(0, cantidad);
    }
    
    return null;
  }

  void _mostrarDialogAsignacionManual(int cantidad) {
    Get.dialog(
      AlertDialog(
        title: Text('Asignación de Aretes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No se encontró un rango óptimo para asignar $cantidad aretes.'),
            SizedBox(height: 8),
            Text('Opciones disponibles:'),
            ...rangosConsecutivos.map((rango) => 
          TextButton(
            onPressed: () {
              Get.back();
                  if (rango.length >= cantidad) {
                    asignarEntrega(rango.sublist(0, cantidad), false);
                  } else {
                    Get.snackbar('Error', 'El rango seleccionado no tiene suficientes aretes');
                  }
            },
                child: Text('Rango ${rango.first}-${rango.last} (${rango.length} aretes)')
              )
            ).toList(),
            
        TextButton(
          onPressed: () {
            Get.back();
          },
              child: Text('Usar rangos mixtos'),
        ),
      ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  String resolveDepartamento(String? idDept) {
    final dep = Hive.box<Departamento>('departamentos').values.firstWhere(
        (d) => d.idDepartamento == idDept,
        orElse: () => Departamento(
            idDepartamento: idDept ?? '', departamento: 'Desconocido'));
    return dep.departamento;
  }

  String resolveMunicipio(String? idMun) {
    final mun = Hive.box<Municipio>('municipios').values.firstWhere(
        (m) => m.idMunicipio == idMun,
        orElse: () => Municipio(
            idMunicipio: idMun ?? '',
            municipio: 'Desconocido',
            idDepartamento: ''));
    return mun.municipio;
  }

  Future<bool> asignarEntrega(List<int> asignados, bool esRangoMixto) async {
    if (asignados.isEmpty) {
      Get.snackbar("Error", "No se pudo asignar la entrega.");
      return false;
    }

    print("📝 Iniciando asignación de entrega:");
    print("  • Aretes a asignar: ${asignados.length}");
    print("  • Rango: ${asignados.first}-${asignados.last}");
    print("  • Es rango mixto: $esRangoMixto");

    // Guardar todos los aretes originales antes de cualquier modificación
    List<int> todosLosAretesAsignados = List.from(asignados);

    final Establecimiento? establecimientoSeleccionado =
        establecimientos.firstWhereOrNull(
            (e) => e.establecimiento.trim() == cueController.text.trim());

    final Productor? productorSeleccionado = productores.firstWhereOrNull(
        (p) => p.productor.trim() == cupaController.text.trim());

    final double latitud =
        double.tryParse(establecimientoSeleccionado?.latitud ?? '0.0') ?? 0.0;
    final double longitud =
        double.tryParse(establecimientoSeleccionado?.longitud ?? '0.0') ?? 0.0;

    // Detectar subrangos dentro de los aretes asignados (máximo 2)
    List<List<int>> subRangos = [];
    List<int> rangoActual = [asignados.first];
    for (int i = 1; i < asignados.length; i++) {
      if (asignados[i] == asignados[i-1] + 1) {
        rangoActual.add(asignados[i]);
      } else {
        subRangos.add(List.from(rangoActual));
        rangoActual = [asignados[i]];
      }
    }
    if (rangoActual.isNotEmpty) {
      subRangos.add(List.from(rangoActual));
    }
    // Limitar a máximo 2 subrangos
    if (subRangos.length > 2) {
      subRangos = subRangos.sublist(0, 2);
    }
    String? rangoInicialExt;
    String? rangoFinalExt;
    int aretesEnRangoExt = 0;
    if (subRangos.length == 2) {
      rangoInicialExt = subRangos[1].first.toString();
      rangoFinalExt = subRangos[1].last.toString();
      aretesEnRangoExt = subRangos[1].length;
    }
    // Eliminar TODOS los aretes asignados de aretesDisponibles
    aretesDisponibles.removeWhere((a) => todosLosAretesAsignados.contains(a));
    // Actualizar la cantidad disponible y el rango asignado
    cantidadDisponible.value = aretesDisponibles.length;
    rangoAsignado.value = aretesDisponibles.isNotEmpty
        ? '${aretesDisponibles.first} - ${aretesDisponibles.last}'
        : 'Sin aretes disponibles';
    // Actualizar el bag en Hive
    final box = Hive.box<Bag>('bag');
    if (box.isNotEmpty) {
      bag = box.getAt(0)!;
      print("📦 Actualizando existencias en Bag:");
      
      int usadosPrincipal = 0;
      // Usar una copia modificable de rangosAdicionales
      List<RangoBag> rangosAdicionalesActualizados = List.from(bag.rangosAdicionales);
      Map<int, int> usosPorRangoAdicional = {}; // ID -> cantidad usada

      for (var arete in todosLosAretesAsignados) {
        // Verificar rango principal
        int inicioPrincipalDisp = bag.rangoInicial + (bag.cantidad - bag.existencia);
        int finPrincipalDisp = inicioPrincipalDisp + bag.existencia - 1;
        if (bag.existencia > 0 && arete >= inicioPrincipalDisp && arete <= finPrincipalDisp) {
          usadosPrincipal++;
        } else {
          // Verificar rangos adicionales
          bool encontradoAdicional = false;
          for (int i = 0; i < rangosAdicionalesActualizados.length; i++) {
            var rango = rangosAdicionalesActualizados[i];
            if (rango.existencia > 0) {
              int inicioAdicionalDisp = rango.rangoInicial + (rango.cantidad - rango.existencia);
              int finAdicionalDisp = inicioAdicionalDisp + rango.existencia - 1;
              if (arete >= inicioAdicionalDisp && arete <= finAdicionalDisp) {
                usosPorRangoAdicional[rango.id] = (usosPorRangoAdicional[rango.id] ?? 0) + 1;
                encontradoAdicional = true;
                break; // Pasar al siguiente arete asignado
              }
            }
          }
          if (!encontradoAdicional) {
             print("⚠️ Advertencia: Arete asignado $arete no encontrado en rangos disponibles para actualizar existencia.");
          }
        }
      }

      // Aplicar actualizaciones
      if (usadosPrincipal > 0) {
        print("  📉 Descontando $usadosPrincipal del Rango Principal (Existencia actual: ${bag.existencia})");
        bag = bag.copyWith(existencia: bag.existencia - usadosPrincipal);
        print("     Nueva existencia principal: ${bag.existencia}");
      }

      usosPorRangoAdicional.forEach((idRango, cantidadUsada) {
         int index = rangosAdicionalesActualizados.indexWhere((r) => r.id == idRango);
         if (index != -1) {
            var rangoOriginal = rangosAdicionalesActualizados[index];
            print("  📉 Descontando $cantidadUsada del Rango Adicional ID $idRango (Existencia actual: ${rangoOriginal.existencia})");
            // Crear nuevo RangoBag con existencia actualizada (Hive no permite modificar objetos directamente en la lista)
            rangosAdicionalesActualizados[index] = RangoBag(
                id: rangoOriginal.id,
                rangoInicial: rangoOriginal.rangoInicial,
                rangoFinal: rangoOriginal.rangoFinal,
                cantidad: rangoOriginal.cantidad,
                existencia: rangoOriginal.existencia - cantidadUsada,
                dias: rangoOriginal.dias
            );
             print("     Nueva existencia Rango ID $idRango: ${rangosAdicionalesActualizados[index].existencia}");
         } else {
             print("⚠️ Error: No se encontró el Rango Adicional ID $idRango para actualizar.");
         }
      });

      // Guardar el bag con la lista de rangos adicionales actualizada
      bag = bag.copyWith(rangosAdicionales: rangosAdicionalesActualizados);
      await box.putAt(0, bag);
      print("💾 Bag guardado en Hive con existencias actualizadas.");

      // Recalcular rangos consecutivos para la UI (opcional aquí, ya se hizo antes)
      // _calcularRangosConsecutivos(); 
    } else {
      print("📦 Error: No se encontró el Bag en Hive para actualizar existencias.");
    }

    final nuevaEntrega = Entregas(
      entregaId: (100000 + Random().nextInt(900000)).toString(),
      fechaEntrega: DateTime.now(),
      cupa: cupaController.text,
      cue: cueController.text,
      rangoInicial: subRangos.isNotEmpty ? subRangos[0].first : 0, // Usar el primer subrango
      rangoFinal: subRangos.isNotEmpty ? subRangos[0].last : 0,
      cantidad: todosLosAretesAsignados.length, // Cantidad total real
      existencia: todosLosAretesAsignados.length, // O mantener la lógica anterior si es necesario
      nombreProductor: productorSeleccionado?.nombreProductor ?? 'Desconocido',
      establecimiento:
          cueController.text.isNotEmpty ? cueController.text : 'No asignado',
      dias: 0,
      nombreEstablecimiento:
          establecimientoSeleccionado?.nombreEstablecimiento ?? 'No encontrado',
      latitud: latitud,
      longitud: longitud,
      distanciaCalculada: null,
      estado: 'pendiente',
      lastUpdate: DateTime.now(),
      tipo: 'manual',
      fotoBovInicial: '',
      fotoBovFinal: '',
      reposicion: false,
      observaciones: '',
      departamento:
          resolveDepartamento(establecimientoSeleccionado?.idDepartamento),
      municipio: resolveMunicipio(establecimientoSeleccionado?.idMunicipio),
      rangoInicialExt: rangoInicialExt,
      rangoFinalExt: rangoFinalExt,
      esRangoMixto: esRangoMixto,
      aretesAsignados: todosLosAretesAsignados,
    );
    final entregasBox = Hive.box<Entregas>('entregas');
    await entregasBox.put(nuevaEntrega.entregaId, nuevaEntrega);

    // Preparar argumentos para la siguiente pantalla (si aplica)
    // List<String> aretesParaForm = todosLosAretesAsignados.map((e) => e.toString()).toList();
    // print("📋 Aretes para formbovinos_view.dart: ${aretesParaForm.length}");

    // Navegar al Home
    Get.snackbar(
      'Éxito',
      'Entrega registrada correctamente.',
      backgroundColor: AppColors.snackSuccess,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
    await Future.delayed(const Duration(milliseconds: 1500));
    Get.offUntil(
      GetPageRoute(page: () => HomeView()), 
      (route) => false,
    );
    return true;
  }

  /// Restaurar Bag cuando se elimina una entrega
  Future<void> restoreBag(int cantidad, int rangoInicialEliminado) async {
    final box = Hive.box<Bag>('bag');

    if (box.isNotEmpty) {
      bag = box.getAt(0)!;

      // Restaurar la cantidad y agregar los aretes eliminados de nuevo al stock
      aretesDisponibles
          .addAll(List.generate(cantidad, (i) => rangoInicialEliminado + i));
      aretesDisponibles.sort(); // Ordenar para evitar saltos

      cantidadDisponible.value = aretesDisponibles.length;
      rangoAsignado.value = aretesDisponibles.isNotEmpty
          ? '${aretesDisponibles.first} - ${aretesDisponibles.last}'
          : 'Sin aretes disponibles';
      
      // Recalcular rangos consecutivos
      _calcularRangosConsecutivos();

      await box.putAt(0, bag);

      print('Bag restaurado: cantidad=${cantidadDisponible.value}, '
          'rango=${rangoAsignado.value}');
    }
  }

  Future<void> eliminarEntrega(String entregaId) async {
    final entregasBox = Hive.box<Entregas>('entregas');
    final entrega = entregasBox.get(entregaId);

    if (entrega == null) {
      Get.snackbar('Error', 'No se encontró la entrega.');
      return;
    }

    // Devolver aretes al stock
    List<int> aretesARestaurar = List.generate(
      entrega.rangoFinal - entrega.rangoInicial + 1, 
      (i) => entrega.rangoInicial + i
    );
    
    // Si hay rango extendido, también restaurarlo
    if (entrega.esRangoMixto && entrega.rangoInicialExt != null && entrega.rangoFinalExt != null) {
      final rangoInicialExt = int.parse(entrega.rangoInicialExt!);
      final rangoFinalExt = int.parse(entrega.rangoFinalExt!);
      
      List<int> aretesExtensionARestaurar = List.generate(
        rangoFinalExt - rangoInicialExt + 1, 
        (i) => rangoInicialExt + i
      );
      
      aretesARestaurar.addAll(aretesExtensionARestaurar);
      
      print("🔄 Restaurando ${aretesARestaurar.length} aretes: " 
            "Principal ${entrega.rangoInicial}-${entrega.rangoFinal} + "
            "Extension $rangoInicialExt-$rangoFinalExt");
    }
    
    // Agregar todos los aretes al stock y ordenar
    aretesDisponibles.addAll(aretesARestaurar);
    aretesDisponibles.sort();

    await entregasBox.delete(entregaId);

    // Actualizar UI
    cantidadDisponible.value = aretesDisponibles.length;
    rangoAsignado.value = aretesDisponibles.isNotEmpty
        ? '${aretesDisponibles.first} - ${aretesDisponibles.last}'
        : 'Sin aretes disponibles';
    
    // Recalcular rangos consecutivos
    _calcularRangosConsecutivos();

    update();

    Get.snackbar(
      'Éxito',
      'Entrega eliminada y aretes devueltos al stock.',
      backgroundColor: AppColors.snackSuccess,
      colorText: Colors.white,
    );
  }

  /// Buscar establecimientos por municipio y nombre
  Future<List<Establecimiento>> buscarEstablecimientos(String query) async {
    if (query.isEmpty || municipioSeleccionado.value.isEmpty) return [];

    final box = Hive.box<Establecimiento>('establecimientos');
    return box.values
        .where((e) =>
            e.idMunicipio == municipioSeleccionado.value &&
            (e.nombreEstablecimiento
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
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

  /// Escanear código de barras
  Future<void> scanCode(String type) async {
    final result = await Get.to(() => ScannerView());
    if (result != null) {
      if (type == 'cue') {
        // Buscar el establecimiento por código
        final establecimiento = establecimientos.firstWhereOrNull(
          (e) => e.establecimiento.trim() == result.trim()
        );
        
        if (establecimiento != null) {
          cueController.text = establecimiento.establecimiento;
          // Actualizar departamento y municipio
          departamentoSeleccionado.value = establecimiento.idDepartamento;
          filtrarMunicipios(establecimiento.idDepartamento);
          municipioSeleccionado.value = establecimiento.idMunicipio;
          update();
        } else {
          Get.snackbar(
            'Error',
            'Establecimiento no encontrado',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else if (type == 'cupa') {
        // Buscar el productor por código
        final productor = productores.firstWhereOrNull(
          (p) => p.productor.trim() == result.trim()
        );
        
        if (productor != null) {
          cupaController.text = productor.productor;
          update();
        } else {
          Get.snackbar(
            'Error',
            'Productor no encontrado',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    }
  }

  /// Mostrar detalles de todos los rangos disponibles
  void mostrarDetallesBag() {
    if (bag.rangosAdicionales.isEmpty) {
      Get.dialog(
        AlertDialog(
          title: Text('Información del Bolsón'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rango Principal:'),
              Text('• Rango: ${bag.rangoInicial} - ${bag.rangoFinal}'),
              Text('• Cantidad total: ${bag.cantidad}'),
              Text('• Aretes disponibles: ${bag.existencia}'),
              SizedBox(height: 8),
              Text('No hay rangos adicionales'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
      } else {
      Get.dialog(
        AlertDialog(
          title: Text('Información del Bolsón'),
          contentPadding: EdgeInsets.only(left: 24, right: 24, top: 20),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 400),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text('Rango Principal:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Rango: ${bag.rangoInicial} - ${bag.rangoFinal}'),
                Text('• Cantidad total: ${bag.cantidad}'),
                Text('• Aretes disponibles: ${bag.existencia}'),
                Divider(),
                Text('Rangos adicionales:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...bag.rangosAdicionales.map((rango) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• Rango: ${rango.rangoInicial} - ${rango.rangoFinal}'),
                      Text('• Cantidad total: ${rango.cantidad}'),
                      Text('• Aretes disponibles: ${rango.existencia}'),
                    ],
                  ),
                )).toList(),
                Divider(),
                Text('Total general:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Aretes disponibles en todos los rangos: ${bag.existenciaTotal}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  // Para gestión de rangos residuales
  List<List<int>> get rangosResiduales => rangosConsecutivos.where((r) => r.length < 20).toList();
  
  bool get tieneRangosResiduales => rangosResiduales.isNotEmpty;
  
  void mostrarRangosResiduales() {
    if (!tieneRangosResiduales) {
      Get.snackbar(
        'Información', 
        'No hay rangos residuales disponibles',
        backgroundColor: Colors.orange,
        colorText: Colors.white
      );
      return;
    }
    
    final rangos = rangosResiduales;
    Get.dialog(
      AlertDialog(
        title: const Text('Rangos Residuales Disponibles'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: rangos.length,
            itemBuilder: (context, index) {
              final rango = rangos[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('Rango ${index + 1}'),
                  subtitle: Text('${rango.first} - ${rango.last} (${rango.length} aretes)'),
                  trailing: ElevatedButton(
                    child: const Text('Usar'),
                    onPressed: () {
                      Get.back();
                      // Usar este rango para una entrega
                      _usarRangoResidual(rango);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
  
  void _usarRangoResidual(List<int> rango) {
    // Preparamos los campos para la entrega con este rango residual
    cantidadController.text = rango.length.toString();
    
    Get.snackbar(
      'Rango seleccionado', 
      'Se usará el rango ${rango.first} - ${rango.last} (${rango.length} aretes)',
      backgroundColor: Colors.green,
      colorText: Colors.white
    );
  }
}

