import 'dart:convert';
import 'dart:io';

import 'package:bro_app_to/components/app_bar_title.dart';
import 'package:bro_app_to/components/avatar_placeholder.dart';
import 'package:bro_app_to/components/custom_dropdown.dart';
import 'package:bro_app_to/components/custom_text_button.dart';
import 'package:bro_app_to/components/i_field.dart';
import 'package:bro_app_to/components/snackbar.dart';
import 'package:bro_app_to/providers/player_provider.dart';
import 'package:bro_app_to/providers/user_provider.dart';
import 'package:bro_app_to/src/registration/data/models/player_full_model.dart';
import 'package:bro_app_to/src/registration/presentation/screens/select_camp.dart';
import 'package:bro_app_to/utils/api_client.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../utils/api_constants.dart';
import '../../utils/current_state.dart';

class EditarInfoPlayer extends StatefulWidget {
  const EditarInfoPlayer({super.key});

  @override
  EditarInfoPlayerState createState() => EditarInfoPlayerState();
}

class EditarInfoPlayerState extends State<EditarInfoPlayer> {
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _correoController;
  late TextEditingController _paisController;
  late TextEditingController _provinciaController;
  late TextEditingController _posicionController;
  late TextEditingController _categoriaController;
  late TextEditingController _logrosIndividualesController;
  late TextEditingController _alturaController;
  late TextEditingController _pieDominanteController;
  late TextEditingController _seleccionNacionalController;
  late TextEditingController _dniController;
  late TextEditingController _clubController;
  late TextEditingController _categoriaSeleccionController;
  late TextEditingController _directionController;
  late PlayerProvider provider;
  late PlayerFullModel player;
  final picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  Color _appBarColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = Provider.of<PlayerProvider>(context, listen: true);
    player = provider.getPlayer()!;
    _nombreController = TextEditingController(text: player.name);
    _apellidoController = TextEditingController(text: player.lastName);
    _correoController = TextEditingController(text: player.email);
    _paisController = TextEditingController(text: countries[player.pais] ?? '');
    _provinciaController = TextEditingController(
        text: provincesByCountry[player.pais]?[player.provincia] ?? '');
    _posicionController =
        TextEditingController(text: posiciones[player.position] ?? '');
    _categoriaController =
        TextEditingController(text: categorias[player.categoria] ?? '');
    _logrosIndividualesController =
        TextEditingController(text: player.logrosIndividuales);
    _alturaController = TextEditingController(text: player.altura);
    _pieDominanteController =
        TextEditingController(text: piesDominantes[player.pieDominante] ?? '');
    _seleccionNacionalController = TextEditingController(
        text: selecciones[player.seleccionNacional] ?? '');
    _categoriaSeleccionController = TextEditingController(
        text: nationalCategories[player.seleccionNacional]
                ?[player.categoriaSeleccion] ??
            '');
    _dniController = TextEditingController(text: player.dni);
    _clubController = TextEditingController(text: player.club);
    _directionController = TextEditingController(text: player.direccion);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _paisController.dispose();
    _provinciaController.dispose();
    _posicionController.dispose();
    _categoriaController.dispose();
    _logrosIndividualesController.dispose();
    _alturaController.dispose();
    _pieDominanteController.dispose();
    _seleccionNacionalController.dispose();
    _categoriaSeleccionController.dispose();
    _dniController.dispose();
    _clubController.dispose();
    _directionController.dispose();
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final agenteProvider = Provider.of<PlayerProvider>(context, listen: false);
    final usuario = userProvider.getCurrentUser();
    const url = '${ApiConstants.baseUrl}/auth/upload-player-image';
    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.files
        .add(await http.MultipartFile.fromPath('imagen', imageFile.path));
    request.fields["userId"] = usuario.userId.toString();
    request.fields["isAgent"] = "false";
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      final image = jsonDecode(responseBody)["image"];
      agenteProvider.updateLocalImage(image);
      userProvider.updateLocalImage(image);
    } else {
      debugPrint('Failed to upload image. Error code: ${response.statusCode}');
    }
  }

  Future<void> validateFields() async {
    if (_nombreController.text.isEmpty ||
        _apellidoController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _paisController.text.isEmpty ||
        _provinciaController.text.isEmpty ||
        _posicionController.text.isEmpty ||
        _categoriaController.text.isEmpty ||
        _logrosIndividualesController.text.isEmpty ||
        _alturaController.text.isEmpty ||
        _pieDominanteController.text.isEmpty ||
        _seleccionNacionalController.text.isEmpty ||
        _clubController.text.isEmpty ||
        _categoriaSeleccionController.text.isEmpty ||
        _directionController.text.isEmpty) {
      return showErrorSnackBar(
          context, translations!['completAllFieldEditProfile']);
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final response = await ApiClient().post('auth/player-check',
        {"userId": userProvider.getCurrentUser().userId.toString()});
    if (response.statusCode == 200) {
      Navigator.of(context).pushReplacementNamed('/config-player');
    } else {
      showErrorSnackBar(context, translations!['error_try_again']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    final user = userProvider.getCurrentUser();
    return WillPopScope(
      onWillPop: () async {
        validateFields();

        return false;
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF444444), Color(0xFF000000)],
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: appBarTitle(translations!["EDIT_INFORMATION"]),
            backgroundColor: _appBarColor,
            elevation: 0,
            leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF00E050),
                  size: 32,
                ),
                onPressed: () {
                  validateFields();
                }),
          ),
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _openGallery,
                  child: Stack(
                    children: [
                      ClipOval(
                        child: user.imageUrl != ''
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
                                  imageUrl: user.imageUrl,
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
                _buildTextField(
                    label: translations!["Name"],
                    controller: _nombreController,
                    camp: 'name'),
                _buildTextField(
                    label: translations!["Last_name"],
                    controller: _apellidoController,
                    camp: 'lastname'),
                _buildTextField(
                    label: translations!["Email"],
                    controller: _correoController,
                    camp: 'email'),
                _buildTextField(
                    label: translations!["Direction"],
                    controller: _directionController,
                    camp: 'direccion'),
                // _buildTextField(
                //     label: 'DOCUMENTO DE IDENTIDAD',
                //     controller: _dniController,
                //     camp: 'dni'),
                _buildTextField(
                    label: translations!["Country"],
                    controller: _paisController,
                    camp: 'pais',
                    select: true,
                    items: countries),
                _buildTextField(
                  label: translations!["Province"],
                  controller: _provinciaController,
                  camp: 'provincia',
                  select: true,
                  items: provincesByCountry[player.pais ?? 'spain'],
                ),
                _buildTextField(
                    label: translations!["Position"],
                    controller: _posicionController,
                    camp: 'position',
                    goToSelCamp: true),
                _buildTextField(
                    label: translations!["Club"],
                    controller: _clubController,
                    camp: 'club'),
                _buildTextField(
                    label: translations!["Category"],
                    controller: _categoriaController,
                    camp: 'categoria',
                    select: true,
                    items: categorias),
                _buildTextField(
                    label: translations!["Achievements"],
                    controller: _logrosIndividualesController,
                    camp: 'logros'),
                _buildTextField(
                  label: translations!["height_label2"],
                  controller: _alturaController,
                  camp: 'altura',
                  select: true,
                  items: alturas,
                ),
                _buildTextField(
                  label: translations!["Dominate_foot"],
                  controller: _pieDominanteController,
                  camp: 'piedominante',
                  select: true,
                  items: piesDominantes,
                ),
                _buildTextField(
                  label: translations!["Selection"],
                  controller: _seleccionNacionalController,
                  camp: 'seleccion',
                  select: true,
                  items: selecciones,
                ),
                _buildTextField(
                  label: translations!["Selection_category"],
                  controller: _categoriaSeleccionController,
                  camp: 'categoriaseleccion',
                  select: true,
                  items: nationalCategories[player.seleccionNacional ?? 'male'],
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String camp,
    bool? goToSelCamp,
    bool select = false,
    Map<String, String> items = const {},
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              controller.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF00E050)),
            onPressed: () {
              if (goToSelCamp ?? false) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) =>
                        const SelectCamp(registrando: false)));
              } else {
                _editarCampo(
                  context,
                  label,
                  controller,
                  camp,
                  select: select,
                  items: items,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _editarCampo(
    BuildContext context,
    String label,
    TextEditingController controller,
    String camp, {
    bool select = false,
    Map<String, String> items = const {},
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (BuildContext context) {
        TextEditingController editingController =
            TextEditingController(text: controller.text);

        return Dialog(
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                padding: const EdgeInsets.all(15),
                height: 170,
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
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Color(0xff00E050),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (!select) iField(editingController, ''),
                    if (select)
                      StatefulBuilder(
                        builder: (context, StateSetter setState) {
                          return DropdownWidget<String>(
                            offsetX: -5,
                            value: editingController.text,
                            items: items,
                            onChanged: (String? newValue) {
                              setState(() {
                                editingController.text = newValue!;
                              });
                            },
                            width: 300,
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomTextButton(
                          onTap: () => Navigator.of(context).pop(),
                          text: 'Cancelar',
                          buttonPrimary: false,
                          width: 90,
                          height: 27,
                        ),
                        CustomTextButton(
                          onTap: () async {
                            if (mounted) {
                              setState(() {
                                controller.text = editingController.text;
                              });
                            }
                            provider.updatePlayer(
                              fieldName: camp.toLowerCase(),
                              value: editingController.text,
                            );
                            final player = provider.getPlayer()!;

                            final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false);

                            userProvider.updateUserFromPlayer(player);

                            await ApiClient().post('auth/edit-player',
                                provider.getPlayer()!.toMap());
                            Navigator.of(context).pop();
                          },
                          text: 'Guardar',
                          buttonPrimary: true,
                          width: 90,
                          height: 27,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }
}
