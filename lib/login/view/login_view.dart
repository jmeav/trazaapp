import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  bool loading = false;

 @override
  void initState() {
    super.initState();
    imeiController.text = '8927368326889';
    codigoController.text = '2024';
  }
  
  Future<void> login() async {
    controller.saveDeviceInfo(imeiController.text, codigoController.text);
    controller.login(imeiController.text, codigoController.text);
  }

  @override
  Widget build(BuildContext context) {
    double fontSizeTitle = 25;
    double paddingLateral = 20;
    double spacing = 20;
    double containerWidth = MediaQuery.of(context).size.width * 0.9;

    return Obx(() {
      return Scaffold(
        body: Center(
          child: SizedBox(
            width: containerWidth,
            child: SingleChildScrollView(
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: paddingLateral),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              '¡Bienvenido!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: fontSizeTitle),
                            ),
                          ),
                          if (controller.isFirstTime.value) ...[
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: TextFormField(
                                controller: imeiController,
                                decoration: InputDecoration(
                                  suffixIcon: const Icon(Icons.phone_android),
                                  filled: true,
                                  hintText: "Ingrese su IMEI",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El IMEI es obligatorio';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: TextFormField(
                                controller: codigoController,
                                decoration: InputDecoration(
                                  suffixIcon: const Icon(Icons.code),
                                  filled: true,
                                  hintText: "Código Oficial",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: spacing),
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: loading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: () async {
                                      await login();
                                    },
                                    child: const Text("Iniciar sesión"),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
