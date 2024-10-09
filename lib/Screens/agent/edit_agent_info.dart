import 'dart:convert';
import 'dart:io';

import 'package:bro_app_to/components/app_bar_title.dart';
import 'package:bro_app_to/components/avatar_placeholder.dart';
import 'package:bro_app_to/components/custom_text_button.dart';
import 'package:bro_app_to/providers/agent_provider.dart';
import 'package:bro_app_to/providers/user_provider.dart';
import 'package:bro_app_to/utils/agente_model.dart';
import 'package:bro_app_to/utils/current_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../utils/api_client.dart';
import '../../utils/api_constants.dart';

class EditarInfo extends StatefulWidget {
  const EditarInfo({super.key});

  @override
  EditarInfoState createState() => EditarInfoState();
}

class EditarInfoState extends State<EditarInfo> {
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _correoController;
  late TextEditingController _usuarioController;
  late TextEditingController _paisController;
  late TextEditingController _provinciaController;
  late AgenteProvider provider;
  late Agente agente;
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = Provider.of<AgenteProvider>(context, listen: true);
    agente = provider.getAgente();
    _nombreController = TextEditingController(text: agente.nombre);
    _apellidoController = TextEditingController(text: agente.apellido);
    _correoController = TextEditingController(text: agente.correo);
    _usuarioController = TextEditingController(text: agente.usuario);
    _paisController = TextEditingController(text: agente.pais);
    _provinciaController = TextEditingController(text: agente.provincia);
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
    final agenteProvider = Provider.of<AgenteProvider>(context, listen: false);
    final usuario = userProvider.getCurrentUser();
    const url = '${ApiConstants.baseUrl}/auth/upload-player-image';

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.files
        .add(await http.MultipartFile.fromPath('imagen', imageFile.path));
    request.fields["userId"] = usuario.userId.toString();
    request.fields["isAgent"] = "true";
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF212121), Color(0xFF121212)],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: appBarTitle(translations!["EDIT_INFORMATION"]),
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
        backgroundColor: _appBarColor,
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
                      child: agente.imageUrl != ''
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
                                imageUrl: agente.imageUrl ?? '',
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
                  label: translations!["username"],
                  controller: _usuarioController,
                  camp: 'username'),
              _buildTextField(
                  label: translations!["Country"],
                  controller: _paisController,
                  camp: 'pais'),
              _buildTextField(
                  label: translations!["Province"],
                  controller: _provinciaController,
                  camp: 'provincia'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      required String camp}) {
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
            onPressed: () => _editarCampo(context, label, controller, camp),
          ),
        ],
      ),
    );
  }

  void _editarCampo(
    BuildContext context,
    String label,
    TextEditingController controller,
    String camp,
  ) {
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
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Color(0xff00E050),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    TextField(
                      controller: editingController,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 5),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF00E050), width: 2),
                        ),
                      ),
                      cursorColor: Colors.white,
                    ),
                    const SizedBox(height: 20),
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
                            if (mounted) {
                              setState(() {
                                controller.text = editingController.text;
                              });
                            }
                            provider.updateAgent(
                              fieldName: camp.toLowerCase(),
                              value: editingController.text,
                            );
                            final agent = provider.getAgente();

                            final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false);

                            userProvider.updateUserFromAgent(agent);

                            await ApiClient().post('auth/edit-agent',
                                provider.getAgente().toMap());
                            Navigator.of(context).pop();
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
            ));
      },
    );
  }
}
