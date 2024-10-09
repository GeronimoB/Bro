import 'dart:io' as io;
import 'package:bro_app_to/components/custom_text_button.dart';
import 'package:bro_app_to/components/snackbar.dart';
import 'package:bro_app_to/utils/current_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../providers/user_provider.dart';
import '../utils/api_constants.dart';

class VerificationReferral extends StatefulWidget {
  const VerificationReferral({super.key});

  @override
  VerificationReferralState createState() => VerificationReferralState();
}

class VerificationReferralState extends State<VerificationReferral> {
  bool showUploadFiles = false;
  final picker = ImagePicker();
  bool isLoading = false;
  Map<String, dynamic> files = {
    "dni_frontal": null,
    "dni_trasero": null,
    "documento": null,
  };
  Map<String, String> fileName = {
    "dni_frontal": "Sin archivo seleccionado.",
    "dni_trasero": "Sin archivo seleccionado.",
    "documento": "Sin archivo seleccionado.",
  };

  Future<void> _openGallery(String camp) async {
    if (io.Platform.isIOS || io.Platform.isAndroid) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          files[camp] = pickedFile.path;
          fileName[camp] = pickedFile.name;
        });
      } else {
        debugPrint('No image selected.');
      }
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        final pickedFile = result.files.single;
        setState(() {
          files[camp] = pickedFile.path!;
          fileName[camp] = pickedFile.name;
        });
      } else {
        debugPrint('No image selected.');
      }
    }
  }

  void _uploadFiles() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final usuario = userProvider.getCurrentUser();
      String userId = usuario.userId.toString();

      const url =
          '${ApiConstants.baseUrl}/auth/upload-verification-files-referrals';
      var request = http.MultipartRequest('POST', Uri.parse(url));

      for (String camp in files.keys) {
        String? filePath = files[camp];
        if (filePath != null) {
          request.files.add(await http.MultipartFile.fromPath(camp, filePath));
        } else {
          showErrorSnackBar(context, translations!['please_upload_all_files']);
          return;
        }
      }
      request.fields["userId"] = userId;
      var response = await request.send();

      if (response.statusCode == 200) {
        showSucessSnackBar(
            context, translations!['scss_upload_referals_files']);

        Navigator.of(context).pop();
      } else {
        showErrorSnackBar(context, translations!['error_try_again']);
      }
    } catch (e) {
      showErrorSnackBar(context, translations!['error_try_again']);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: Stack(
          children: [
            if (!isLoading)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    translations!['company_or_autum'],
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xff00E050),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (showUploadFiles) ...[
                    SizedBox(
                      width: double.maxFinite,
                      child: Text(
                        translations!['upload_doc'],
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                        label: translations!["036orCIFDocument"],
                        camp: 'documento'),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.maxFinite,
                      child: Text(
                        translations!['upload_dni'],
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                        label: translations!["Front_ID"], camp: 'dni_frontal'),
                    _buildTextField(
                        label: translations!["Back_ID"], camp: 'dni_trasero'),
                    const SizedBox(height: 35),
                    Center(
                      child: CustomTextButton(
                        onTap: () {
                          _uploadFiles();
                        },
                        text: translations!['send'],
                        buttonPrimary: true,
                        width: 90,
                        height: 27,
                      ),
                    ),
                  ],
                  if (!showUploadFiles) ...[
                    const SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomTextButton(
                          onTap: () => Navigator.of(context).pop(),
                          text: translations!['not'],
                          buttonPrimary: false,
                          width: 90,
                          height: 27,
                        ),
                        CustomTextButton(
                          onTap: () {
                            setState(() {
                              showUploadFiles = true;
                            });
                          },
                          text: translations!['yes'],
                          buttonPrimary: true,
                          width: 90,
                          height: 27,
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            if (isLoading)
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF05FF00)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String camp,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              height: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fileName[camp] ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                  height: 1,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF00E050),
                  size: 20,
                ),
                onPressed: () {
                  _openGallery(camp);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void showVerificationReferral(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (BuildContext context) {
      return const VerificationReferral();
    },
  );
}
