import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trazaapp/data/models/bag/bag.dart';
import 'package:hive/hive.dart';

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

  // Cargar los datos del bolsón desde Hive
  // Cargar datos del Bag
  Future<void> loadBagData() async {
    final box = Hive.box<Bag>('bag');
    if (box.isNotEmpty) {
      bag = box.getAt(0)!; // Asumiendo que hay un Bag disponible
      cantidadDisponible.value = bag.cantidad;
    }
  }

  // Asignar bag
  Future<void> asignarBag() async {
    final int cantidadAsignar = int.tryParse(cantidadController.text) ?? 0;

    if (cantidadAsignar <= 0 || cantidadAsignar > cantidadDisponible.value) {
      Get.snackbar('Error', 'Cantidad no válida.');
      return;
    }

    final int rangoInicial = bag.rangoInicial;
    final int rangoFinal = rangoInicial + cantidadAsignar - 1;

    // Actualizar bag
    bag = bag.copyWith(
      rangoInicial: rangoFinal + 1,
      cantidad: bag.cantidad - cantidadAsignar,
    );

    // Guardar en Hive
    final box = Hive.box<Bag>('bag');
    await box.putAt(0, bag);

    // Actualizar observables
    cantidadDisponible.value = bag.cantidad;
    rangoAsignado.value = '$rangoInicial-$rangoFinal';

    // Limpiar campos
    departamentoController.clear();
    municipioController.clear();
    cupaController.clear();
    cueController.clear();
    cantidadController.clear();

    Get.snackbar('Éxito', 'Rango asignado: $rangoInicial-$rangoFinal');
  }
}
