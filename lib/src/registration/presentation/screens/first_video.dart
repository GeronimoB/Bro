import 'dart:typed_data';

import 'package:bro_app_to/components/app_bar_title.dart';
import 'package:bro_app_to/components/custom_text_button.dart';
import 'package:bro_app_to/Screens/planes_pago.dart';
import 'package:bro_app_to/utils/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../providers/player_provider.dart';
import '../../../../utils/current_state.dart';

class FirstVideoWidget extends StatefulWidget {
  const FirstVideoWidget({super.key});

  @override
  State<FirstVideoWidget> createState() => _FirstVideoWidgetState();
}

class _FirstVideoWidgetState extends State<FirstVideoWidget> {
  VideoPlayerController? _videoController;
  VideoPlayerController? _temporalVideoController;
  double _sliderValue = 0.0;
  String? videoPathToUpload;
  Uint8List? imagePathToUpload;

  @override
  void dispose() {
    _videoController?.dispose();
    _temporalVideoController?.dispose();
    super.dispose();
  }

  void showUploadDialog(String text, bool success) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23)),
              backgroundColor: const Color(0xFF3B3B3B),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                        color: success ? const Color(0xff00E050) : Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: success ? FontWeight.w400 : FontWeight.bold,
                        fontSize: success ? 20 : 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  CustomTextButton(
                      onTap: () async {
                        Navigator.of(context).pop();
                      },
                      text: translations!['ready'],
                      buttonPrimary: true,
                      width: 174,
                      height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String videoPath = file.path!;
      videoPathToUpload = videoPath;
      _temporalVideoController?.dispose();
      _temporalVideoController = VideoPlayerController.file(File(videoPath));

      await _temporalVideoController?.initialize();

      Duration duration = _temporalVideoController!.value.duration;
      if (duration.inSeconds > 120) {
        showUploadDialog(translations!['video_max_2m'], false);
        return;
      }

      if (_temporalVideoController!.value.size.height < 720 ||
          _temporalVideoController!.value.size.width < 720) {
        showUploadDialog(translations!['video_720'], false);
        return;
      }

      if (_temporalVideoController!.value.aspectRatio > 1) {
        showUploadDialog(translations!['video_vertical'], false);
        return;
      }

      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.PNG,
        maxHeight: 200,
        quality: 30,
      );
      imagePathToUpload = uint8list;
      final playerProvider =
          Provider.of<PlayerProvider>(context, listen: false);

      playerProvider.updateDataToUpload(videoPath, uint8list);
      playerProvider.isSubscriptionPayment = true;
      playerProvider.isNewSubscriptionPayment = true;
      _temporalVideoController?.dispose();
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(videoPath));
      showUploadDialog(translations!['video_scss'], true);
      await _videoController?.initialize();

      await _videoController?.play();
      Future.delayed(const Duration(seconds: 6), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PlanesPago()),
        );
      });

      _videoController?.setLooping(true);

      _videoController?.addListener(() {
        setState(() {
          _sliderValue = _videoController!.value.position.inSeconds.toDouble();
        });
      });
    }
  }

  Future<void> uploadVideoAndImage(
      String? videoPath, Uint8List? uint8list) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/auth/uploadFiles'),
    );
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

    await request.send();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 44, 44, 44),
                Color.fromARGB(255, 33, 33, 33),
                Color.fromARGB(255, 22, 22, 22),
                Color.fromARGB(255, 22, 22, 22),
                Color.fromARGB(255, 18, 18, 18),
              ],
              stops: [
                0.0,
                0.5,
                0.8,
                0.9,
                1.0
              ]),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: appBarTitle(translations!['first_video']),
            automaticallyImplyLeading: false,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox.shrink(),
              _videoController?.value.isInitialized ?? false
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          height: 500,
                          child: VideoPlayer(_videoController!),
                        ),
                        Slider(
                          activeColor: const Color(0xff3EAE64),
                          inactiveColor: const Color(0xff00F056),
                          value: _sliderValue,
                          min: 0.0,
                          max: _videoController!.value.duration.inSeconds
                              .toDouble(),
                          onChanged: (value) {
                            setState(() {
                              _sliderValue = value;
                              _videoController!
                                  .seekTo(Duration(seconds: value.toInt()));
                            });
                          },
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        GestureDetector(
                          onTap: _pickVideo,
                          child: SvgPicture.asset(
                            'assets/icons/CloudIcon.svg',
                            width: 210,
                          ),
                        ),
                        Text(
                          translations!['upload'],
                          style: const TextStyle(
                            color: Color(0xFF00E050),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w900,
                            fontSize: 15.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        SizedBox(
                          width: 300,
                          child: Text(
                            translations!['show_your_habilities'],
                            style: const TextStyle(
                              color: Color(0xFF00E050),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w900,
                              fontSize: 15.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: SvgPicture.asset(
                    width: 104,
                    'assets/icons/Logo.svg',
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
