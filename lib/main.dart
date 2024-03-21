import 'dart:async';
import 'package:bro_app_to/utils/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:bro_app_to/Intro.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = ApiConstants.stripePublicKey;

  await Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

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
      ],
      child: MaterialApp(
        title: 'Bro app',
        theme: ThemeData(
          primarySwatch: Colors.green,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: customGreen, // Color principal
            backgroundColor: Colors.black, // Color de fondo
            cardColor: Colors.white, // Color de la tarjeta
          ),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MySplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
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