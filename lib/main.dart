import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trazaapp/controller/baja_controller.dart';
import 'package:trazaapp/controller/catalogs_controller.dart';
import 'package:trazaapp/controller/formrepo_controller.dart';
import 'package:trazaapp/data/local/models/appconfig/appconfig_adapter.dart';
import 'package:trazaapp/data/local/models/appconfig/appconfig_model.dart';
import 'package:trazaapp/data/local/models/bag/bag_operadora.dart';
import 'package:trazaapp/data/local/models/bag/bag_operadora_adapter.dart';
import 'package:trazaapp/data/local/models/baja/baja_model.dart';
import 'package:trazaapp/data/local/models/baja/baja_adapter.dart';
import 'package:trazaapp/data/local/models/bovinos/bovino.dart';
import 'package:trazaapp/data/local/models/bovinos/bovino_adapter.dart';
import 'package:trazaapp/data/local/models/departamentos/departamento.dart';
import 'package:trazaapp/data/local/models/departamentos/departamento_adapter.dart';
import 'package:trazaapp/data/local/models/entregas/entregas.dart';
import 'package:trazaapp/data/local/models/entregas/entregas_adapter.dart';
import 'package:trazaapp/data/local/models/establecimiento/establecimiento.dart';
import 'package:trazaapp/data/local/models/establecimiento/establecimiento_adapter.dart';
import 'package:trazaapp/data/local/models/home_stat.dart';
import 'package:trazaapp/data/local/models/motivosbajaarete/motivosbajaarete.dart';
import 'package:trazaapp/data/local/models/motivosbajaarete/motivosbajaarete_adapter.dart';
import 'package:trazaapp/data/local/models/motivosbajabovino/motivosbajabovino.dart';
import 'package:trazaapp/data/local/models/motivosbajabovino/motivosbajabovino_adapter.dart';
import 'package:trazaapp/data/local/models/municipios/minicipio_adapter.dart';
import 'package:trazaapp/data/local/models/municipios/municipio.dart';
import 'package:trazaapp/data/local/models/productores/productor.dart';
import 'package:trazaapp/data/local/models/productores/productor_adapter.dart';
import 'package:trazaapp/data/local/models/razas/raza.dart';
import 'package:trazaapp/data/local/models/razas/raza_adapter.dart';
import 'package:trazaapp/data/local/models/altaentrega/altaentrega.dart';
import 'package:trazaapp/data/local/models/altaentrega/altaentrega_adapter.dart';
import 'package:trazaapp/data/local/models/altaentrega/resbov_adapter.dart';
import 'package:trazaapp/data/local/models/reposicion/bovinorepo.dart';
import 'package:trazaapp/data/local/models/reposicion/bovinorepo_adapter.dart';
import 'package:trazaapp/data/local/models/reposicion/repoentrega.dart';
import 'package:trazaapp/data/local/models/reposicion/repoentrega_adapter.dart';
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
import 'package:trazaapp/presentation/baja/baja_form_view.dart';
import 'package:trazaapp/presentation/baja/baja_view.dart';
import 'package:trazaapp/presentation/baja/baja_send_view.dart';
import 'package:trazaapp/presentation/scanner/scanner_view.dart';
import 'package:trazaapp/presentation/baja/baja_select_view.dart';
import 'package:trazaapp/presentation/baja/baja_multiple_view.dart';
import 'package:trazaapp/data/local/models/baja/arete_baja_adapter.dart';
import 'package:trazaapp/presentation/consultas/consultaalta_view.dart';
import 'package:trazaapp/controller/consultasaltas_controller.dart';
import 'package:trazaapp/presentation/reposcreen/send_repo_view.dart';
import 'package:trazaapp/presentation/views/profile_view.dart';
import 'package:trazaapp/presentation/consultas/consultarepo_view.dart';
import 'package:trazaapp/controller/consultasrepo_controller.dart';
import 'package:trazaapp/presentation/consultas/consultas_menu_view.dart';
import 'package:trazaapp/presentation/sendscreen/send_menu_view.dart';
import 'package:trazaapp/presentation/consultas/consultabaja_view.dart';
import 'package:trazaapp/controller/consultasbajas_controller.dart';
import 'package:trazaapp/data/local/models/bag/rango_bag_adapter.dart';
import 'package:trazaapp/presentation/baja/baja_form_any_view.dart';
import 'package:trazaapp/data/local/models/bajasinorigen/baja_sin_origen.dart';
import 'package:trazaapp/data/local/models/bajasinorigen/baja_sin_origen_adapter.dart';
import 'package:trazaapp/presentation/consultas/consultabajassinorigen_view.dart';
import 'package:trazaapp/controller/consultasbajassinorigen_controller.dart';
import 'package:trazaapp/controller/arete_input_controller.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive
  await Hive.initFlutter();

  // Registro de adaptadores
  Hive.registerAdapter(EntregasAdapter());
  Hive.registerAdapter(BovinoAdapter());
  Hive.registerAdapter(EstablecimientoAdapter());
  Hive.registerAdapter(ProductorAdapter());
  Hive.registerAdapter(BagAdapter());
  Hive.registerAdapter(RangoBagAdapter());
  Hive.registerAdapter(DepartamentoAdapter());
  Hive.registerAdapter(MunicipioAdapter());
  Hive.registerAdapter(AppConfigAdapter());
  Hive.registerAdapter(AltaEntregaAdapter());
  Hive.registerAdapter(BovinoResumenAdapter());
  Hive.registerAdapter(RazaAdapter());
  Hive.registerAdapter(BovinoRepoAdapter());
  Hive.registerAdapter(RepoEntregaAdapter());
  Hive.registerAdapter(BajaAdapter());
  Hive.registerAdapter(AreteBajaAdapter());
  Hive.registerAdapter(MotivoBajaAreteAdapter());
  Hive.registerAdapter(MotivoBajaBovinoAdapter());
  Hive.registerAdapter(BajaSinOrigenAdapter());

  // Abrir cajas en paralelo para mejor rendimiento
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
    Hive.openBox<Baja>('bajas'),
    Hive.openBox<MotivoBajaArete>('motivosbajaarete'),
    Hive.openBox<MotivoBajaBovino>('motivosbajabovino'),
    Hive.openBox<BajaSinOrigen>('bajassinorigen'),
  ]);

  // 🚨 SOLO QUITAR LOS COMENTARIOS SI QUERÉS BORRAR LAS CAJAS EN USO
  // Esto elimina todo lo almacenado en esas cajas, útil para pruebas.
  // await Hive.box<Entregas>('entregas').clear();
  // await Hive.box<Bag>('bag').clear();
  // await Hive.box<AltaEntrega>('altaentregas').clear();
  // await Hive.box<RepoEntrega>('repoentregas').clear();
  // await Hive.box<Baja>('bajas').clear();
  // await Hive.box<Bovino>('bovinos').clear();
  // await Hive.box<Establecimiento>('establecimientos').clear();
  // await Hive.box<Productor>('productores').clear();
  // await Hive.box<Raza>('razas').clear();
  // await Hive.box<BovinoResumen>('resumenBovino').clear();
  // await Hive.box<MotivoBajaArete>('motivosbajaarete').clear();
  // await Hive.box<MotivoBajaBovino>('motivosbajabovino').clear();
  // await Hive.box<Departamento>('departamentos').clear();
  // await Hive.box<Municipio>('municipios').clear();
  // await Hive.box<BovinoRepo>('bovinosrepo').clear();
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
          GetPage(
            name: '/formrepo',
            page: () => FormRepoView(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => FormRepoController());
            }),
          ),
          GetPage(name: '/repo', page: () => RepoView()),
          GetPage(name: '/managebag', page: () => ManageBagView()),
          GetPage(name: '/sendview', page: () => EnviarView()),
          GetPage(name: '/catalogs', page: () => CatalogosScreen()),
          GetPage(name: '/configs', page: () => ConfiguracionesScreen()),
          GetPage(name: '/verifycue', page: () => VerifyEstablishmentView()),
          GetPage(name: '/baja/select', page: () => const BajaSelectView()),
          // GetPage(
          //   name: '/baja/form',
          //   page: () => const BajaFormView(),
          //   binding: BindingsBuilder(() {
          //     Get.lazyPut(() => BajaController(), fenix: true);
          //     Get.lazyPut(() => AreteInputController(), tag: 'areteInput', fenix: true);
          //   }),
          // ),
          GetPage(name: '/baja/form', page: () => BajaFormView()),
          GetPage(
            name: '/baja/send',
            page: () => const BajaSendView(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => BajaController());
            }),
          ),
          GetPage(
              name: '/scanner',
              page: () => const ScannerView(),
              preventDuplicates: false // Permite abrir múltiples instancias
              ),
          GetPage(name: '/consultas/menu', page: () => const ConsultasMenuView()),
          GetPage(
            name: '/consultas/altas',
            page: () => const ConsultasView(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => ConsultasController());
            }),
          ),
          GetPage(
            name: '/consultas/repos',
            page: () => const ConsultasRepoView(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => ConsultasRepoController());
            }),
          ),
          GetPage(name: '/sendrepo', page: () => SendRepoView()),
          GetPage(name: '/perfil', page: () => const ProfileView()),
          GetPage(name: '/send/menu', page: () => const SendMenuView()),
          GetPage(
            name: '/consultas/bajas',
            page: () => const ConsultaBajaView(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => ConsultasBajasController());
            }),
          ),
          GetPage(
            name: '/baja/formany',
            page: () => const BajaFormAnyView(),
          ),
          GetPage(
            name: '/consultabajassinorigen',
            page: () => const ConsultaBajaSinOrigenView(),
            binding: BindingsBuilder(() {
              Get.put(ConsultasBajasSinOrigenController());
            }),
          ),
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
      if (config.isFirstTime ||
          boxDep.isEmpty ||
          boxMun.isEmpty ||
          boxRaz.isEmpty) {
        print(
            "✅ Primera vez o catálogos vacíos, redirigiendo a descarga de catálogos");
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
