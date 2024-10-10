import 'dart:convert';

import 'package:bro_app_to/components/app_bar_title.dart';
import 'package:bro_app_to/components/custom_box_shadow.dart';
import 'package:bro_app_to/components/custom_text_button.dart';
import 'package:bro_app_to/components/snackbar.dart';
import 'package:bro_app_to/utils/api_client.dart';
import 'package:bro_app_to/utils/current_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bro_app_to/Screens/agregar_tarjeta_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../components/i_field.dart';

class MetodoDePagoScreen extends StatefulWidget {
  final double valueToPay;
  const MetodoDePagoScreen({super.key, required this.valueToPay});

  @override
  State<MetodoDePagoScreen> createState() => _MetodoDePagoScreenState();
}

class _MetodoDePagoScreenState extends State<MetodoDePagoScreen> {
  bool cardSelected = false;
  bool transferSelected = false;
  double valueToPay = 0;
  late TextEditingController cupon;
  bool couponApplied = false;
  String couponToSend = '';
  @override
  void initState() {
    super.initState();
    valueToPay = widget.valueToPay;
    cupon = TextEditingController();
  }

  @override
  void dispose() {
    cupon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double metodoPagoWidth = 325.0;
    const double metodoPagoHeight = 106.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C2C2C), Color(0xFF000000)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          title: appBarTitle(translations!["payment_method"]),
          centerTitle: true,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                '$valueToPay €',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF00E050),
                  fontSize: 40,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTapDown: (_) {
                setState(() {
                  cardSelected = true;
                });
              },
              onTapUp: (_) {
                setState(() {
                  cardSelected = false;
                });
              },
              onTapCancel: () {
                setState(() {
                  cardSelected = false;
                });
              },
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        //AgregarTarjetaScreen(valueToPay: valueToPay, cupon: couponToSend),
                        AgregarTarjetaScreen(),
                  ),
                );
              },
              child: Container(
                width: metodoPagoWidth,
                height: metodoPagoHeight,
                decoration: BoxDecoration(
                    color: cardSelected ? Colors.black : Colors.white,
                    border:
                        Border.all(color: const Color(0xff05FF00), width: 1.5),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    boxShadow: cardSelected
                        ? [
                            const CustomBoxShadow(
                              color: Color(0xff05FF00),
                              blurRadius: 4,
                            )
                          ]
                        : null),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/Mastercard_icon.png',
                      width: 96,
                      height: 54,
                    ),
                    Image.asset(
                      'assets/images/Visa_icon.png',
                      width: 96,
                      height: 54,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25.0),
            Text(
              translations!["applyDisc"],
              style: const TextStyle(
                  color: Color(0xFF00E050),
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(width: 200, child: iField(cupon, '')),
                const SizedBox(
                  width: 10,
                ),
                CustomTextButton(
                  onTap: () => handleApplyDisc(cupon.text),
                  text: translations!["apply"],
                  buttonPrimary: true,
                  width: 100,
                  height: 25,
                )
              ],
            ),
            const SizedBox(height: 26),
            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: SvgPicture.asset(
                  'assets/icons/Logo.svg',
                  width: 80,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleApplyDisc(String coupon) async {
    cupon.clear();
    if (couponApplied) {
      return showErrorSnackBar(context, translations!['justOneCoupon']);
    }

    if (coupon == "") {
      return showErrorSnackBar(context, translations!['invalidCoupon']);
    }

    final response =
        await ApiClient().post('auth/check-coupon', {"code": coupon});

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final disc = jsonData["percent"];
      showSucessSnackBar(context, '${translations!['validCoupon']} $disc%');
      setState(() {
        valueToPay = valueToPay * (1 - disc / 100);
        couponApplied = true;
        couponToSend = coupon;
      });
    } else {
      final jsonData = jsonDecode(response.body);
      final err = jsonData["error"];
      showErrorSnackBar(context, err);
    }
  }
}
