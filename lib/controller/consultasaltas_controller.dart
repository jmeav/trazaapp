import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trazaapp/data/repositories/consultas/consultasalta_repo.dart';
import 'package:trazaapp/utils/pdf_generator.dart';
import 'package:trazaapp/presentation/pdf_viewer/pdf_viewer_screen.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:hive/hive.dart';

class ConsultasController extends GetxController {
  final ConsultasRepo repo = ConsultasRepo();

  final Rx<DateTime> fechaInicio = DateTime.now().obs;
  final Rx<DateTime> fechaFin = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  final RxBool isGeneratingPdf = false.obs;
  final RxnString error = RxnString();
  final RxList<dynamic> resultados = <dynamic>[].obs;

  // Nuevas variables para filtro y vista
  final RxString filterStatus = 'Todos'.obs; // Opciones: Todos, Procesado, Rechazado, Pendiente
  final RxBool isCardView = true.obs; // true para Card, false para Tabla

  // Lista filtrada computada
  List<dynamic> get filteredResultados {
    if (filterStatus.value == 'Todos') {
      return resultados;
    }
    return resultados.where((item) {
      final estado = item['estadoproceso']?.toString() ?? '0';
      String estadoTexto;
      switch (estado) {
        case '1': estadoTexto = 'Procesado'; break;
        case '2': estadoTexto = 'Rechazado'; break;
        default: estadoTexto = 'Pendiente';
      }
      return estadoTexto == filterStatus.value;
    }).toList();
  }

  // Método para cambiar el filtro
  void setFilter(String status) {
    filterStatus.value = status;
  }

  // Método para cambiar la vista
  void toggleViewMode() {
    isCardView.value = !isCardView.value;
  }

  Future<void> consultarAltas({required String token, required String codhabilitado}) async {
    isLoading.value = true;
    error.value = null;
    resultados.clear();
    try {
      final DateFormat fmt = DateFormat('yyyy-MM-dd');
      final res = await repo.consultarAltas(
        fechaInicio: fmt.format(fechaInicio.value),
        fechaFin: fmt.format(fechaFin.value),
        token: token,
        codhabilitado: codhabilitado,
      );
      if (res is List) {
        resultados.assignAll(res);
      } else if (res is Map && res['data'] is List) {
        resultados.assignAll(res['data']);
      } else {
        resultados.assignAll([]);
      }
    } catch (e) {
      error.value = "Error consultando: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }

  // Método para generar y mostrar el PDF
  Future<void> generarYMostrarFicha(Map<String, dynamic> altaData) async {
    isGeneratingPdf.value = true;
    try {
      // Obtener el código de habilitado desde Hive
      final appConfigBox = Hive.box<AppConfig>('appConfig');
      final config = appConfigBox.get('config');
      final codHabilitado = config?.codHabilitado ?? '';
      
      // Generar el PDF pasando el código de habilitado
      final pdfPath = await PdfGenerator.generateFichaPdf(
        altaData,
        codHabilitado: codHabilitado,
      );
      
      Get.to(() => PdfViewerScreen(pdfPath: pdfPath));
    } catch (e) {
      Get.snackbar(
        'Error al generar PDF',
        'No se pudo crear la ficha: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isGeneratingPdf.value = false;
    }
  }
} 