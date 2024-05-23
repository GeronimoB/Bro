import 'dart:convert';

import 'package:bro_app_to/Screens/player/bottom_navigation_bar_player.dart';
import 'package:bro_app_to/Screens/player/verification.dart';
import 'package:bro_app_to/components/custom_box_shadow.dart';
import 'package:bro_app_to/components/custom_text_button.dart';
import 'package:bro_app_to/components/snackbar.dart';
import 'package:bro_app_to/providers/user_provider.dart';
import 'package:bro_app_to/src/auth/data/models/user_model.dart';
import 'package:bro_app_to/src/registration/data/models/player_full_model.dart';
import 'package:bro_app_to/utils/current_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../components/app_bar_title.dart';
import '../providers/player_provider.dart';
import '../utils/api_client.dart';
import 'package:http/http.dart' as http;

import '../utils/api_constants.dart';
import '../utils/tarjeta_model.dart';
import 'package:http_parser/http_parser.dart';

class AgregarTarjetaScreen extends StatefulWidget {
  final double valueToPay;
  final String cupon;
  const AgregarTarjetaScreen({
    required this.valueToPay,
    required this.cupon,
    Key? key,
  }) : super(key: key);

  @override
  AgregarTarjetaScreenState createState() => AgregarTarjetaScreenState();
}

