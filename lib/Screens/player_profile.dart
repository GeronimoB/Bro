import 'dart:convert';

import 'package:bro_app_to/components/avatar_placeholder.dart';
import 'package:bro_app_to/providers/user_provider.dart';
import 'package:bro_app_to/src/auth/data/models/user_model.dart';
import 'package:bro_app_to/src/registration/data/models/player_full_model.dart';
import 'package:bro_app_to/utils/current_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../components/custom_box_shadow.dart';
import '../providers/player_provider.dart';
import '../utils/api_client.dart';
import '../utils/video_model.dart';
import 'player/config_profile_player.dart';
import 'player/full_screen_video_page.dart';

class PlayerProfile extends StatefulWidget {
  const PlayerProfile({super.key});

  @override
  PlayerProfileState createState() => PlayerProfileState();
}

class PlayerProfileState extends State<PlayerProfile> {
  double gridSpacing = 2.0;
  bool _isExpanded = false;
  bool _showAlert = false;
  int diasFaltantes = 3;
  int diasTranscurridos = 0;
  late PlayerProvider playerProvider;
  late PlayerFullModel player;
  late UserProvider userProvider;
  late UserModel user;
  void _closeAlert() {
    setState(() {
      _showAlert = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    player = playerProvider.getPlayer()!;
    userProvider = Provider.of<UserProvider>(context, listen: false);
    user = userProvider.getCurrentUser();

    // if (!player.emailVerified) {
    //   _showAlert = true;
    //   DateTime dateCreated = player.dateCreated ?? DateTime.now();
    //   DateTime now = DateTime.now();
    //   Duration difference = now.difference(dateCreated);
    //   int daysPassed = difference.inDays;
    //   diasTranscurridos = daysPassed;
    //   diasFaltantes -= daysPassed;
    // }
  }

  Future<List<Video>> fetchVideos() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final userId = playerProvider.getPlayer()!.userId;
    try {
      final videosResponse = await ApiClient().get('auth/videos/$userId');
      if (videosResponse.statusCode == 200) {
        final jsonData = jsonDecode(videosResponse.body);
        final videos = jsonData["videos"];
        final List<Video> sortedVideos = mapListToVideos(videos);

        //playerProvider.setUserVideos(mapListToVideos(videos));
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
        //playerProvider.setUserVideos(mapListToVideos([]));
        return [];
      }
    } catch (e) {
      debugPrint('Error en la solicitud de videos: $e');
      //playerProvider.setUserVideos(mapListToVideos([]));
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final widthVideo = MediaQuery.of(context).size.width / 3;

    DateTime? birthDate = player.birthDate;
    String formattedDate =
        birthDate != null ? DateFormat('dd-MM-yyyy').format(birthDate) : '';
    String shortInfo =
        '${provincesByCountry[player.pais][player.provincia]}, ${countries[player.pais]}\n ${translations!["birthdate"]}: $formattedDate';
    String fullInfo =
        '${provincesByCountry[player.pais][player.provincia]}, ${countries[player.pais]}\n ${translations!["birthdate"]}: $formattedDate\n ${translations!["Categorys"]}: ${categorias[player.categoria]}\n ${posiciones[translations!["position_label"]]}: ${player.position}\n ${translations!["club_label"]}: ${player.club}\n ${translations!["national_selection_short"]}: ${selecciones[player.seleccionNacional]} ${nationalCategories[player.seleccionNacional][player.categoriaSeleccion]}\n ${translations!["dominant_feet"]}: ${piesDominantes[player.pieDominante]} \n ${translations!["Achievements2"]}: ${player.logrosIndividuales}  \n ${translations!["height_label"]}: ${player.altura}';
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
        body: Stack(
          children: [
            Column(
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
                      icon:
                          const Icon(Icons.settings, color: Color(0xFF00E050)),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ConfigProfilePlayer(),
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
                          width: 95,
                          height: 95,
                        );
                      },
                      imageUrl: user.imageUrl,
                      fit: BoxFit.fill,
                      width: 95,
                      height: 95,
                    ),
                  ),
                if (user.imageUrl == '')
                  ClipOval(
                    child: Image.asset(
                      'assets/images/fot.png',
                      width: 95,
                      height: 95,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                        ? translations!["seLess"]
                        : translations!["seMore"],
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
                  margin:
                      const EdgeInsets.symmetric(vertical: 0.0, horizontal: 15),
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF05FF00)),
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
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  translations!["noVideos"],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                  textAlign: TextAlign.center,
                                ),
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
                                        builder: (context) =>
                                            FullScreenVideoPage(
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
                                        errorWidget:
                                            (context, error, stackTrace) {
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
            if (_showAlert)
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xff3B3B3B),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${translations!["Have"]} $diasFaltantes ${translations!["DaysToConfirmYourEmail"]}", // Texto del aviso
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            iconSize: 32,
                            color: const Color(0xFF00E050),
                            onPressed: _closeAlert,
                          ),
                        ],
                      ),
                      LinearProgressIndicator(
                        value: diasTranscurridos / 3,
                        backgroundColor:
                            const Color.fromARGB(255, 123, 123, 123),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF00E050)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
