import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({Key? key}) : super(key: key);

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool hasPermission = false;
  bool hasError = false;
  String? errorMessage;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        if (!mounted) return;
        setState(() {
          hasPermission = true;
        });
      } else {
        if (!mounted) return;
        setState(() {
          hasError = true;
          errorMessage = 'Se requieren permisos de cámara para escanear';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        errorMessage = 'Error al solicitar permisos: $e';
      });
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (isScanning || scanData.code == null) return;
      
      isScanning = true;
      print('📦 Código detectado: ${scanData.code}');
      
      // Detener la cámara y regresar el resultado
      controller.pauseCamera();
      Navigator.of(context).pop(scanData.code);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await controller?.pauseCamera();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Escanear código'),
          actions: [
            if (controller != null) ...[
              IconButton(
                icon: const Icon(Icons.flash_on),
                onPressed: () async {
                  await controller?.toggleFlash();
                  setState(() {});
                },
              ),
              IconButton(
                icon: const Icon(Icons.flip_camera_ios),
                onPressed: () async {
                  await controller?.flipCamera();
                  setState(() {});
                },
              ),
            ],
          ],
        ),
        body: !hasPermission
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Permisos de cámara requeridos',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _checkPermission,
                      child: const Text('Solicitar permisos'),
                    ),
                  ],
                ),
              )
            : hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Error al inicializar la cámara',
                          style: TextStyle(color: Colors.red, fontSize: 18),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              hasError = false;
                              errorMessage = null;
                            });
                            _checkPermission();
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                        overlay: QrScannerOverlayShape(
                          borderColor: Theme.of(context).primaryColor,
                          borderRadius: 10,
                          borderLength: 30,
                          borderWidth: 10,
                          cutOutSize: 300,
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          color: Colors.black54,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Apunte al código de barras',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Mantenga el dispositivo estable',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
