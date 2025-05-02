import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trazaapp/data/repositories/consultas/consultasrepo_repo.dart'; // Importar el nuevo repo

class ConsultasRepoController extends GetxController {
  final ConsultasRepoRepo repo = ConsultasRepoRepo(); // Usar el nuevo repo

  final Rx<DateTime> fechaInicio = DateTime.now().obs;
  final Rx<DateTime> fechaFin = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final RxList<dynamic> resultados = <dynamic>[].obs;

  // Variables para filtro y vista (igual que en altas)
  final RxString filterStatus = 'Todos'.obs; // Opciones: Todos, Enviado, Rechazado, Pendiente (o Lista)
  final RxBool isCardView = true.obs; // true para Card, false para Tabla

  // Lista filtrada computada
  List<dynamic> get filteredResultados {
    if (filterStatus.value == 'Todos') {
      return resultados;
    }
    return resultados.where((item) {
      // Usar el campo 'estadoproceso' para filtrar
      final estado = item['estadoproceso']?.toString() ?? '0';
      String estadoTexto;
      switch (estado) {
        case '1':
          estadoTexto = 'Procesado';
          break;
        case '2':
          estadoTexto = 'Rechazado';
          break;
        case '0':
        default:
          estadoTexto = 'Pendiente';
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

  // Método para consultar reposiciones
  Future<void> consultarRepos({required String token, required String codhabilitado}) async {
    isLoading.value = true;
    error.value = null;
    resultados.clear();
    try {
      final DateFormat fmt = DateFormat('yyyy-MM-dd');
      final res = await repo.consultarRepos( // Llamar al método del repo correcto
        fechaInicio: fmt.format(fechaInicio.value),
        fechaFin: fmt.format(fechaFin.value),
        token: token,
        codhabilitado: codhabilitado,
      );
      // La lógica para manejar la respuesta puede ser similar a la de altas
      if (res is List) {
        resultados.assignAll(res);
      } else if (res is Map && res['data'] is List) { // Ajustar si la estructura de respuesta es diferente
        resultados.assignAll(res['data']);
      } else if (res is Map && res.containsKey('message')) {
        // Si la respuesta es un mapa con un mensaje, podría ser un error o sin resultados
        if (res['success'] == false) {
            error.value = res['message'] ?? 'Error desconocido';
        } else {
            error.value = res['message']; // O mostrar como info si no es error
        }
        resultados.assignAll([]);
      } else {
        resultados.assignAll([]);
      }
      print("Resultados consulta repos: ${resultados.length}"); // Log
    } catch (e) {
      print("Error en consultarRepos controller: $e"); // Log
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
} 