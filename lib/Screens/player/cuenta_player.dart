import 'dart:convert';
import 'dart:io';

import 'package:bro_app_to/components/app_bar_title.dart';
import 'package:bro_app_to/components/avatar_placeholder.dart';
import 'package:bro_app_to/Screens/planes_pago.dart';
import 'package:bro_app_to/components/planes_cuenta_widget.dart';
import 'package:bro_app_to/providers/user_provider.dart';
import 'package:bro_app_to/utils/api_constants.dart';
import 'package:bro_app_to/utils/current_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:bro_app_to/components/custom_text_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bro_app_to/providers/player_provider.dart';
import 'package:http/http.dart' as http;

import '../../components/i_field.dart';
import '../../utils/api_client.dart';

class CuentaPage extends StatefulWidget {
  const CuentaPage({super.key});

  @override
  CuentaPageState createState() => CuentaPageState();
}

class CuentaPageState extends State<CuentaPage> {
  bool deslizadorActivado = true;
  bool expanded = false;
  final picker = ImagePicker();
  bool _isExpanded = false;
  late UserProvider userProvider;
  late PlayerProvider playerProvider;
  final ScrollController _scrollController = ScrollController();
  Color _appBarColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    playerProvider = Provider.of<PlayerProvider>(context, listen: false);
  }

  void _onScroll() {
    if (_scrollController.offset > 50) {
      setState(() {
        _appBarColor = Colors.black.withOpacity(0.9);
      });
    } else {
      setState(() {
        _appBarColor = Colors.transparent;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _uploadImage(File(pickedFile.path));
    } else {
      debugPrint('No image selected.');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    final player = playerProvider.getPlayer()!;
    const url = '${ApiConstants.baseUrl}/auth/upload-player-image';

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.files
        .add(await http.MultipartFile.fromPath('imagen', imageFile.path));
    request.fields["userId"] = player.userId ?? '0';
    request.fields["isAgent"] = player.isAgent.toString();
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      final image = jsonDecode(responseBody)["image"];
      playerProvider.updateLocalImage(image);
      userProvider.updateLocalImage(image);
      debugPrint('Image uploaded successfully');
    } else {
      debugPrint('Failed to upload image. Error code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final player = playerProvider.getPlayer()!;
    DateTime? birthDate = player.birthDate;

    String formattedDate =
        birthDate != null ? DateFormat('dd-MM-yyyy').format(birthDate) : '';
    String shortInfo =
        '${provincesByCountry[player.pais][player.provincia]}, ${countries[player.pais]}\n ${translations!["birthdate"]}: $formattedDate';
    String fullInfo =
        '${provincesByCountry[player.pais][player.provincia]}, ${countries[player.pais]}\n ${translations!["birthdate"]}: $formattedDate\n ${translations!["Categorys"]}: ${categorias[player.categoria]}\n ${posiciones[translations!["position_label"]]}: ${player.position}\n ${translations!["club_label"]}: ${player.club}\n ${translations!["national_selection_short"]}: ${selecciones[player.seleccionNacional]} ${nationalCategories[player.seleccionNacional][player.categoriaSeleccion]}\n ${translations!["dominant_feet"]}: ${piesDominantes[player.pieDominante]} \n ${translations!["Achievements2"]}: ${player.logrosIndividuales}  \n ${translations!["height_label"]}: ${player.altura}';

    double width = MediaQuery.of(context).size.width;

    return Container(
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
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: _appBarColor,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: appBarTitle(translations!["ACCOUNT"]),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF00E050),
              size: 32,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: _openGallery,
                child: Stack(
                  children: [
                    ClipOval(
                      child: player.userImage != ''
                          ? ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Colors.grey.withOpacity(0.5),
                                BlendMode.dstATop,
                              ),
                              child: CachedNetworkImage(
                                placeholder: (context, url) =>
                                    AvatarPlaceholder(150),
                                errorWidget: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/fot.png',
                                    fit: BoxFit.fill,
                                    width: 150,
                                    height: 150,
                                  );
                                },
                                imageUrl: player.userImage ?? '',
                                fit: BoxFit.fill,
                                width: 150,
                                height: 150,
                              ),
                            )
                          : ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Colors.grey.withOpacity(0.5),
                                BlendMode.dstATop,
                              ),
                              child: Image.asset(
                                'assets/images/fot.png',
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    const Positioned(
                      bottom: 0,
                      top: 0,
                      right: 0,
                      left: 0,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${player.name} ${player.lastName}',
                    style: const TextStyle(
                      color: Color(0xFF05FF00),
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  if (player.verificado)
                    const Icon(
                      Icons.verified,
                      color: Color(0xFF00E050),
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                _isExpanded ? fullInfo : shortInfo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? 'Ver menos' : 'Ver más',
                  style: const TextStyle(
                    color: Color(0xFF05FF00),
                    fontSize: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 35),
              CarouselSlider(
                options: CarouselOptions(
                  height: 400.0,
                  enlargeCenterPage: true,
                  autoPlay: false,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: width > 550 ? 0.5 : 0.8,
                ),
                items: planes.map((plan) {
                  final isActualPlan =
                      userProvider.getCurrentUser().subscription == plan.nombre;
                  return PlanesCuentaWidget(
                    plan: plan,
                    isActualPlan: isActualPlan,
                    cancelModal: confirmationCancelDialog,
                  );
                }).toList(),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Image.asset(
                    'assets/images/Logo.png',
                    width: 104,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void confirmationCancelDialog(BuildContext context, PlayerProvider provider) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (BuildContext context) {
        TextEditingController ctlr = TextEditingController();
        return Dialog(
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                padding: const EdgeInsets.all(15),
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xff3B3B3B),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(5, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 5),
                    Text(
                      translations!["ConfirmCancelSubscription"],
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Color(0xff00E050),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      translations!["EnterReasonForCancellation"],
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1),
                    ),
                    iField(ctlr, ''),
                    const SizedBox(height: 40),
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
                            final id = provider.getPlayer()!.userId;

                            await ApiClient().post('auth/cancel-subscription',
                                {"userId": id, "reason": ctlr.text});
                            Navigator.of(context).pop();
                          },
                          text: translations!["Continue"],
                          buttonPrimary: true,
                          width: 90,
                          height: 27,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ));
      },
    );
  }
}
