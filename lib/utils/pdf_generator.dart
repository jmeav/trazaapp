import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:get/get.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/data/models/razas/raza.dart';

class PdfGenerator {
  static Future<String> generateFichaPdf(
    Map<String, dynamic> altaData, {
    String? codHabilitado,
    String? nombreHabilitado,
    String? cedulaHabilitado,
    AppConfig? appConfig,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);

    // Cargar imágenes
    final ByteData logoIzqBytes =
        await rootBundle.load('assets/images/izquierda1.png');
    final ByteData logoDerBytes =
        await rootBundle.load('assets/images/derecha1.png');
    final Uint8List logoIzqData = logoIzqBytes.buffer.asUint8List();
    final Uint8List logoDerData = logoDerBytes.buffer.asUint8List();
    final logoIzquierdo = pw.MemoryImage(logoIzqData);
    final logoIPSA = pw.MemoryImage(logoDerData);

    // Generar QR con el ID del alta
    final qrImage = await QrPainter(
      data: altaData['idAlta']?.toString() ?? '',
      version: QrVersions.auto,
    ).toImageData(200.0);

    final qrBytes = qrImage!.buffer.asUint8List();
    final qrPdfImage = pw.MemoryImage(qrBytes);

    // Extraer datos (con valores por defecto si son null)
    final nombreProductor = altaData['NombreProductor']?.toString() ?? 'N/A';
    final cupa = altaData['cupa']?.toString() ?? 'N/A'; // CUPA como Cédula/RUC
   
    final nombreEstablecimiento = altaData['Finca']?.toString() ?? 'N/A';
    final cue = altaData['cue']?.toString() ?? 'N/A';
    final idAlta = altaData['idAlta']?.toString() ?? 'N/A';
    final rangoInicial = _formatArete(altaData['rangoInicial']?.toString());
    final rangoFinal = _formatArete(altaData['rangoFinal']?.toString());

    // Código de habilitado (desde los parámetros o valor por defecto)
    final codigo = codHabilitado ?? appConfig?.codHabilitado ?? 'N/A';
    final nombreHb = nombreHabilitado ?? appConfig?.nombre ?? '';
    final cedulaHb = cedulaHabilitado ?? appConfig?.cedula ?? '';

    // Obtener la lista de bovinos (sin multiplicar)
    final List bovinos = altaData['detalleBovinos'] as List? ?? [];
    const int bovinosPorPagina = 23;
    const int bovinosUltimaPagina = 15;
    int totalPaginas = 0;
    if (bovinos.length <= bovinosPorPagina) {
      totalPaginas = 1;
    } else {
      totalPaginas =
          ((bovinos.length - bovinosUltimaPagina) / bovinosPorPagina).ceil() +
              1;
    }

    // Obtener el catálogo de razas
    final catalogosController = Get.find<CatalogosController>();
    final razas = catalogosController.razas;

    for (int pagina = 0; pagina < totalPaginas; pagina++) {
      int inicio, fin;
      if (pagina < totalPaginas - 1) {
        inicio = pagina * bovinosPorPagina;
        fin = ((pagina + 1) * bovinosPorPagina < bovinos.length)
            ? (pagina + 1) * bovinosPorPagina
            : bovinos.length;
      } else {
        inicio = bovinos.length - bovinosUltimaPagina;
        if (inicio < 0) inicio = 0;
        fin = bovinos.length;
      }
      final List bovinosPagina =
          bovinos.isNotEmpty ? bovinos.sublist(inicio, fin) : [];

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.legal,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Positioned(
                  left: 10,
                  bottom: 85,
                  child: pw.Text(
                    'NO REQUIERE SELLO NI FIRMA',
                    style: pw.TextStyle(
                      color: PdfColors.red,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Positioned(
                  right: 10,
                  bottom: 85,
                  child: pw.Container(
                    width: 50,
                    height: 50,
                    child: pw.Image(qrPdfImage),
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Encabezado completo con bordes
                    pw.Container(
                      decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                      child: pw.Column(
                        children: [
                          // Primera fila: Logos e información institucional
                          pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(bottom: pw.BorderSide(width: 1))),
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  // Logo izquierdo e información
                                  pw.Row(children: [
                                    pw.Container(
                                      width: 50,
                                      height: 70,
                                      child: pw.Image(logoIzquierdo),
                                    ),
                                    pw.SizedBox(width: 10),
                                    pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                              'INSTITUTO DE PROTECCION Y SANIDAD AGROPECUARIA',
                                              style: pw.TextStyle(
                                                  fontWeight: pw.FontWeight.bold,
                                                  fontSize: 8)),
                                          pw.Text(
                                              'DIRECCION DE TRAZABILIDAD PECUARIA',
                                              style: pw.TextStyle(fontSize: 6)),
                                          pw.Text(
                                              'DEPARTAMENTO DE TRAZABILIDAD EN PRODUCCIÓN PRIMARIA PECUARIA',
                                              style: pw.TextStyle(fontSize: 6)),
                                        ]),
                                  ]),
                                  // Logo IPSA
                                  pw.Row(children: [
                                    pw.Container(
                                      width: 50,
                                      height: 70,
                                      child: pw.Image(logoIPSA),
                                    ),
                                  ]),
                                  // Columna de identificación del formato y fecha
                                  pw.Container(
                                    width: 100,
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border(
                                        left: pw.BorderSide(width: 1),
                                      ),
                                    ),
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Container(
                                          decoration: pw.BoxDecoration(
                                            border: pw.Border(
                                              bottom: pw.BorderSide(width: 1),
                                            ),
                                          ),
                                          child: pw.Center(
                                            child: pw.Text(
                                              'TRAZAB-NIC-02',
                                              style: pw.TextStyle(
                                                fontWeight: pw.FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ),
                                        pw.SizedBox(height: 5),
                                        pw.Row(children: [
                                          pw.Text('FECHA: ',
                                              style: pw.TextStyle(fontSize: 6)),
                                          pw.Text(formattedDate,
                                              style: pw.TextStyle(fontSize: 6)),
                                        ]),
                                        pw.SizedBox(height: 5),
                                        pw.Row(children: [
                                          pw.Text('OFICIAL ',
                                              style: pw.TextStyle(fontSize: 6)),
                                          pw.Container(
                                            width: 10,
                                            height: 10,
                                            decoration: pw.BoxDecoration(
                                                border: pw.Border.all()),
                                          ),
                                          pw.SizedBox(width: 10),
                                          pw.Text('HABILITADO ',
                                              style: pw.TextStyle(fontSize: 6)),
                                          pw.Container(
                                            width: 10,
                                            height: 10,
                                            decoration: pw.BoxDecoration(
                                                border: pw.Border.all()),
                                            child: pw.Center(
                                                child: pw.Text('X',
                                                    style: pw.TextStyle(
                                                        fontSize: 7,
                                                        fontWeight:
                                                            pw.FontWeight.bold))),
                                          ),
                                        ]),
                                        pw.SizedBox(height: 5),
                                        pw.Row(children: [
                                          pw.Text('CODIGO: ',
                                              style: pw.TextStyle(fontSize: 6)),
                                          pw.Text(codigo,
                                              style: pw.TextStyle(fontSize: 6)),
                                        ]),
                                      ],
                                    ),
                                  ),
                                ]),
                          ),

                          // Segunda fila: Título del formato
                          pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(bottom: pw.BorderSide(width: 1))),
                            padding: const pw.EdgeInsets.symmetric(vertical: 10),
                            child: pw.Center(
                              child: pw.Text(
                                  'FORMATO DE BOVINOS IDENTIFICADOS POR ESTABLECIMIENTOS',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ),

                          // Tercera fila: Datos del productor
                          pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(bottom: pw.BorderSide(width: 1))),
                            child: pw.Row(
                              children: [
                                pw.Expanded(
                                  flex: 6,
                                  child: pw.Container(
                                    padding: const pw.EdgeInsets.all(5),
                                    decoration: pw.BoxDecoration(
                                        border: pw.Border(
                                            right: pw.BorderSide(width: 1))),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                            'NOMBRE O RAZÓN SOCIAL DEL PRODUCTOR',
                                            style: pw.TextStyle(
                                                fontSize: 8,
                                                fontWeight: pw.FontWeight.bold)),
                                        pw.SizedBox(height: 5),
                                        pw.Text(nombreProductor,
                                            style: pw.TextStyle(fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 4,
                                  child: pw.Container(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text('CEDULA / RUC:',
                                            style: pw.TextStyle(
                                                fontSize: 8,
                                                fontWeight: pw.FontWeight.bold)),
                                        pw.SizedBox(height: 5),
                                        pw.Text(cupa,
                                            style: pw.TextStyle(fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Cuarta fila: Coordenadas geográficas
                          pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(bottom: pw.BorderSide(width: 1))),
                            padding: const pw.EdgeInsets.symmetric(vertical: 2),
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Container(
                                  width: 160,
                                  padding:
                                      const pw.EdgeInsets.symmetric(vertical: 5),
                                  alignment: pw.Alignment.center,
                                  decoration: pw.BoxDecoration(
                                      border: pw.Border(
                                          right: pw.BorderSide(width: 1))),
                                  child: pw.Text('COORDENADAS GEOGRÁFICAS',
                                      style: pw.TextStyle(
                                          fontSize: 8,
                                          fontWeight: pw.FontWeight.bold),
                                      textAlign: pw.TextAlign.center),
                                ),
                                pw.Expanded(
                                  child: pw.Center(
                                    child: pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.center,
                                      children: [
                                        pw.Text(
                                          'LATITUD: ${(altaData['latitud']?.toString() ?? '').toUpperCase()}',
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              fontWeight: pw.FontWeight.bold),
                                        ),
                                        pw.SizedBox(width: 20),
                                        pw.Text(
                                          'LONGITUD: ${(altaData['longitud']?.toString() ?? '').toUpperCase()}',
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              fontWeight: pw.FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Quinta fila: Datos del establecimiento
                          pw.Container(
                            child: pw.Row(
                              children: [
                                pw.SizedBox(width: 2),
                                // Nombre del establecimiento
                                pw.Expanded(
                                  flex: 3,
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('NOMBRE ESTABLECIMIENTO',
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              fontWeight: pw.FontWeight.bold)),
                                      pw.SizedBox(height: 2),
                                      pw.Text(nombreEstablecimiento,
                                          style: pw.TextStyle(fontSize: 8)),
                                    ],
                                  ),
                                ),
                                 pw.SizedBox(width: 1),
                                // Departamento
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('DEPARTAMENTO',
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              fontWeight: pw.FontWeight.bold)),
                                      pw.SizedBox(height: 2),
                                      pw.Text(
                                          altaData['departamento']?.toString().toUpperCase() ??
                                              '',
                                          style: pw.TextStyle(fontSize: 8)),
                                    ],
                                  ),
                                ),
                                // Municipio
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('MUNICIPIO',
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              fontWeight: pw.FontWeight.bold)),
                                      pw.SizedBox(height: 2),
                                      pw.Text(
                                          altaData['municipio']?.toString().toUpperCase() ?? '',
                                          style: pw.TextStyle(fontSize: 8)),
                                    ],
                                  ),
                                ),
                                // CUE (alineado a la derecha, con cajas)
                                pw.Container(
                                  width: 155,
                                  child: pw.Row(
                                    children: [
                                      pw.Text('CUE:',
                                          style: pw.TextStyle(
                                              fontSize: 10,
                                              fontWeight: pw.FontWeight.bold)),
                                              pw.SizedBox(width: 10),
                                              pw.Text(cue,
                                            style: pw.TextStyle(fontSize: 11)),
                                     
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tabla de animales para esta página
                    _buildTablaAnimales(rangoInicial, rangoFinal, bovinosPagina),

                    // Pie de página en todas las páginas, con borde
                    pw.Container(
                      // margin: const pw.EdgeInsets.only(top: 10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1, color: PdfColors.black),
                      ),
                      child: _buildFooter(
                        nombreProductor: nombreProductor,
                        cupa: cupa,
                        nombreHabilitado: nombreHb,
                        cedulaHabilitado: cedulaHb,
                        codHabilitado: appConfig?.codHabilitado ?? '',
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    final outputDir = await getTemporaryDirectory();
    final file = File("${outputDir.path}/ficha_alta_$idAlta.pdf");
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static String _formatArete(String? arete) {
    if (arete == null) return 'N/A';
    final s = arete.padLeft(10, '0');
    return '558$s';
  }

  static pw.Widget _buildTablaAnimales(String rangoInicial, String rangoFinal,
      [List? bovinos]) {
    final headers = [
      'No.',
      'CODIGO UNICO DE IDENTIFICACIÓN ANIMAL (CUIA)',
      'EDAD EN MESES',
      'SEXO',
      'RAZA'
    ];

    final List<List<String>> data = [];
    final catalogosController = Get.find<CatalogosController>();
    final razas = catalogosController.razas;

    if (bovinos != null && bovinos.isNotEmpty) {
      for (int i = 0; i < 23; i++) {
        if (i < bovinos.length) {
          final bovino = bovinos[i];
          final razaId = bovino['raza']?.toString() ?? '';
          final raza = razas.firstWhere(
            (r) => r.id == razaId,
            orElse: () => Raza(id: '', nombre: ''),
          );
          data.add([
            (i + 1).toString(),
            bovino['arete']?.toString() ?? '',
            bovino['edad']?.toString() ?? '',
            bovino['sexo']?.toString() ?? '',
            raza.nombre,
          ]);
        } else {
          data.add([(i + 1).toString(), '', '', '', '']);
        }
      }
    } else {
      // Lógica anterior si no hay bovinos
      bool mostrarTodosEnRango = false;
      int inicioRango = 0;
      int finRango = 0;
      try {
        String inicioStr = rangoInicial.substring(3);
        String finStr = rangoFinal.substring(3);
        inicioRango = int.parse(inicioStr);
        finRango = int.parse(finStr);
        if ((finRango - inicioRango + 1) <= 23) {
          mostrarTodosEnRango = true;
        }
      } catch (e) {
        mostrarTodosEnRango = false;
      }
      if (mostrarTodosEnRango) {
        for (int i = 0; i <= (finRango - inicioRango); i++) {
          int actual = inicioRango + i;
          String codigo = '558${actual.toString().padLeft(10, '0')}';
          data.add([(i + 1).toString(), codigo, '', '', '']);
        }
        if (data.length < 23) {
          for (int i = data.length; i < 23; i++) {
            data.add([(i + 1).toString(), '', '', '', '']);
          }
        }
      } else {
        data.add(['1', rangoInicial, '', '', '']);
        for (int i = 2; i < 23; i++) {
          data.add([i.toString(), '', '', '', '']);
        }
        data.add(['23', rangoFinal, '', '', '']);
      }
    }

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FixedColumnWidth(40),
        4: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: headers
              .map((header) => pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Text(
                        header,
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 8),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ))
              .toList(),
        ),
        ...data.map(
          (row) => pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Center(
                    child: pw.Text(row[0], style: pw.TextStyle(fontSize: 9))),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Center(
                    child: pw.Text(row[1], style: pw.TextStyle(fontSize: 9))),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Center(
                    child: pw.Text(row[2], style: pw.TextStyle(fontSize: 9))),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Center(
                    child: pw.Text(row[3], style: pw.TextStyle(fontSize: 9))),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Center(
                    child: pw.Text(row[4], style: pw.TextStyle(fontSize: 9))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter({
    required String nombreProductor,
    required String cupa,
    required String nombreHabilitado,
    required String cedulaHabilitado,
    required String codHabilitado,
  }) {
    return pw.Column(children: [
      pw.SizedBox(height: 10),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
        pw.Column(children: [
          pw.SizedBox(height: 10),
          pw.Text(nombreHabilitado, style: pw.TextStyle(fontSize: 10)),
          pw.Container(
            width: 200,
            decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide())),
          ),
          pw.SizedBox(height: 5),
          pw.Text('Técnico Oficial/Habilitado',
              style: pw.TextStyle(fontSize: 10)),
        ]),
        pw.Column(children: [
          pw.SizedBox(height: 10),
          pw.Text(cedulaHabilitado, style: pw.TextStyle(fontSize: 10)),
          pw.Container(
            width: 200,
            decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide())),
          ),
          pw.SizedBox(height: 5),
          pw.Text('Cédula', style: pw.TextStyle(fontSize: 10)),
        ]),
      ]),
      pw.SizedBox(height: 50),
      
    ]);
  }
}
