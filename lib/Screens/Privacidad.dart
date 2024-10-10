import 'dart:convert';

import 'package:bro_app_to/components/app_bar_title.dart';
import 'package:bro_app_to/components/custom_text_button.dart';
import 'package:bro_app_to/components/snackbar.dart';
import 'package:bro_app_to/providers/user_provider.dart';
import 'package:bro_app_to/utils/api_client.dart';
import 'package:bro_app_to/utils/current_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Privacidad extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  Privacidad({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 44, 44, 44),
            Color.fromARGB(255, 0, 0, 0)
          ],
        ),
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: appBarTitle(translations!["PRIVACY"]),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF00E050),
              size: 32,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                showPassDialog(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      translations!["ChangePassword"],
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showPassDialog(context);
                      },
                      child:
                          Icon(Icons.chevron_right, color: Color(0xff00E050)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ListTile(
            //   title: const Text(
            //     'AUTENTICACION DE DOBLE FACTOR',
            //     style: const TextStyle(
            //       color: Colors.white,
            //       fontFamily: 'Montserrat',
            //       fontSize: 16,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            //   onTap: () {
            //     _editarCampo(context, 'Autenticación de Doble Factor',
            //         TextEditingController());
            //   },
            //   trailing: Icon(Icons.chevron_right, color: Color(0xff00E050)),
            // ),
            const SizedBox(height: 10),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Image.asset(
                    'assets/images/Logo.png',
                    width: 104,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showPassDialog(BuildContext context) {
    TextEditingController oldPasswordCtlr = TextEditingController();
    TextEditingController newPasswordCtlr = TextEditingController();
    TextEditingController confirmPasswordCtlr = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(35),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  translations!["ChangePassword"],
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Color(0xff00E050),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Form(
                  autovalidateMode: AutovalidateMode.always,
                  key: _formKey,
                  child: TextFormField(
                    controller: oldPasswordCtlr,
                    decoration: InputDecoration(
                      labelText: translations!["OldPassword"],
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                      errorStyle: TextStyle(
                        color: Color.fromARGB(255, 255, 106, 106),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF00E050), width: 2),
                      ),
                    ),
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'Montserrat'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa una contraseña.';
                      }

                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Form(
                  autovalidateMode: AutovalidateMode.always,
                  key: _formKey2,
                  child: TextFormField(
                    controller: newPasswordCtlr,
                    decoration: InputDecoration(
                      labelText: translations!["NewPassword"],
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                      errorStyle: const TextStyle(
                        color: Color.fromARGB(255, 255, 106, 106),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF00E050), width: 2),
                      ),
                    ),
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'Montserrat'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa una contraseña.';
                      }
                      if (value.length < 8) {
                        return 'La contraseña debe tener al menos 8 caracteres.';
                      }
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        return 'La contraseña debe contener al menos una letra mayúscula.';
                      }
                      if (!value.contains(RegExp(r'[a-z]'))) {
                        return 'La contraseña debe contener al menos una letra minúscula.';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'La contraseña debe contener al menos un número.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Form(
                  autovalidateMode: AutovalidateMode.always,
                  key: _formKey3,
                  child: TextFormField(
                    controller: confirmPasswordCtlr,
                    decoration: InputDecoration(
                      labelText: translations!["ConfirmNewPassword"],
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                      errorStyle: const TextStyle(
                        color: Color.fromARGB(255, 255, 106, 106),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF00E050), width: 2),
                      ),
                    ),
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'Montserrat'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa una contraseña.';
                      }
                      if (value != newPasswordCtlr.text) {
                        return 'Las contraseñas no coinciden.';
                      }

                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomTextButton(
                      onTap: () => Navigator.of(context).pop(),
                      text: translations!["cancel"],
                      buttonPrimary: false,
                      width: 90,
                      height: 27,
                    ),
                    CustomTextButton(
                      onTap: () async {
                        final userProvider =
                            Provider.of<UserProvider>(context, listen: false);
                        final id =
                            userProvider.getCurrentUser().userId.toString();
                        final isAgent =
                            userProvider.getCurrentUser().isAgent.toString();
                        final response =
                            await ApiClient().post('auth/change-pssw', {
                          "UserId": id,
                          "OldPassword": oldPasswordCtlr.text,
                          "NewPassword": newPasswordCtlr.text
                        });
                        if (response.statusCode == 200) {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString('username', "");
                          prefs.setString('password', "");
                          Navigator.of(context).pop();
                          showSucessSnackBar(context,
                              translations!["PasswordUpdateSuccessMessage"]);
                        } else {
                          final jsonData = json.decode(response.body);
                          final errorMessage = jsonData["error"];
                          Navigator.of(context).pop();
                          showErrorSnackBar(context, errorMessage);
                        }
                      },
                      text: translations!["save"],
                      buttonPrimary: true,
                      width: 90,
                      height: 27,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editarCampo(
      BuildContext context, String label, TextEditingController controller) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (BuildContext context) {
        TextEditingController editingController =
            TextEditingController(text: controller.text);
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  onTap: () {
                    // Agrega la lógica para Google Authenticator
                    Navigator.pop(context);
                  },
                  title: Text(
                    translations!["GoogleAuthenticator"],
                    style: const TextStyle(
                      color: Color(0xff00E050),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
