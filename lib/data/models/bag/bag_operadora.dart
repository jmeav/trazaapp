import 'package:hive/hive.dart';

@HiveType(typeId: 6)
class Bag {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int rangoInicial;

  @HiveField(2)
  final int rangoFinal;

  @HiveField(3)
  final int cantidad;

  @HiveField(4)
  final int dias;

  @HiveField(5)
  final int existencia;
  
  // Lista de rangos adicionales
  @HiveField(6)
  final List<RangoBag> rangosAdicionales;

  Bag({
    required this.id,
    required this.rangoInicial,
    required this.rangoFinal,
    required this.cantidad,
    required this.dias,
    required this.existencia,
    this.rangosAdicionales = const [],
  });

  // Método copyWith para crear una copia modificada del objeto
  Bag copyWith({
    int? id,
    int? rangoInicial,
    int? rangoFinal,
    int? cantidad,
    int? dias,
    int? existencia,
    List<RangoBag>? rangosAdicionales,
  }) {
    return Bag(
      id: id ?? this.id,
      rangoInicial: rangoInicial ?? this.rangoInicial,
      rangoFinal: rangoFinal ?? this.rangoFinal,
      cantidad: cantidad ?? this.cantidad,
      dias: dias ?? this.dias,
      existencia: existencia ?? this.existencia,
      rangosAdicionales: rangosAdicionales ?? this.rangosAdicionales,
    );
  }

  // Constructor factory para crear un objeto Bag a partir de un JSON
  factory Bag.fromJson(Map<String, dynamic> json) {
    print("🔄 Bag.fromJson recibió: $json");
    
    // Procesar rangos iniciales y finales como strings primero
    String rangoInicialStr = json['RANGO_INICIAL'] ?? '0';
    String rangoFinalStr = json['RANGO_FINAL'] ?? '0';
    
    // Eliminar prefijo 558 para evitar overflow en int
    if (rangoInicialStr.startsWith("558")) {
      rangoInicialStr = rangoInicialStr.substring(3);
    }
    if (rangoFinalStr.startsWith("558")) {
      rangoFinalStr = rangoFinalStr.substring(3);
    }
    
    int rangoInicial = int.tryParse(rangoInicialStr) ?? 0;
    int rangoFinal = int.tryParse(rangoFinalStr) ?? 0;
    
    print("🔄 Bag.fromJson - ID: ${json['ID']} - Rango: $rangoInicial-$rangoFinal");
    
    return Bag(
      id: int.tryParse(json['ID'] ?? '0') ?? 0,
      rangoInicial: rangoInicial,
      rangoFinal: rangoFinal,
      cantidad: int.tryParse(json['CANTIDAD'] ?? '0') ?? 0,
      dias: int.tryParse(json['DIAS'] ?? '0') ?? 0,
      existencia: int.tryParse(json['EXISTENCIA'] ?? '0') ?? 0,
      rangosAdicionales: [], // Se llena externamente
    );
  }

  // Conversión a JSON, en caso de ser necesario
  Map<String, dynamic> toJson() {
    return {
      'ID': id.toString(),
      'RANGO_INICIAL': rangoInicial.toString(),
      'RANGO_FINAL': rangoFinal.toString(),
      'CANTIDAD': cantidad.toString(),
      'DIAS': dias.toString(),
      'EXISTENCIA': existencia.toString(),
      'rangosAdicionales': rangosAdicionales.map((r) => r.toJson()).toList(),
    };
  }
  
