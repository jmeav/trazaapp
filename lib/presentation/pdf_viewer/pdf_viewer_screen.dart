import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfPath;

  const PdfViewerScreen({Key? key, required this.pdfPath}) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isLoading = true;
  PDFViewController? _pdfViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha Generada'),
        actions: [
          // WhatsApp
          IconButton(
            icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
            tooltip: 'Compartir por WhatsApp',
            onPressed: () => _shareViaWhatsApp(),
          ),
          // Compartir
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartir',
            onPressed: () => _sharePdf(),
          ),
          // Guardar
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Guardar PDF',
            onPressed: () => _savePdf(),
          ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdfPath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageFling: false,
            defaultPage: 0,
            fitPolicy: FitPolicy.BOTH,
            pageSnap: true,
            onRender: (_pages) {
              setState(() {
                _totalPages = _pages!;
                _isLoading = false;
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              setState(() {
                _pdfViewController = pdfViewController;
              });
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page!;
              });
            },
            onError: (error) {
              print(error.toString());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error al cargar el PDF: $error")),
              );
            },
            onPageError: (page, error) {
              print('$page: ${error.toString()}');
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error en página $page: $error")),
              );
            },
          ),
          
          // Indicador de carga
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Cargando PDF..."),
                ],
              ),
            ),
          
          // Controles de navegación
          if (!_isLoading && _totalPages > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _currentPage > 0 
                        ? () => _pdfViewController?.setPage(_currentPage - 1) 
                        : null,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.navigate_before),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentPage + 1} / $_totalPages',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _currentPage < _totalPages - 1 
                        ? () => _pdfViewController?.setPage(_currentPage + 1) 
                        : null,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.navigate_next),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Compartir PDF por cualquier app
  Future<void> _sharePdf() async {
    try {
      await Share.shareFiles(
        [widget.pdfPath],
        text: 'Ficha de registro bovino',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo compartir el PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Compartir por WhatsApp
  Future<void> _shareViaWhatsApp() async {
    try {
      final String whatsappUrl = "https://wa.me/?text=Ficha%20de%20registro%20bovino";
      
      final Uri uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await Share.shareFiles(
          [widget.pdfPath],
          subject: 'Ficha de registro bovino',
        );
      } else {
        Get.snackbar(
          'Error',
          'WhatsApp no está instalado en este dispositivo',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo compartir por WhatsApp: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Guardar PDF en el dispositivo
  Future<void> _savePdf() async {
    try {
      final status = await Permission.storage.request();
      
      if (status.isGranted) {
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('No se pudo acceder al almacenamiento');
        }
        
        // Crear directorio para guardar los PDFs si no existe
        final downloadsDir = Directory('${directory.path}/TrazaApp_PDFs');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        
        // Copiar el archivo al directorio de descargas
        final String fileName = widget.pdfPath.split('/').last;
        final String savePath = '${downloadsDir.path}/$fileName';
        final File file = File(widget.pdfPath);
        await file.copy(savePath);
        
        Get.snackbar(
          'Guardado',
          'PDF guardado en ${downloadsDir.path}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'Permiso denegado',
          'Se necesita permiso de almacenamiento para guardar el PDF',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar el PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
} 