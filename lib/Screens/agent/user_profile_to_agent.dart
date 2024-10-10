import 'dart:convert';

import 'package:bro_app_to/Screens/player/full_screen_video_page.dart';
import 'package:bro_app_to/components/avatar_placeholder.dart';
import 'package:bro_app_to/components/custom_box_shadow.dart';
import 'package:bro_app_to/src/registration/data/models/player_full_model.dart';
import 'package:bro_app_to/utils/api_client.dart';
import 'package:bro_app_to/utils/current_state.dart';
import 'package:bro_app_to/utils/video_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlayerProfileToAgent extends StatefulWidget {
  final String userId;

  const PlayerProfileToAgent({super.key, required this.userId});

  @override
  PlayerProfileToAgentState createState() => PlayerProfileToAgentState();
}

class PlayerProfileToAgentState extends State<PlayerProfileToAgent> {
  double gridSpacing = 2.0;
  bool _isExpanded = false;
  PlayerFullModel? player;

  @override
  void initState() {
    super.initState();
    fetchPlayerInfo();
  }

  void fetchPlayerInfo() async {
    final userId = widget.userId;
    try {
      final playerResponse = await ApiClient().get('auth/player/$userId');
      if (playerResponse.statusCode == 200) {
        final jsonData = jsonDecode(playerResponse.body);
        final playerjson = jsonData["player"];
        setState(() {
          player = PlayerFullModel.fromJson(playerjson);
        });
      } else {
        debugPrint('Error al obtener los videos: ${playerResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al obtener el usuario: $e');
    }
  }

  Future<List<Video>> fetchVideos() async {
    final userId = widget.userId;
    try {
      final videosResponse = await ApiClient().get('auth/videos/$userId');
      if (videosResponse.statusCode == 200) {
        final jsonData = jsonDecode(videosResponse.body);
        final videos = jsonData["videos"];
        final List<Video> sortedVideos = mapListToVideos(videos);

        sortedVideos.sort((a, b) {
          if (a.isFavorite && !b.isFavorite) {
            return -1;
          } else if (!a.isFavorite && b.isFavorite) {
            return 1;
          } else {
            return 0;
          }
        });
        return sortedVideos;
      } else {
        debugPrint('Error al obtener los videos: ${videosResponse.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error en la solicitud de videos: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final widthVideo = MediaQuery.of(context).size.width / 3;

    DateTime? birthDate = player?.birthDate;

    String formattedDate =
        birthDate != null ? DateFormat('dd-MM-yyyy').format(birthDate) : '';
    String shortInfo =
        '${provincesByCountry[player?.pais][player?.provincia]}, ${countries[player?.pais]}\n ${translations!["birthdate"]}: $formattedDate';
    String fullInfo =
        '${provincesByCountry[player?.pais][player?.provincia]}, ${countries[player?.pais]}\n ${translations!["birthdate"]}: $formattedDate\n ${translations!["Categorys"]}: ${categorias[player?.categoria]}\n ${posiciones[translations!["position_label"]]}: ${player?.position}\n ${translations!["club_label"]}: ${player?.club}\n ${translations!["national_selection_short"]}: ${selecciones[player?.seleccionNacional]} ${nationalCategories[player?.seleccionNacional][player?.categoriaSeleccion]}\n ${translations!["dominant_feet"]}: ${piesDominantes[player?.pieDominante]} \n ${translations!["Achievements2"]}: ${player?.logrosIndividuales}  \n ${translations!["height_label"]}: ${player?.altura}';

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
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF00E050),
              size: 32,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        extendBody: true,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (player?.userImage!.isNotEmpty ?? false)
              ClipOval(
                child: CachedNetworkImage(
                  placeholder: (context, url) => AvatarPlaceholder(80),
                  errorWidget: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/fot.png',
                      fit: BoxFit.fill,
                      width: 95,
                      height: 95,
                    );
                  },
                  imageUrl: player?.userImage ?? '',
                  fit: BoxFit.fill,
                  width: 95,
                  height: 95,
                ),
              ),
            if (player?.userImage!.isEmpty ?? true)
              ClipOval(
                child: Image.asset(
                  'assets/images/fot.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${player?.name} ${player?.lastName}',
                  style: const TextStyle(
                    color: Color(0xFF00E050),
                    fontSize: 22.0,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  width: 5,
                ),
                if (player?.verificado ?? false)
                  const Icon(
                    Icons.verified,
                    color: Color(0xFF00E050),
                    size: 24,
                  ),
              ],
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
                _isExpanded
                    ? translations!['seeLess']
                    : translations!['seeMore'],
                style: const TextStyle(
                    color: Color(0xFF05FF00),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w900),
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
                      return Expanded(
                        child: Center(
                          child: Text(
                            translations!["NoVideosYet!"],
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
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenVideoPage(
                                      video: video,
                                      index: index,
                                      showOptions: false,
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
                                  if (video.isFavorite)
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