class AgregarTarjetaScreenState extends State<AgregarTarjetaScreen> {
  final controller = CardFormEditController();
  int isSelected = -1;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    controller.addListener(update);
  }

  @override
  void dispose() {
    controller.removeListener(update);
    controller.dispose();
    super.dispose();
  }

  void update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: true);

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C2C2C), Color(0xFF000000)],
        ),
      ),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0,
              centerTitle: true,
              title: appBarTitle(translations!["payment_method"]),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF00E050),
                  size: 32,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: Container(
              height: MediaQuery.of(context).size.height - 100,
              padding: const EdgeInsets.all(26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.maxFinite,
                    child: Text(
                      translations!["available_cards"],
                      style: const TextStyle(
                          color: Color(0xFF00E050),
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(0),
                    height: playerProvider.getSavedCards()!.isEmpty
                        ? 0
                        : playerProvider.getSavedCards()!.length < 3
                            ? MediaQuery.of(context).size.height * 0.15
                            : MediaQuery.of(context).size.height * 0.25,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: playerProvider.getSavedCards()!.length,
                      itemBuilder: (context, index) {
                        Tarjeta tarjeta =
                            playerProvider.getSavedCards()![index];
                        final player = playerProvider.getPlayer() ??
                            playerProvider.getTemporalUser();
                        final String titular =
                            '${player.name} ${player.lastName}';
                        return _buildListCard(
                            tarjeta, index, titular, playerProvider);
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: double.maxFinite,
                    child: Text(
                      translations!["add_card_title"],
                      style: const TextStyle(
                          color: Color(0xFF00E050),
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  CardFormField(
                    countryCode: 'ES',
                    enablePostalCode: false,
                    onCardChanged: (details) {
                      if (controller.details.complete) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    controller: controller,
                    style: CardFormStyle(
                      backgroundColor: Colors.white,
                      borderWidth: 2,
                      borderColor: const Color(0xFF00E050),
                      cursorColor: const Color(0xFF00E050),
                      borderRadius: 15,
                      fontSize: 14,
                      textColor: Colors.black,
                      placeholderColor: Colors.black,
                    ),
                  ),
                  CustomTextButton(
                      onTap: controller.details.complete == true
                          ? () {
                              _handleAddCard();
                            }
                          : () => FocusScope.of(context).unfocus(),
                      text: translations!["add_card_btn"],
                      buttonPrimary: false,
                      width: 233,
                      height: 32),
                  const SizedBox(height: 16.0),
                  CustomTextButton(
                      onTap: () {
                        _handlePressPay();
                      },
                      text: translations!["pay_btn"],
                      buttonPrimary: true,
                      width: 233,
                      height: 30),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child:
                          SvgPicture.asset('assets/icons/Logo.svg', width: 80),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF05FF00)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23)),
              contentPadding: const EdgeInsets.all(25),
              backgroundColor: const Color(0xFF3B3B3B),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    translations!["upload_video_loading"],
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  const LinearProgressIndicator(
                    color: Color(0xff00E050),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListCard(Tarjeta tarjeta, int index, String titular,
      PlayerProvider playerProvider) {
    return GestureDetector(
      onTap: () {
        playerProvider.setSelectedCard(tarjeta);
        setState(() {
          isSelected = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF00E050)),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: isSelected == index
                ? [
                    const CustomBoxShadow(
                        color: Color(0xFF05FF00), blurRadius: 6)
                  ]
                : null,
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            leading: Image.asset(
              tarjeta.displayBrand == 'visa'
                  ? 'assets/images/Visa_icon.png'
                  : 'assets/images/Mastercard_icon.png',
              width: 70,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titular,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '*${tarjeta.last4Numbers}',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                  softWrap: false,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF00E050), size: 32),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                final player = playerProvider.getPlayer() ??
                    playerProvider.getTemporalUser();
                final asociatePaymentMethod = await ApiClient().post(
                  'security_filter/v1/api/payment/delete-payment-method',
                  {
                    "paymentMethodId": tarjeta.cardId,
                    "customerId": player.customerStripeId,
                  },
                );

                if (asociatePaymentMethod.statusCode != 200) {
                  showErrorSnackBar(
                      context, translations!["error_deleting_card"]);

                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }
                setState(() {
                  _isLoading = false;
                });
                final savedCards =
                    jsonDecode(asociatePaymentMethod.body)["paymentMethods"];
                showSucessSnackBar(
                    context, translations!["scss_deleting_card"]);
                playerProvider.setCards(mapListToTarjetas(savedCards));
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddCard() async {
    if (!controller.details.complete) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final playerProvider =
          Provider.of<PlayerProvider>(context, listen: false);
      final player =
          playerProvider.getPlayer() ?? playerProvider.getTemporalUser();
      final billingDetails = BillingDetails(
        email: player.email,
      );

      final paymentMethod = await Stripe.instance.createPaymentMethod(
          params: PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(
          billingDetails: billingDetails,
        ),
      ));

      final customerId = player.customerStripeId;
      controller.clear();
      final asociatePaymentMethod = await ApiClient().post(
        'security_filter/v1/api/payment/payment-method',
        {
          "paymentMethodId": paymentMethod.id.toString(),
          "customerId": customerId,
        },
      );

      if (asociatePaymentMethod.statusCode != 200) {
        showErrorSnackBar(context, translations!["error_saving_card"]);

        setState(() {
          _isLoading = false;
        });
        return;
      }

      final savedCards =
          jsonDecode(asociatePaymentMethod.body)["paymentMethods"];
      showSucessSnackBar(context, translations!["scss_saving_card"]);

      playerProvider.setCards(mapListToTarjetas(savedCards));
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      showErrorSnackBar(context, 'Error: $e');

      setState(() {
        _isLoading = false;
      });
      rethrow;
    }
  }

  Future<void> _handlePressPay() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final isSubscription = playerProvider.isSubscriptionPayment;
    final player =
        playerProvider.getPlayer() ?? playerProvider.getTemporalUser();

    if (playerProvider.selectedCard == null) {
      showErrorSnackBar(context, translations!["select_payment_card"]);
      return;
    }

    try {
      _setLoadingState(true);

      if (isSubscription) {
        await _handleSubscriptionPayment(player, playerProvider);
      } else {
        await _handleFavoriteVideoPayment(player, playerProvider);
      }
    } catch (e) {
      showErrorSnackBar(context, 'Error: $e');
      _setLoadingState(false);
      rethrow;
    }
  }

  Future<void> _handleSubscriptionPayment(
      PlayerFullModel player, PlayerProvider playerProvider) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final subscriptionIntent = await ApiClient().post(
      'security_filter/v1/api/payment/subscription',
      {
        "planId": playerProvider.getActualPlan()!.idPlan,
        "customerId": player.customerStripeId,
        "paymentMethodId": playerProvider.selectedCard!.cardId,
        "paymentMethod":
            "${playerProvider.selectedCard!.displayBrand!.toUpperCase()} *${playerProvider.selectedCard!.last4Numbers}",
        "plan": playerProvider.getActualPlan()!.nombre,
        "userId": player.userId,
        "amount": widget.valueToPay.toString(),
        "isSuscription": "1",
        "cupon": widget.cupon
      },
    );

    if (subscriptionIntent.statusCode != 200) {
      showErrorSnackBar(context, translations!['error_paying']);
      _setLoadingState(false);
      return;
    }

    _setLoadingState(false);

    if (playerProvider.isNewSubscriptionPayment) {
      showSucessSnackBar(context, translations!['scss_paying']);
      await Future.delayed(const Duration(seconds: 1));

      userProvider.setCurrentUser(UserModel.fromPlayer(player,
          status: true, plan: playerProvider.getActualPlan()?.nombre));
      playerProvider.setNewUser();
      _showUploadDialog();
      final video = playerProvider.videoPathToUpload;
      final image = playerProvider.imagePathToUpload;
      final userId = player.userId;
      uploadVideoAndImage(
          video, image, userId, playerProvider.getActualPlan()?.nombre);
    } else {
      userProvider.updatePlan(playerProvider.getActualPlan()!.nombre,
          status: true);
      showSucessSnackBar(context, translations!['scss_update_sub']);

      await Future.delayed(const Duration(seconds: 2));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => const CustomBottomNavigationBarPlayer()),
      );
    }
  }

  Future<void> _handleFavoriteVideoPayment(
      PlayerFullModel player, PlayerProvider playerProvider) async {
    final video = playerProvider.videoProcessingFavoritePayment;
    final destacarVideo = await ApiClient().post(
      'security_filter/v1/api/payment/subscription',
      {
        "planId": "price_1P2RbpIkdX2ffauue0ZIWVUn",
        "customerId": player.customerStripeId,
        "paymentMethodId": playerProvider.selectedCard!.cardId,
        "paymentMethod":
            "${playerProvider.selectedCard!.displayBrand!.toUpperCase()} *${playerProvider.selectedCard!.last4Numbers}",
        "plan": "Destacar video",
        "userId": player.userId,
        "amount": widget.valueToPay.toString(),
        "isSuscription": "0",
        'videoId': video?.id.toString(),
        "cupon": widget.cupon
      },
    );

    if (destacarVideo.statusCode != 200) {
      showErrorSnackBar(context, translations!['error_paying']);
      _setLoadingState(false);
      return;
    }

    playerProvider.indexProcessingVideoFavoritePayment = 0;
    playerProvider.videoProcessingFavoritePayment = null;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) =>
              const CustomBottomNavigationBarPlayer(initialIndex: 4)),
    );
  }

  void _setLoadingState(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  Future<void> uploadVideoAndImage(String? videoPath, Uint8List? uint8list,
      String? userId, String? plan) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/auth/uploadFiles'),
      );
      request.fields["userId"] = userId ?? '';
      if (videoPath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'video',
          videoPath,
        ));
      }

      if (uint8list != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'imagen',
          uint8list,
          filename: 'imagen.png',
          contentType: MediaType('image', 'png'),
        ));
      }

      var response = await request.send();

      // Verificar el estado de la respuesta
      if (response.statusCode == 200) {
        Navigator.pop(context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => plan == "Unlimited"
                  ? const VerificationScreen(
                      newUser: true,
                    )
                  : const CustomBottomNavigationBarPlayer()),
        );
      } else {
        Navigator.pop(context);
        showErrorSnackBar(context, translations!['err_upload_first_video']);

        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => plan == "Unlimited"
                  ? const VerificationScreen(
                      newUser: true,
                    )
                  : const CustomBottomNavigationBarPlayer()),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorSnackBar(context, translations!['err_upload_first_video']);

      await Future.delayed(const Duration(seconds: 2));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => plan == "Unlimited"
                ? const VerificationScreen(
                    newUser: true,
                  )
                : const CustomBottomNavigationBarPlayer()),
      );
    }
  }
}
