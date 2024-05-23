import 'dart:async';
import 'dart:convert';
import 'package:bro_app_to/Screens/player/bottom_navigation_bar_player.dart';
import 'package:bro_app_to/firebase_options.dart';
import 'package:bro_app_to/utils/api_constants.dart';
import 'package:bro_app_to/utils/current_state.dart';
import 'package:bro_app_to/utils/firebase_api.dart';
import 'package:bro_app_to/utils/language_localizations.dart';
import 'package:bro_app_to/utils/notification_model.dart';
import 'package:bro_app_to/utils/router_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:bro_app_to/Screens/intro.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/agent_provider.dart';
import 'providers/player_provider.dart';
import 'providers/user_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/auth/data/datasources/remote_data_source_impl.dart';
import 'src/auth/domain/entitites/user_entity.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Stripe.publishableKey = ApiConstants.stripePublicKey;
  await Stripe.instance.applySettings();
  List<NotificationModel> notificaciones = await getSavedNotifications();
  if (notificaciones.isNotEmpty) {
    currentNotifications.addAll(notificaciones.reversed);
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

Future<List<NotificationModel>> getSavedNotifications() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String>? savedNotifications = prefs.getStringList('notifications') ?? [];

  List<NotificationModel> notifications = savedNotifications
      .map((String notification) =>
          NotificationModel.fromJson(jsonDecode(notification)))
      .toList();

  return notifications;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MaterialColor customGreen = const MaterialColor(
      0xFF00F056,
      <int, Color>{
        50: Color(0xFFE0F7EF),
        100: Color(0xFFB3E1C9),
        200: Color(0xFF80CEA1),
        300: Color(0xFF4DBB79),
        400: Color(0xFF26AC5E),
        500: Color(0xFF00F056),
        600: Color(0xFF00C84B),
        700: Color(0xFF009A3B),
        800: Color(0xFF00732B),
        900: Color(0xFF004C1D),
      },
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => AgenteProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: GetMaterialApp(
        title: 'Bro app',
        debugShowCheckedModeBanner: false,
        navigatorKey: Get.key,
        theme: ThemeData(
          primarySwatch: Colors.green,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: customGreen,
            backgroundColor: Colors.black,
            cardColor: Colors.white,
          ),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        locale: const Locale('es', ''),
        initialRoute: RouteHelper.getInitialRoute(),
        getPages: RouteHelper.routes,
        defaultTransition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 350),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          LanguageLocalizations.delegate
        ],
        supportedLocales: const [
          Locale('es'),
          Locale('en'),
          Locale('it'),
          Locale('fr'),
          Locale('de'),
          Locale('pt'),
        ],
      ),
    );
  }
}

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  MySplashScreenState createState() => MySplashScreenState();
}

class MySplashScreenState extends State<MySplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await FirebaseApi().initNotifications(context);
    Stream<RemoteMessage> stream = FirebaseMessaging.onMessageOpenedApp;
    stream.listen((RemoteMessage event) async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              const CustomBottomNavigationBarPlayer(initialIndex: 3)));
    });
    loadRememberMe();
  }

  Future<void> loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language') ?? 'es';
    LanguageLocalizations? localizations = LanguageLocalizations.of(context);
    await localizations!.changeLanguage(languageCode);
    translations = LanguageLocalizations.of(context)!.getJsonTranslate();
    setState(() {
      final String savedUsername = prefs.getString('username') ?? '';
      final String savedPassword = prefs.getString('password') ?? '';
      if (savedUsername.isNotEmpty && savedPassword.isNotEmpty) {
        final playerProvider =
            Provider.of<PlayerProvider>(context, listen: false);
        RemoteDataSourceImpl(playerProvider).signIn(
            UserEntity(username: savedUsername, password: savedPassword),
            context,
            true,
            true);
      } else {
        Timer(
          const Duration(seconds: 2),
          () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SignInPage()),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 44, 44, 44),
              Color.fromARGB(255, 0, 0, 0),
            ],
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            width: 239,
            height: 117,
            fit: BoxFit.fill,
            'assets/icons/Logo.svg',
          ),
        ),
      ),
    );
  }
}
