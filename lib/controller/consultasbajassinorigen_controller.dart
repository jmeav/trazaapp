import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trazaapp/data/repositories/consultas/consultasbajassinorigen_repo.dart';

class ConsultasBajasSinOrigenController extends GetxController {
  final ConsultasBajasSinOrigenRepo repo = ConsultasBajasSinOrigenRepo();

  final Rx<DateTime> fechaInicio = DateTime.now().obs;
  final Rx<DateTime> fechaFin = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final RxList<dynamic> resultados = <dynamic>[].obs;

  final RxString filterStatus = 'Todos'.obs; // 'Todos', 'Procesado', 'Rechazado', 'Pendiente'
  final RxBool isCardView = true.obs;

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
        case '0':
        default: estadoTexto = 'Pendiente';
      }
      return estadoTexto == filterStatus.value;
    }).toList();
  }

  void setFilter(String status) {
    filterStatus.value = status;
  }

  void toggleViewMode() {
    isCardView.toggle();
    update(); // Forzar actualización de la UI
  }

  Future<void> consultarBajasSinOrigen({required String token, required String codhabilitado}) async {
    isLoading.value = true;
    error.value = null;
    resultados.clear();
    try {
      final DateFormat fmt = DateFormat('yyyy-MM-dd');
      final res = await repo.consultarBajasSinOrigen(
        fechaInicio: fmt.format(fechaInicio.value),
        fechaFin: fmt.format(fechaFin.value),
        token: token,
        codhabilitado: codhabilitado,
      );
      if (res is List) {
        resultados.assignAll(res);
      } else if (res is Map && res['data'] is List) {
        resultados.assignAll(res['data']);
      } else if (res is Map && res.containsKey('message')) {
        if (res['success'] == false) {
          error.value = res['message'] ?? 'Error desconocido';
        } else {
          error.value = res['message'];
        }
        resultados.assignAll([]);
      } else {
        resultados.assignAll([]);
      }
      print("Resultados consulta bajas sin origen: ${resultados.length}");
    } catch (e) {
      print("Error en consultarBajasSinOrigen controller: $e");
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
} 