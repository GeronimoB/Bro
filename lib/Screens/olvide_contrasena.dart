import 'package:bro_app_to/Screens/intro.dart';
import 'package:bro_app_to/components/custom_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OlvideContrasenaPage extends StatelessWidget {
  const OlvideContrasenaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Fondo_oc.png'),
          fit: BoxFit.cover,
        ),
        color: Color.fromARGB(255, 27, 23, 23),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF00E050),
              size: 32,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.transparent,
        ),
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            const Text(
              'Recuperación de Cuenta',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Te enviaremos un correo electrónico con un enlace con el que ingresarás de inmediato.',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 35),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle:
                      TextStyle(color: Color.fromARGB(255, 255, 250, 250)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(height: 50),
            CustomTextButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                },
                text: 'Recuperar',
                buttonPrimary: false,
                width: 183.5,
                height: 39),
            const SizedBox(height: 50),
            SvgPicture.asset(
              width: 100,
              height: 49,
              'assets/icons/Logo.svg',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}