import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/login/controller/login_controller.dart';
import 'package:trazaapp/data/services/version_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController controller = Get.put(LoginController());
  final VersionService versionService = Get.put(VersionService());
  final TextEditingController imeiController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RxString imeiError = ''.obs;
  RxString codigoError = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    if (versionService.shouldCheckForUpdate()) {
      await versionService.checkVersion();

      if (versionService.hasUpdateAvailable()) {
        final currentVersion = versionService.getCurrentVersion();
        final latestVersion = versionService.getLatestVersion();

        Get.dialog(
          AlertDialog(
            title: const Text('Actualización Disponible'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hay una nueva versión disponible: $latestVersion'),
                const SizedBox(height: 8),
                Text('Tu versión actual: $currentVersion'),
                const SizedBox(height: 16),
                const Text(
                    'Por favor, actualiza la aplicación para continuar.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  // Agregar redirección a la tienda si se desea
                },
                child: const Text('Actualizar'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }
    }
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
      imeiController.text = config.imei;
    }
  }

  Future<void> login() async {
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
        isFirstTime: false,
        themeMode: config?.themeMode ?? "light",
        token: '',
        fechaVencimiento: config?.fechaVencimiento ?? "",
        fechaEmision: config?.fechaEmision ?? "",
        foto: config?.foto ?? "",
        qr: config?.qr ?? "",
        organizacion: config?.organizacion ?? "",
      );

      await box.put('config', newConfig);
    }

    await controller.login(imeiController.text, codigoController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Image.asset('assets/images/header.png'),
                    const SizedBox(height: 20),
                    const Text(
                      '¡Bienvenido!',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Obx(() => TextFormField(
                          controller: imeiController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            hintText: "Ingrese su IMEI",
                            errorText: imeiError.value.isEmpty
                                ? null
                                : imeiError.value,
                            suffixIcon: const Icon(Icons.phone_android,
                                color: Colors.grey),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        )),
                    const SizedBox(height: 10),
                    Obx(() => TextFormField(
                          controller: codigoController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            hintText: "Código Oficial",
                            errorText: codigoError.value.isEmpty
                                ? null
                                : codigoError.value,
                            suffixIcon:
                                const Icon(Icons.code, color: Colors.grey),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        )),
                    const SizedBox(height: 20),
                    Obx(
                      () => controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.teal[700],
                                shadowColor: Colors.black.withOpacity(0.15),
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  side: BorderSide(
                                      color: Colors.teal.shade300, width: 1.5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.login, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Iniciar sesión",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/ipsawhite.png',
                            width: 150, fit: BoxFit.cover),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
