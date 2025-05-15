import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:trazaapp/controller/arete_input_controller.dart';
import 'package:trazaapp/controller/baja_sin_origen_controller.dart';
import 'package:trazaapp/presentation/widgets/custom_saving.dart';

class BajaFormAnyView extends StatefulWidget {
  const BajaFormAnyView({super.key});

  @override
  State<BajaFormAnyView> createState() => _BajaFormAnyViewState();
}

class _BajaFormAnyViewState extends State<BajaFormAnyView> {
  final AreteInputController areteInput = Get.put(AreteInputController(), tag: 'areteInputAny');
  final BajaSinOrigenController bajaController = Get.put(BajaSinOrigenController());
  String? evidenciaFileName;
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickEvidencia() async {
    final picker = ImagePicker();
    final XFile? image = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () async {
                final XFile? picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                Navigator.pop(context, picked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () async {
                final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                Navigator.pop(context, picked);
              },
            ),
          ],
        ),
      ),
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        evidenciaFileName = image.name;
        bajaController.evidenciaBase64.value = base64Encode(bytes);
      });
    }
  }

  Future<void> _guardarBaja() async {
    if (_formKey.currentState?.validate() != true) return;
    
    // Verificar GPS
    if (!bajaController.isGpsEnabled.value) {
      Get.snackbar(
        'Error', 
        'El GPS debe estar activado para registrar la baja',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Verificar arete
    if (areteInput.areteController.text.isEmpty) {
      Get.snackbar(
        'Error', 
        'El arete es obligatorio',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Verificar evidencia
    if (bajaController.evidenciaBase64.value.isEmpty) {
      Get.snackbar(
        'Error', 
        'La evidencia (foto) es obligatoria',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Una vez validado, mostrar el diálogo de carga
    Get.dialog(
      const SavingLoadingDialog(),
      barrierDismissible: false,
    );

    try {
      bajaController.arete.value = areteInput.areteController.text;
      
      final success = await bajaController.guardarBaja();
      
      // Cerrar el diálogo de carga
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      if (success) {
        Get.snackbar(
          'Éxito', 
          'Baja registrada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Limpiar el formulario
        areteInput.areteController.clear();
        bajaController.evidenciaBase64.value = '';
        setState(() {
          evidenciaFileName = null;
        });
        
        // Navegar a la pantalla principal
        Get.offAllNamed('/home');
      }
    } catch (e) {
      // Cerrar el diálogo de carga si está abierto
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      Get.snackbar(
        'Error', 
        'Error al guardar la baja: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Baja General (Sin Origen)')),
      body: Obx(() {
       return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: areteInput.areteController,
                        decoration: const InputDecoration(
                          labelText: 'Arete',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => (value == null || value.isEmpty) ? 'El arete es obligatorio' : null,
                        onChanged: (value) {
                          areteInput.isScanned.value = false;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: () => areteInput.escanearArete(),
                    ),
                    const SizedBox(width: 8),
                    Obx(() => Chip(
                      label: Text(areteInput.isScanned.value ? 'Escaneado' : 'Digitado'),
                      backgroundColor: areteInput.isScanned.value
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.secondaryContainer,
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickEvidencia,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Agregar Foto'),
                    ),
                    const SizedBox(width: 12),
                    if (evidenciaFileName != null)
                      Flexible(child: Text(evidenciaFileName!, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                if (bajaController.evidenciaBase64.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: Image.memory(
                        base64Decode(bajaController.evidenciaBase64.value),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: bajaController.isLoading.value ? null : _guardarBaja,
                    child: bajaController.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Guardar Baja'),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
} 