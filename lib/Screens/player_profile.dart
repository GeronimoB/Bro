import 'dart:convert';

import 'package:bro_app_to/components/avatar_placeholder.dart';
import 'package:bro_app_to/providers/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../components/custom_box_shadow.dart';
import '../providers/player_provider.dart';
import '../providers/user_provider.dart';
import '../utils/api_client.dart';
import '../utils/video_model.dart';
import 'player/bottom_navigation_bar_player.dart';
import 'player/config_profile_player.dart';
import 'player/full_screen_video_page.dart';

class PlayerProfile extends StatefulWidget {
  @override
  _PlayerProfileState createState() => _PlayerProfileState();
}

class _PlayerProfileState extends State<PlayerProfile> {
  double gridSpacing = 2.0;
  bool _isExpanded = false;

  Future<List<Video>> fetchVideos() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final userId = playerProvider.getPlayer()!.userId;
    try {
      final videosResponse = await ApiClient().get('auth/videos/$userId');
      if (videosResponse.statusCode == 200) {
        final jsonData = jsonDecode(videosResponse.body);
        final videos = jsonData["videos"];
        print(videos.length);
        //playerProvider.setUserVideos(mapListToVideos(videos));
        return mapListToVideos(videos);
      } else {
        print('Error al obtener los videos: ${videosResponse.statusCode}');
        playerProvider.setUserVideos(mapListToVideos([]));
        return [];
      }
    } catch (e) {
      print('Error en la solicitud de videos: $e');
      playerProvider.setUserVideos(mapListToVideos([]));
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: true);
    final player = playerProvider.getPlayer()!;
    final widthVideo = MediaQuery.of(context).size.width / 3;
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    final user = userProvider.getCurrentUser();
    DateTime? birthDate = player.birthDate;

    String formattedDate =
        birthDate != null ? DateFormat('dd-MM-yyyy').format(birthDate) : '';
    String shortInfo =
        'Provincia, pais: ${player.provincia}, ${player.pais}\n Fecha de nacimiento: $formattedDate';
    String fullInfo =
        'Provincia, pais: ${player.provincia}, ${player.pais}\n Fecha de nacimiento: $formattedDate \nEscuela deportiva: ${player.club}\n Altura: ${player.altura} cm\n Pie Dominante: ${player.pieDominante}\n Selección: ${player.seleccionNacional} ${player.categoriaSeleccion}\n Posición: ${player.position}\n Categoria: ${player.categoria}\n Logros: ${player.logrosIndividuales}';
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
        extendBody: true,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                right: 8.0,
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Color(0xFF00E050)),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ConfigProfilePlayer(),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 15.0),
            if (user.imageUrl != '')
              ClipOval(
                child: CachedNetworkImage(
                  placeholder: (context, url) => AvatarPlaceholder(80),
                  errorWidget: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/fot.png',
                      fit: BoxFit.fill,
                      width: 80,
                      height: 80,
                    );
                  },
                  imageUrl: user.imageUrl,
                  fit: BoxFit.fill,
                  width: 80,
                  height: 80,
                ),
              ),
            if (user.imageUrl == '')
              ClipOval(
                child: Image.asset(
                  'assets/images/fot.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 15.0),
            Text(
              '${player.name} ${player.lastName}',
              style: const TextStyle(
                color: Color(0xFF00E050),
                fontSize: 22.0,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
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
            const SizedBox(
              height: 15,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 15),
              height: 4.0,
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Color(0xFF00E050),
                  boxShadow: [
                    CustomBoxShadow(color: Color(0xFF05FF00), blurRadius: 4)
                  ]),
            ),
            FutureBuilder<List<Video>>(
                future: fetchVideos(),
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
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    );
                  } else {
                    final videos = snapshot.data ?? [];

                    if (videos.isEmpty) {
                      return const Expanded(
                        child: Center(
                          child: Text(
                            "¡Aun no tienes videos, sube uno!",
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 22.0),
                          ),
                        ),
                      );
                    }
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: gridSpacing,
                            mainAxisSpacing: gridSpacing,
                            childAspectRatio: 1,
                          ),
                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            final video = videos[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenVideoPage(
                                      video: video,
                                      index: index,
                                      showOptions: true,
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  CachedNetworkImage(
                                    placeholder: (context, url) {
                                      return AspectRatio(
                                        aspectRatio: 1,
                                        child: Image.asset(
                                          'assets/images/video_placeholder.jpg',
                                          width: widthVideo,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                    errorWidget: (context, error, stackTrace) {
                                      return AspectRatio(
                                        aspectRatio: 1,
                                        child: Image.asset(
                                          'assets/images/video_placeholder.jpg',
                                          width: widthVideo,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                    imageUrl: video.imageUrl ?? "",
                                    width: widthVideo,
                                    fit: BoxFit.cover,
                                  ),
                                  if (video
                                      .isFavorite) // Mostrar estrella si el video está destacado
                                    const Positioned(
                                      top: 8.0,
                                      right: 8.0,
                                      child: Icon(
                                        Icons.star,
                                        color: Color(0xFF05FF00),
                                        size: 24.0,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}
