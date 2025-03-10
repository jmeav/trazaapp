import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/login/controller/login_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController controller = Get.put(LoginController());
  final TextEditingController imeiController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RxString imeiError = ''.obs;
  RxString codigoError = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

Future<void> _loadConfig() async {
  Box<AppConfig> box;

  if (!Hive.isBoxOpen('appConfig')) {
    box = await Hive.openBox<AppConfig>('appConfig');
  } else {
    box = Hive.box<AppConfig>('appConfig');
  }

  AppConfig? config = box.get('config');
  if (config != null) {
    controller.isFirstTime.value = config.isFirstTime;
    imeiController.text = config.imei; // ✅ Aseguramos que el IMEI guardado se cargue correctamente
  }
}

Future<void> login() async {
  // **Validación de campos**
  if (imeiController.text.trim().isEmpty) {
    imeiError.value = "El IMEI no puede estar vacío";
  } else {
    imeiError.value = "";
  }

  if (codigoController.text.trim().isEmpty) {
    codigoError.value = "El código oficial no puede estar vacío";
  } else {
    codigoError.value = "";
  }

  if (imeiError.value.isNotEmpty || codigoError.value.isNotEmpty) {
    Get.snackbar(
      "Campos incompletos",
      "Por favor, completa todos los campos antes de iniciar sesión.",
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  // 🔹 **Guardar el IMEI solo si es la primera vez**
  Box<AppConfig> box = Hive.box<AppConfig>('appConfig');
  AppConfig? config = box.get('config');

  if (config == null || config.isFirstTime) {
    AppConfig newConfig = AppConfig(
      imei: imeiController.text.trim(),
      codHabilitado: codigoController.text.trim(),
      nombre: config?.nombre ?? "",
      cedula: config?.cedula ?? "",
      email: config?.email ?? "",
      movil: config?.movil ?? "",
      idOrganizacion: config?.idOrganizacion ?? "",
      categoria: config?.categoria ?? "",
      habilitadoOperadora: config?.habilitadoOperadora ?? "",
      isFirstTime: false, // Ya no es la primera vez
      themeMode: config?.themeMode ?? "light", token: '',
    );

    await box.put('config', newConfig);
  }

  await controller.login(imeiController.text, codigoController.text);
}


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text('¡Bienvenido!', style: TextStyle(fontSize: 25)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Obx(() => TextFormField(
                          controller: imeiController,
                        //  enabled: controller.isFirstTime.value, // 🔹 Solo editable si es la primera vez
                          decoration: InputDecoration(
                            suffixIcon: const Icon(Icons.phone_android),
                            filled: true,
                            hintText: "Ingrese su IMEI",
                            errorText: imeiError.value.isEmpty ? null : imeiError.value,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Obx(() => TextFormField(
                          controller: codigoController,
                          decoration: InputDecoration(
                            suffixIcon: const Icon(Icons.code),
                            filled: true,
                            hintText: "Código Oficial",
                            errorText: codigoError.value.isEmpty ? null : codigoError.value,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: login,
                            child: const Text("Iniciar sesión"),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
