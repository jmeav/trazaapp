import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EditBovinoDialog extends StatefulWidget {
  final String arete;
  final String sexo;
  final int edad;
  final Function(String sexo, int edad) onSave;

  const EditBovinoDialog({
    Key? key,
    required this.arete,
    required this.sexo,
    required this.edad,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditBovinoDialog> createState() => _EditBovinoDialogState();
}

class _EditBovinoDialogState extends State<EditBovinoDialog> {
  late TextEditingController _edadController;
  late String _sexo;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _edadController = TextEditingController(text: widget.edad.toString());
    _sexo = widget.sexo;
  }

  @override
  void dispose() {
    _edadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Bovino ${widget.arete}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo de Edad
            TextFormField(
              controller: _edadController,
              decoration: const InputDecoration(
                labelText: 'Edad (meses)',
                hintText: 'Ingrese la edad en meses',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La edad es obligatoria';
                }
                int? edad = int.tryParse(value);
                if (edad == null) {
                  return 'Ingrese un número válido';
                }
                if (edad <= 0) {
                  return 'La edad debe ser mayor a 0';
                }
                if (edad > 240) {
                  return 'La edad no puede ser mayor a 240 meses';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Selección de Sexo
            DropdownButtonFormField<String>(
              value: _sexo.isNotEmpty ? _sexo : null,
              decoration: const InputDecoration(
                labelText: 'Sexo',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'H', child: Text('H')),
                DropdownMenuItem(value: 'M', child: Text('M')),
              ],
              onChanged: (value) {
                setState(() {
                  _sexo = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El sexo es obligatorio';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              int edad = int.parse(_edadController.text);
              widget.onSave(_sexo, edad);
              Get.back();
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
} 