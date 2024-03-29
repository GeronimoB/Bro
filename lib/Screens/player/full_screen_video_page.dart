import 'dart:io';

import 'package:bro_app_to/Screens/metodo_pago_screen.dart';
import 'package:bro_app_to/components/modal_decision.dart';
import 'package:bro_app_to/providers/player_provider.dart';
import 'package:bro_app_to/utils/video_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../../components/custom_text_button.dart';
import '../../utils/api_client.dart';
import 'bottom_navigation_bar_player.dart';
import 'package:path_provider/path_provider.dart';

class FullScreenVideoPage extends StatefulWidget {
  final Video video;
  final int index;

  const FullScreenVideoPage(
      {Key? key, required this.video, required this.index})
      : super(key: key);

  @override
  _FullScreenVideoPageState createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    Uri url = Uri.parse(widget.video.videoUrl ?? '');
    _controller = VideoPlayerController.networkUrl(url)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  void _handleDownload(Video video) async {
    String? videoUrl = video.videoUrl;

    if (videoUrl == null || videoUrl.isEmpty) {
      print('URL del video nula o vacía. No se puede iniciar la descarga.');
      return;
    }

    print('Iniciando descarga del video desde la URL: $videoUrl');

    final status = await Permission.storage.status;
    if (!status.isGranted) {
      print('Solicitando permiso de almacenamiento...');
      final result = await Permission.storage.request();
      if (!result.isGranted) {
        print(
            'Permiso de almacenamiento denegado. No se puede continuar con la descarga.');
        return;
      }
    }

    final directory = (await getExternalStorageDirectory())!.absolute.path;
    final savedDir = Directory(directory);
    if (!savedDir.existsSync()) {
      await savedDir.create();
    }

    // Verifica la ruta del directorio de destino
    print('Directorio de descarga: $savedDir');

    try {
      final taskId = await FlutterDownloader.enqueue(
          url: videoUrl,
          savedDir: directory,
          fileName: 'video_${video.id}.mp4',
          showNotification: true,
          openFileFromNotification: true,
          saveInPublicStorage: true);
      print('Descarga iniciada correctamente. ID de tarea: $taskId');
    } catch (error) {
      print('Error al iniciar la descarga: $error');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoHeight = MediaQuery.of(context).size.height - 100;
    return Stack(
      children: [
        GestureDetector(
          onTap: _togglePlayPause,
          child: _controller.value.isInitialized
              ? SizedBox(
                  width: double.maxFinite,
                  height: videoHeight,
                  child: VideoPlayer(_controller),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top,
          left: 8.0,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF00E050)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top,
          right: 8.0,
          child: Theme(
            data: Theme.of(context).copyWith(
              iconTheme: const IconThemeData(color: Color(0xFF00E050)),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: Color(0xFF00E050)),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              color: const Color(0xff3B3B3B),
              onSelected: (String result) {},
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  child: GestureDetector(
                    onTap: () {
                      _showConfirmationDeleteDialog(widget.video.id ?? 0);
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
                      child: Text('Borrar',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontStyle: FontStyle.italic)),
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  child: GestureDetector(
                    onTap: () {
                      _handleDestacar(
                          widget.index, widget.video, widget.video.isFavorite);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 1.0),
                      child: Text(
                          widget.video.isFavorite
                              ? 'Dejar de destacar'
                              : 'Destacar',
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontStyle: FontStyle.italic)),
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  child: GestureDetector(
                    onTap: () {
                      _handleDownload(widget.video);
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
                      child: Text(
                        'Guardar',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: MediaQuery.of(context).size.width / 2 - 52,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: SvgPicture.asset(
              'assets/icons/Logo.svg',
              fit: BoxFit.fitWidth,
              width: 104,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).size.height - videoHeight - 2,
          child: VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(vertical: 0),
            colors: const VideoProgressColors(
              playedColor: Color(0xFF00E050),
              bufferedColor: Colors.white60,
              backgroundColor: Colors.white24,
            ),
          ),
        ),
      ],
    );
  }

  void _showConfirmationDeleteDialog(int videoId) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return ModalDecition(
          text: "¿Estas seguro de borrar este video?",
          confirmCallback: () async {
            final response = await ApiClient()
                .post('auth/delete-video', {"videoId": videoId.toString()});
            await Future.delayed(const Duration(seconds: 1));
            if (response.statusCode == 200) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const CustomBottomNavigationBarPlayer(initialIndex: 4)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text(
                        'Hubo un error al borrar el video intentelo de nuevo.')),
              );
              await Future.delayed(const Duration(seconds: 2));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const CustomBottomNavigationBarPlayer(initialIndex: 4)),
              );
            }
          },
          cancelCallback: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _handleDestacar(int index, Video video, bool dDestacar) async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.setVideoAndIndex(index, video);

    if (dDestacar) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.6),
        builder: (BuildContext context) {
          return ModalDecition(
            text:
                "¿Esta seguro de dejar de destacar este video? Si desea volverlo a destacar en un futuro, deberá volver a pagar.",
            confirmCallback: () async {
              playerProvider.updateIsFavoriteById();
              await ApiClient().post('auth/update-video', {
                'videoId': video.id.toString(),
                'destacado': video.isFavorite.toString(),
              });
              playerProvider.indexProcessingVideoFavoritePayment = 0;
              playerProvider.videoProcessingFavoritePayment = null;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const CustomBottomNavigationBarPlayer(initialIndex: 4)),
              );
            },
            cancelCallback: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    } else {
      playerProvider.isSubscriptionPayment = false;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MetodoDePagoScreen(valueToPay: 0.99),
        ),
      );
    }
  }
}
