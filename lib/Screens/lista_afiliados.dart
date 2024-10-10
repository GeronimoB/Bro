import 'dart:convert';

import 'package:bro_app_to/Screens/retiro.dart';
import 'package:bro_app_to/components/app_bar_title.dart';
import 'package:bro_app_to/components/custom_text_button.dart';
import 'package:bro_app_to/components/referido_item.dart';
import 'package:bro_app_to/components/snackbar.dart';
import 'package:bro_app_to/providers/user_provider.dart';
import 'package:bro_app_to/src/auth/data/models/user_model.dart';
import 'package:bro_app_to/utils/api_client.dart';
import 'package:bro_app_to/utils/current_state.dart';
import 'package:bro_app_to/utils/referido_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ListaReferidosScreen extends StatefulWidget {
  const ListaReferidosScreen({Key? key}) : super(key: key);

  @override
  ListaReferidosScreenState createState() => ListaReferidosScreenState();
}

class ListaReferidosScreenState extends State<ListaReferidosScreen> {
  late UserModel user;
  late UserProvider provider;
  bool isLoading = true;

  @override
  void initState() {
    provider = Provider.of<UserProvider>(context, listen: false);
    user = provider.getCurrentUser();
    fetchReferrals();
    super.initState();
  }

  Future<Map<String, dynamic>>? fetchReferrals() async {
    try {
      final referrals =
          await ApiClient().post('auth/afiliados', {"userId": user.userId});
      if (referrals.statusCode == 200) {
        final afiliados = jsonDecode(referrals.body)["players"];
        final total = jsonDecode(referrals.body)["total"].toDouble();
        return {'afiliados': mapListToAfiliados(afiliados), 'total': total};
      } else {
        return {'afiliados': [], 'total': 0.0};
      }
    } catch (error) {
      print('${translations!["errorGettingReferrals"]}: $error');
      return {'afiliados': [], 'total': 0.0};
    }
  }

  @override
  Widget build(BuildContext context) {
    user = provider.getCurrentUser();
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed(
          user.isAgent ? '/config-agent' : '/config-player',
        );
        return false;
      },
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C2C2C), Color(0xFF000000)],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
            title: appBarTitle(translations!["affiliates"]),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF00E050),
                size: 32,
              ),
              onPressed: () {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                final user = userProvider.getCurrentUser();
                Navigator.of(context).pushReplacementNamed(
                  user.isAgent ? '/config-agent' : '/config-player',
                );
              },
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(
                      text:
                          'https://panelsys.bro.futbol/ref/${user.referralCode}'));
                  showSucessSnackBar(
                      context, translations!["AffiliateLinkCopiedMessage"]);
                },
                child: Text(
                  'https://panelsys.bro.futbol/ref/${user.referralCode}',
                  style: const TextStyle(
                    color: Color(0xFF05FF00),
                    fontFamily: 'Montserrat',
                    fontSize: 15.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: user.referralCode));
                  showSucessSnackBar(
                      context, translations!["AffiliateCodeCopiedMessage"]);
                },
                child: Container(
                  margin: const EdgeInsets.all(25),
                  width: 400,
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30.0),
                    border:
                        Border.all(color: const Color(0xFF05FF00), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        translations!["yourCode"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      Text(
                        user.referralCode,
                        style: const TextStyle(
                          color: Color(0xFF05FF00),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                translations!["referredPeople"],
                style: const TextStyle(
                  color: Color(0xFF05FF00),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15.0),
              FutureBuilder(
                future: fetchReferrals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF05FF00)),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          '${translations!["error"]}: ${snapshot.error}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            fontSize: 18.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    final List<dynamic> afiliados = snapshot.data?['afiliados'];
                    final double total = snapshot.data?['total'] ?? 0.0;

                    if (afiliados.isEmpty) {
                      return Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 35.0),
                            child: Text(
                              translations!["noReferralsMessage"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                                fontSize: 14.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        SizedBox(
                          height: 165,
                          width: 400,
                          child: ListView.builder(
                            itemCount: afiliados.length,
                            itemBuilder: (context, index) {
                              final afiliado = afiliados[index];

                              return ReferidoItem(
                                email: afiliado.email,
                                ganancia: '${afiliado.comision} €',
                              );
                            },
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: '${translations!["total"]}:',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontSize: 15.0,
                            ),
                            children: [
                              TextSpan(
                                text: '\n $total €',
                                style: const TextStyle(
                                  color: Color(0xFF05FF00),
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40.0,
                                ),
                              )
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32.0),
                        CustomTextButton(
                          onTap: () {
                            if (total > 0) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        RetirarMenu(total: total)),
                              );
                            } else {
                              showErrorSnackBar(context,
                                  translations!["NoFundsToWithdrawMessage"]);
                            }
                          },
                          text: translations!["withdraw"],
                          buttonPrimary: true,
                          width: 100,
                          height: 40,
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 32.0),
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/Logo.png',
                  width: 104,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
