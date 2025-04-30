import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class PdfGenerator {
  static Future<String> generateFichaPdf(Map<String, dynamic> altaData,
      {String? codHabilitado}) async {
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

    // Extraer datos (con valores por defecto si son null)
    final nombreProductor = altaData['NombreProductor']?.toString() ?? 'N/A';
    final cupa = altaData['cupa']?.toString() ?? 'N/A'; // CUPA como Cédula/RUC
    final nombreEstablecimiento = altaData['Finca']?.toString() ?? 'N/A';
    final cue = altaData['cue']?.toString() ?? 'N/A';
    final idAlta = altaData['idAlta']?.toString() ?? 'N/A';
    final rangoInicial = _formatArete(altaData['rangoInicial']?.toString());
    final rangoFinal = _formatArete(altaData['rangoFinal']?.toString());

    // Código de habilitado (desde los parámetros o valor por defecto)
    final codigo = codHabilitado ?? 'N/A';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
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
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            // Logo izquierdo e información
                            pw.Row(children: [
                              pw.Container(
                                width: 50,
                                height: 70,
                                child: pw.Image(logoIzquierdo),
                              ),
                              pw.SizedBox(width: 5),
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
                                        'DEPARTAMENTO DE TRAZABILIDAD DE RUMIANTES',
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
                            pw.Container(
                              width: 1,
                              height: 60,
                              color: PdfColors.black,
                              margin:
                                  const pw.EdgeInsets.symmetric(horizontal: 2),
                            ),
                            // Columna de identificación del formato y fecha
                            pw.Container(
                              width: 100,
                              decoration: pw.BoxDecoration(
                                  // border: pw.Border.all(width: 1)
                                  ),
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Center(
                                      child: pw.Text('TRAZAB-NIC-02',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 11)),
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
                                    // pw.SizedBox(height: 5),
                                    // pw.Row(children: [

                                    //   ),
                                    // ]),
                                    pw.SizedBox(height: 5),
                                    pw.Row(children: [
                                      pw.Text('CODIGO: ',
                                          style: pw.TextStyle(fontSize: 6)),
                                      pw.Text(codigo,
                                          style: pw.TextStyle(fontSize: 6)),
                                    ]),
                                  ]),
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
                                fontWeight: pw.FontWeight.bold, fontSize: 12)),
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
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('NOMBRE O RAZÓN SOCIAL DEL PRODUCTOR',
                                      style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
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
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('CEDULA / RUC:',
                                      style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
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
                        border: pw.Border(bottom: pw.BorderSide(width: 1))
                      ),
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Etiqueta de coordenadas
                          pw.Container(
                            width: 160,
                            padding: const pw.EdgeInsets.symmetric(vertical: 10),
                            alignment: pw.Alignment.center,
                            decoration: pw.BoxDecoration(
                              border: pw.Border(right: pw.BorderSide(width: 1))
                            ),
                            child: pw.Text('COORDENADAS GEOGRÁFICAS', 
                              style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.center
                            ),
                          ),
                          // HORIZONTALES(X)
                          pw.SizedBox(width: 10),
                          pw.Container(
                            padding: const pw.EdgeInsets.only(top: 2, left: 2, right: 2),
                            child: pw.Column(
                              children: [
                                pw.Text('HORIZONTALES(X)', style: pw.TextStyle(fontSize: 6,fontWeight: pw.FontWeight.bold)),
                                pw.Row(
                                  children: List.generate(7, (i) => pw.Container(
                                    width: 12,
                                    height: 16,
                                    alignment: pw.Alignment.center,
                                    margin: const pw.EdgeInsets.symmetric(horizontal: 1),
                                    decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                                    child: pw.Text('${i+1}', style: pw.TextStyle(fontSize: 8)),
                                  )),
                                ),
                              ],
                            ),
                          ),
                          // VERTICALES(Y)
                          pw.SizedBox(width: 10),
                          pw.Container(
                            padding: const pw.EdgeInsets.only(top: 2, left: 8, right: 2),
                            child: pw.Column(
                              children: [
                                pw.Text('VERTICALES(Y)', style: pw.TextStyle(fontSize: 6,fontWeight: pw.FontWeight.bold)),
                                pw.Row(
                                  children: List.generate(7, (i) => pw.Container(
                                    width: 12,
                                    height: 16,
                                    alignment: pw.Alignment.center,
                                    margin: const pw.EdgeInsets.symmetric(horizontal: 1),
                                    decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                                    child: pw.Text('${i+1}', style: pw.TextStyle(fontSize: 8)),
                                  )),
                                ),
                              ],
                            ),
                          ),
                          // ALTITUD
                          pw.SizedBox(width: 10),
                          pw.Container(
                            padding: const pw.EdgeInsets.only(top: 2, left: 8, right: 2),
                            child: pw.Column(
                              children: [
                                pw.Text('ALTITUD', style: pw.TextStyle(fontSize: 6,fontWeight: pw.FontWeight.bold)),
                                pw.Row(
                                  children: List.generate(4, (i) => pw.Container(
                                    width: 12,
                                    height: 16,
                                    alignment: pw.Alignment.center,
                                    margin: const pw.EdgeInsets.symmetric(horizontal: 1),
                                    decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                                    child: pw.Text('${i+1}', style: pw.TextStyle(fontSize: 8)),
                                  )),
                                ),
                              ],
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
                                pw.Text('NOMBRE DEL ESTABLECIMIENTO',
                                    style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
                                pw.SizedBox(height: 2),
                                pw.Text(nombreEstablecimiento,
                                    style: pw.TextStyle(fontSize: 8)),
                              ],
                            ),
                          ),
                          // Departamento
                          pw.Expanded(
                            flex: 2,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('DEPARTAMENTO',
                                    style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
                                pw.SizedBox(height: 2),
                                pw.Text(altaData['departamento']?.toString() ?? '', style: pw.TextStyle(fontSize: 8)),
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
                                    style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
                                pw.SizedBox(height: 2),
                                pw.Text(altaData['municipio']?.toString() ?? '', style: pw.TextStyle(fontSize: 8)),
                              ],
                            ),
                          ),
                          // CUE (alineado a la derecha, con cajas)
                          pw.Container(
                            width: 155,
                            child: pw.Row(
                              children: [
                                pw.Text('CUE',
                                    style: pw.TextStyle(
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold)),
                                pw.SizedBox(width: 4),
                                ...cue.split('').map((c) => pw.Container(
                                  width: 10,
                                  height: 20,
                                  alignment: pw.Alignment.center,
                                  decoration: pw.BoxDecoration(
                                      border: pw.Border.all(width: 1)),
                                  child: pw.Text(c,
                                      style: pw.TextStyle(fontSize: 6)),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // pw.SizedBox(height: 10),

              // Tabla de animales
              _buildTablaAnimales(rangoInicial, rangoFinal, altaData['detalleBovinos'] as List?),

              // pw.Spacer(),

              // Pie de página con firmas
              _buildFooter(),
            ],
          );
        },
      ),
    );

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

  static pw.Widget _buildTablaAnimales(String rangoInicial, String rangoFinal, [List? bovinos]) {
    final headers = [
      'No.',
      'CODIGO UNICO DE IDENTIFICACIÓN ANIMAL (CUIA)',
      'EDAD EN MESES',
      'SEXO',
      'RAZA'
    ];

    final List<List<String>> data = [];

    if (bovinos != null && bovinos.isNotEmpty) {
      for (int i = 0; i < 23; i++) {
        if (i < bovinos.length) {
          final bovino = bovinos[i];
          data.add([
            (i + 1).toString(),
            bovino['arete']?.toString() ?? '',
            bovino['edad']?.toString() ?? '',
            'H', // Por ahora, hasta que el backend mande el sexo real
            bovino['raza']?.toString() ?? '',
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
          children: headers.map((header) =>
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Center(
                child: pw.Text(
                  header,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            )
          ).toList(),
        ),
        ...data.map(
          (row) => pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Center(child: pw.Text(row[0], style: pw.TextStyle(fontSize: 8))),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Center(child: pw.Text(row[1], style: pw.TextStyle(fontSize: 8))),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Center(child: pw.Text(row[2], style: pw.TextStyle(fontSize: 8))),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Center(child: pw.Text(row[3], style: pw.TextStyle(fontSize: 8))),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Center(child: pw.Text(row[4], style: pw.TextStyle(fontSize: 8))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
        pw.Column(children: [
          pw.Container(
            width: 200,
            decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide())),
            height: 20,
          ),
          pw.SizedBox(height: 5),
          pw.Text('Propietario/Representante',
              style: pw.TextStyle(fontSize: 10)),
        ]),
        pw.Column(children: [
          pw.Container(
            width: 200,
            decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide())),
            height: 20,
          ),
          pw.SizedBox(height: 5),
          pw.Text('Firma y Cédula', style: pw.TextStyle(fontSize: 10)),
        ]),
      ]),
      pw.SizedBox(height: 30),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
        pw.Column(children: [
          pw.Container(
            width: 200,
            decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide())),
            height: 20,
          ),
          pw.SizedBox(height: 5),
          pw.Text('Técnico Oficial/Habilitado',
              style: pw.TextStyle(fontSize: 10)),
        ]),
        pw.Column(children: [
          pw.Container(
            width: 200,
            decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide())),
            height: 20,
          ),
          pw.SizedBox(height: 5),
          pw.Text('Firma y Cédula', style: pw.TextStyle(fontSize: 10)),
        ]),
      ]),
      pw.SizedBox(height: 20),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 5),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(),
          color: PdfColors.grey200,
        ),
        child: pw.Center(
          child: pw.Text(
            'Nota: En el caso de los códigos se debe colocar 9 dígitos, contando después del 558 que corresponde al código del país.',
            style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
          ),
        ),
      ),
    ]);
  }
}
