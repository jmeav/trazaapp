import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_adapter.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/models/bag/bag_operadora.dart';
import 'package:trazaapp/data/models/bag/bag_operadora_adapter.dart';
import 'package:trazaapp/data/models/bovinos/bovino.dart';
import 'package:trazaapp/data/models/bovinos/bovino_adapter.dart';
import 'package:trazaapp/data/models/departamentos/departamento.dart';
import 'package:trazaapp/data/models/departamentos/departamento_adapter.dart';
import 'package:trazaapp/data/models/entregas/entregas.dart';
import 'package:trazaapp/data/models/entregas/entregas_adapter.dart';
import 'package:trazaapp/data/models/establecimiento/establecimiento.dart';
import 'package:trazaapp/data/models/establecimiento/establecimiento_adapter.dart';
import 'package:trazaapp/data/models/home_stat.dart';
import 'package:trazaapp/data/models/municipios/minicipio_adapter.dart';
import 'package:trazaapp/data/models/municipios/municipio.dart';
import 'package:trazaapp/data/models/productores/productor.dart';
import 'package:trazaapp/data/models/productores/productor_adapter.dart';
import 'package:trazaapp/data/models/razas/raza.dart';
import 'package:trazaapp/data/models/razas/raza_adapter.dart';
import 'package:trazaapp/data/models/altaentrega/altaentrega.dart';
import 'package:trazaapp/data/models/altaentrega/altaentrega_adapter.dart';
import 'package:trazaapp/data/models/altaentrega/resbov_adapter.dart';
import 'package:trazaapp/data/models/repo/bovinorepo.dart';
import 'package:trazaapp/data/models/repo/bovinorepo_adapter.dart';
import 'package:trazaapp/data/models/repo/repoentrega.dart';
import 'package:trazaapp/data/models/repo/repoentrega_adapter.dart';
import 'package:trazaapp/login/controller/login_controller.dart';
import 'package:trazaapp/presentation/catalogscreen/catalogscreen.dart';
import 'package:trazaapp/presentation/reposcreen/formrepo_view.dart';
import 'package:trazaapp/presentation/reposcreen/repo_view.dart';
import 'package:trazaapp/presentation/sendscreen/send_view.dart';
import 'package:trazaapp/presentation/managebagscreen/managebag_view.dart';
import 'package:trazaapp/presentation/pendingscreen/pending_view.dart';
import 'package:trazaapp/presentation/formbovinoscreen/formbovinos_view.dart';
import 'package:trazaapp/presentation/homescreen/home.dart';
import 'package:trazaapp/presentation/splashscreen/splash_screen.dart';
import 'package:trazaapp/login/view/login_view.dart';
import 'package:trazaapp/presentation/verifycuescreen/verifycue_view.dart';
import 'package:trazaapp/theme/theme_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:trazaapp/utils/configscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Registro de adaptadores
  Hive.registerAdapter(EntregasAdapter());
  Hive.registerAdapter(BovinoAdapter());
  Hive.registerAdapter(EstablecimientoAdapter());
  Hive.registerAdapter(ProductorAdapter());
  Hive.registerAdapter(BagAdapter());
  Hive.registerAdapter(DepartamentoAdapter());
  Hive.registerAdapter(MunicipioAdapter());
  Hive.registerAdapter(AppConfigAdapter());
  Hive.registerAdapter(AltaEntregaAdapter());
  Hive.registerAdapter(BovinoResumenAdapter());
  Hive.registerAdapter(RazaAdapter());
  Hive.registerAdapter(BovinoRepoAdapter());
  Hive.registerAdapter(RepoEntregaAdapter());

  await Future.wait([
    Hive.openBox<HomeStat>('homeStat'),
    Hive.openBox<Entregas>('entregas'),
    Hive.openBox<Bovino>('bovinos'),
    Hive.openBox<Establecimiento>('establecimientos'),
    Hive.openBox<Productor>('productores'),
    Hive.openBox<Bag>('bag'),
    Hive.openBox<Departamento>('departamentos'),
    Hive.openBox<Municipio>('municipios'),
    Hive.openBox<AppConfig>('appConfig'),
    Hive.openBox<Raza>('razas'),
    Hive.openBox<BovinoResumen>('resumenBovino'),
    Hive.openBox<AltaEntrega>('altaentregas'),
    Hive.openBox<BovinoRepo>('bovinosrepo'),
    Hive.openBox<RepoEntrega>('repoentregas'),
  ]);

  // 🚨 SOLO QUITAR LOS COMENTARIOS SI QUERÉS BORRAR LAS CAJAS EN USO
  // Esto elimina todo lo almacenado en esas cajas, útil para pruebas.
  
  // await Hive.box<Entregas>('entregas').clear();
  // await Hive.box<AltaEntrega>('altaentregas').clear();
  // await Hive.box<RepoEntrega>('repoentregas').clear();
  // print("🧹 Cajas limpiadas: entregas, altaentregas, repoentregas");
  

  // Inicializa controladores
  Get.put(LoginController());
  Get.put(ThemeController());
  Get.put(CatalogosController());

  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeController.themeData.value,
        initialRoute: '/initial',
        getPages: [
          GetPage(name: '/initial', page: () => InitialView()),
          GetPage(name: '/splash', page: () => SplashScreen()),
          GetPage(name: '/login', page: () => const LoginView()),
          GetPage(name: '/home', page: () => const HomeView()),
          GetPage(name: '/entrega', page: () => EntregasView()),
          GetPage(name: '/formbovinos', page: () => FormBovinosView()),
          GetPage(name: '/formrepo', page: () => FormRepoView()),
          GetPage(name: '/repo', page: () => RepoView()),
          GetPage(name: '/managebag', page: () => ManageBagView()),
          GetPage(name: '/sendview', page: () => EnviarView()),
          GetPage(name: '/catalogs', page: () => CatalogosScreen()),
          GetPage(name: '/configs', page: () => ConfiguracionesScreen()),
          GetPage(name: '/verifycue', page: () => VerifyEstablishmentView()),
        ],
      );
    });
  }
}
class InitialView extends StatelessWidget {
  final ThemeController themeController = Get.find();
  final CatalogosController catalogosController = Get.find();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await themeController.loadTheme();

      final configBox = Hive.box<AppConfig>('appConfig');
      final config = configBox.get('config');

      // Si no hay configuración, ir a splash
      if (config == null) {
        Get.offAllNamed('/splash');
        return;
      }

      final boxDep = Hive.box<Departamento>('departamentos');
      final boxMun = Hive.box<Municipio>('municipios');
      final boxRaz = Hive.box<Raza>('razas');

      // Si es la primera vez o si los catálogos están vacíos, forzar la descarga
      if (config.isFirstTime || boxDep.isEmpty || boxMun.isEmpty || boxRaz.isEmpty) {
        print("✅ Primera vez o catálogos vacíos, redirigiendo a descarga de catálogos");
        catalogosController.isForcedDownload.value = true;
        Get.offAllNamed('/catalogs');
        return;
      }

      // Si todo está bien, ir al home
      Get.offAllNamed('/home');
    });

    return Scaffold(
      body: Center(
        child: SpinKitRing(
          color: themeController.spinKitRingColor,
          size: 50.0,
        ),
      ),
    );
  }
}