  // Obtener todos los aretes disponibles en todos los rangos
  List<int> obtenerTodosLosAretes() {
    List<int> aretes = [];
    
    // Función de depuración
    void debugRango(String tipo, int inicio, int final_) {
      print("🔍 Procesando rango $tipo - Inicial: $inicio, Final: $final_, Existencia: $existencia, Cantidad: $cantidad");
    }
    
    // Añadir aretes del rango principal si hay existencia
    if (existencia > 0) {
      int inicioEfectivo = rangoInicial;
      if (existencia < cantidad) {
        // Si quedan menos aretes que el total, asumimos que son los últimos
        inicioEfectivo = rangoFinal - existencia + 1;
      }
      
      debugRango("Principal", inicioEfectivo, rangoFinal);
      
      try {
        for (int i = 0; i < existencia; i++) {
          aretes.add(inicioEfectivo + i);
        }
      } catch (e) {
        print("❌ Error procesando rango principal: $e");
        print("Valores: rangoInicial=$rangoInicial, rangoFinal=$rangoFinal, existencia=$existencia");
      }
    }
    
    // Añadir aretes de rangos adicionales
    int rangoIndex = 0;
    for (var rango in rangosAdicionales) {
      if (rango.existencia > 0) {
        int inicioEfectivo = rango.rangoInicial;
        if (rango.existencia < rango.cantidad) {
          inicioEfectivo = rango.rangoFinal - rango.existencia + 1;
        }
        
        debugRango("Adicional #$rangoIndex", inicioEfectivo, rango.rangoFinal);
        
        try {
          for (int i = 0; i < rango.existencia; i++) {
            aretes.add(inicioEfectivo + i);
          }
        } catch (e) {
          print("❌ Error procesando rango adicional #$rangoIndex: $e");
          print("Valores: rangoInicial=${rango.rangoInicial}, rangoFinal=${rango.rangoFinal}, existencia=${rango.existencia}");
        }
      }
      rangoIndex++;
    }
    
    // Ordenar los aretes
    aretes.sort();
    print("✅ Total de aretes generados: ${aretes.length}");
    return aretes;
  }
  
  // Obtener cantidad total de aretes disponibles
  int get existenciaTotal {
    int total = existencia;
    for (var rango in rangosAdicionales) {
      total += rango.existencia;
    }
    return total;
  }
}

@HiveType(typeId: 20)
class RangoBag {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final int rangoInicial;
  
  @HiveField(2)
  final int rangoFinal;
  
  @HiveField(3)
  final int cantidad;
  
  @HiveField(4)
  final int existencia;
  
  @HiveField(5)
  final int dias;
  
  RangoBag({
    required this.id,
    required this.rangoInicial,
    required this.rangoFinal,
    required this.cantidad,
    required this.existencia,
    this.dias = 0,
  });
  
  // Constructor factory para crear desde JSON
  factory RangoBag.fromJson(Map<String, dynamic> json) {
    print("🔄 RangoBag.fromJson recibió: $json");
    
    // Procesar rangos iniciales y finales como strings primero
    String rangoInicialStr = json['RANGO_INICIAL'] ?? '0';
    String rangoFinalStr = json['RANGO_FINAL'] ?? '0';
    
    // Eliminar prefijo 558 para evitar overflow en int
    if (rangoInicialStr.startsWith("558")) {
      rangoInicialStr = rangoInicialStr.substring(3);
    }
    if (rangoFinalStr.startsWith("558")) {
      rangoFinalStr = rangoFinalStr.substring(3);
    }
    
    int rangoInicial = int.tryParse(rangoInicialStr) ?? 0;
    int rangoFinal = int.tryParse(rangoFinalStr) ?? 0;
    
    print("🔄 RangoBag.fromJson - ID: ${json['ID']} - Rango: $rangoInicial-$rangoFinal");
    
    return RangoBag(
      id: int.tryParse(json['ID'] ?? '0') ?? 0,
      rangoInicial: rangoInicial,
      rangoFinal: rangoFinal,
      cantidad: int.tryParse(json['CANTIDAD'] ?? '0') ?? 0,
      existencia: int.tryParse(json['EXISTENCIA'] ?? '0') ?? 0,
      dias: int.tryParse(json['DIAS'] ?? '0') ?? 0,
    );
  }
  
  // Conversión a JSON
  Map<String, dynamic> toJson() {
    return {
      'ID': id.toString(),
      'RANGO_INICIAL': rangoInicial.toString(),
      'RANGO_FINAL': rangoFinal.toString(),
      'CANTIDAD': cantidad.toString(),
      'EXISTENCIA': existencia.toString(),
      'DIAS': dias.toString(),
    };
  }
}
