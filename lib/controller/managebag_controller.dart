import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/data/models/bag/bag_operadora.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';

class ManageBagController extends GetxController {
  // Controllers para los campos de texto
  final TextEditingController departamentoController = TextEditingController();
  final TextEditingController municipioController = TextEditingController();
  final TextEditingController cupaController = TextEditingController();
  final TextEditingController cueController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

  // Observable para la cantidad disponible
  final RxInt cantidadDisponible = 0.obs;

  // Observable para el rango asignado
  final RxString rangoAsignado = ''.obs;

  late Bag bag;

  @override
  void onInit() {
    super.onInit();
    loadBagData();
  }

  /// Cargar los datos del Bag desde Hive
  Future<void> loadBagData() async {
    final box = Hive.box<Bag>('bag');
    if (box.isNotEmpty) {
      bag = box.getAt(0)!;
      cantidadDisponible.value = bag.cantidad;
      rangoAsignado.value =
          '${bag.rangoInicial} - ${bag.rangoInicial + bag.cantidad - 1}';
    }
  }

  Future<void> restoreBag(int cantidad, int rangoInicialEliminado) async {
    final box = Hive.box<Bag>('bag');

    if (box.isNotEmpty) {
      bag = box.getAt(0)!;

      // Restaurar la cantidad y ajustar el rangoInicial
      final nuevoBag = bag.copyWith(
        cantidad: bag.cantidad + cantidad,
        rangoInicial: bag.rangoInicial > rangoInicialEliminado
            ? rangoInicialEliminado
            : bag.rangoInicial,
      );

      await box.putAt(0, nuevoBag);

      // ✅ Recargar los datos del bag para actualizar la UI
      await loadBagData();

      print(
          'Bag restaurado: cantidad=${nuevoBag.cantidad}, rango=${rangoAsignado.value}');
    }
  }

  /// Asignar bag
  Future<void> asignarBag() async {
    final int cantidadAsignar = int.tryParse(cantidadController.text) ?? 0;

    if (cantidadAsignar <= 0 || cantidadAsignar > cantidadDisponible.value) {
      Get.snackbar('Error', 'Cantidad no válida.');
      return;
    }

    final int rangoInicial = bag.rangoInicial;
    final int rangoFinal = rangoInicial + cantidadAsignar - 1;

    // Crear una nueva entrega desde un Bag
    final nuevaEntrega = Entregas(
      entregaId: DateTime.now().millisecondsSinceEpoch.toString(),
      cue: cueController.text,
      cupa: cupaController.text,
      estado: 'Pendiente',
      cantidad: cantidadAsignar,
      rangoInicial: rangoInicial,
      rangoFinal: rangoFinal,
      fechaEntrega: DateTime.now(),
      latitud: 1, // Valor temporal, ajustar según la lógica de la aplicación
      longitud: 1, // Valor temporal, ajustar según la lógica de la aplicación
      nombreProductor: '', // Ajustar según la lógica de la aplicación
      establecimiento: '', // Ajustar según la lógica de la aplicación
      dias: 0, // Ajustar según la lógica de la aplicación
      nombreEstablecimiento: '', // Ajustar según la lógica de la aplicación
      existencia: 0, // Ajustar según la lógica de la aplicación
    );

    // Guardar en Hive la nueva entrega
    final entregasBox = Hive.box<Entregas>('entregas');
    await entregasBox.add(nuevaEntrega);

    // Actualizar bag
    bag = bag.copyWith(
      rangoInicial: rangoFinal + 1,
      cantidad: bag.cantidad - cantidadAsignar,
    );

    // Guardar el bag actualizado en Hive
    final box = Hive.box<Bag>('bag');
    await box.putAt(0, bag);

    // Actualizar UI
    cantidadDisponible.value = bag.cantidad;
    rangoAsignado.value =
        '${bag.rangoInicial} - ${bag.rangoInicial + bag.cantidad - 1}';

    // Limpiar campos
    departamentoController.clear();
    municipioController.clear();
    cupaController.clear();
    cueController.clear();
    cantidadController.clear();

    // Redirigir a FormBovinosView con los datos de la nueva entrega
    Get.toNamed('/formbovinos', arguments: {
      'entregaId': nuevaEntrega.entregaId,
      'cue': nuevaEntrega.cue,
      'rangoInicial': nuevaEntrega.rangoInicial,
      'rangoFinal': nuevaEntrega.rangoFinal,
      'cantidad': nuevaEntrega.cantidad,
    });

    Get.snackbar('Éxito', 'Bovinos listos para registrar.');
  }
}
