import 'package:bro_app_to/components/custom_text_button.dart';
import 'package:bro_app_to/src/registration/presentation/screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:bro_app_to/src/auth/presentation/screens/sign_in.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/current_state.dart';
import '../utils/language_localizations.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  bool isPressedSignIn = false;
  bool isPressedCreateAccount = false;

  void changeLanguage(BuildContext context, String languageCode) async {
    LanguageLocalizations? localizations = LanguageLocalizations.of(context);
    if (localizations != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      await localizations.changeLanguage(languageCode);
      setState(() {
        translations = LanguageLocalizations.of(context)!.getJsonTranslate();
      });
    }
  }

  void languageDialog(BuildContext context) {
    String currentLanguage =
        LanguageLocalizations.of(context)?.currentLanguage ?? 'es';
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xff3B3B3B),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(5, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  languageTile(
                      context, 'en', translations!["english"], currentLanguage == 'en'),
                  languageTile(
                      context, 'es', translations!["spanish"], currentLanguage == 'es'),
                  languageTile(
                      context, 'de', translations!["german"], currentLanguage == 'de'),
                  languageTile(
                      context, 'it', translations!["italian"], currentLanguage == 'it'),
                  languageTile(
                      context, 'fr', translations!["french"], currentLanguage == 'fr'),
                  languageTile(
                      context, 'pt', translations!["portuguese"], currentLanguage == 'pt'),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: CustomTextButton(
                      text: translations!["close"],
                      buttonPrimary: true,
                      width: 120,
                      height: 35,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  Widget languageTile(
      BuildContext context, String languageCode, String language, bool select) {
    return InkWell(
      onTap: () {
        changeLanguage(context, languageCode);
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: select ? const Color(0xFF00F056) : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(12.0),
        width: double.infinity,
        child: Text(
          language,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background_1.png'),
            fit: BoxFit.fill,
          ),
          color: Color.fromARGB(26, 0, 0, 0),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    languageDialog(context);
                  },
                  child: const Icon(
                    Icons.language,
                    color: Color(0xff00E050),
                    size: 32,
                  ),
                ),
              )
            ],
          ),
          extendBody: true,
          body: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 150,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        width: 239,
                        height: 117,
                        fit: BoxFit.fill,
                        'assets/icons/Logo.svg',
                      ),
                      const SizedBox(height: 35),
                      CustomTextButton(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignInScreen()),
                            );
                          },
                          text: translations!['sign_in'],
                          buttonPrimary: false,
                          width: 304,
                          height: 39),
                      const SizedBox(height: 20),
                      CustomTextButton(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpScreen()),
                            );
                          },
                          text: translations!['create_account'],
                          buttonPrimary: true,
                          width: 304,
                          height: 39),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
