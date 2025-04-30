import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({Key? key}) : super(key: key);

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final MobileScannerController controller = MobileScannerController();
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
      controller.stop();
    } else if (Platform.isIOS) {
      controller.start();
    }
  }

  @override
  void dispose() {
    controller.dispose();
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

  void _onDetect(BarcodeCapture capture) {
    if (isScanning) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (code == null) return;
    isScanning = true;
    print('📦 Código detectado: $code');
    controller.stop();
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await controller.stop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Escanear código'),
          actions: [
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () async {
                await controller.toggleTorch();
                setState(() {});
              },
            ),
            IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              onPressed: () async {
                await controller.switchCamera();
                setState(() {});
              },
            ),
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
                      MobileScanner(
                        controller: controller,
                        onDetect: _onDetect,
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        top: 80,
                        bottom: 120,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 4,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
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
