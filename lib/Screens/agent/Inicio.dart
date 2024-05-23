import 'dart:convert';

import 'package:bro_app_to/Screens/agent/match_profile.dart';
import 'package:bro_app_to/components/i_field.dart';
import 'package:bro_app_to/providers/user_provider.dart';
import 'package:bro_app_to/utils/api_client.dart';
import 'package:bro_app_to/utils/initial_video_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../components/custom_dropdown.dart';
import '../../components/slidedable_video.dart';
import '../../components/user_filter_result.dart';
import '../../utils/current_state.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  InicioPageState createState() => InicioPageState();
}

class InicioPageState extends State<InicioPage> {
  double _xOffset = 0.0;
  double _rotation = 0.0;
  int _currentIndex = 0;
  bool showTextField = false;
  final List<InitialVideoModel> _videosRandom = [];
  final List<UserFilter> usuarios = [];
  List<UserFilter> usuariosFiltrados = [];
  late VideoPlayerController? currentController;
  late VideoPlayerController? nextController;
  late UserProvider userProvider;
  String currentUserId = '';
  OverlayEntry? _overlayEntry;
  bool showContainerResult = false;
  late TextEditingController selectedCountry;
  late TextEditingController selectedState;
  late TextEditingController selectedHeight;
  late TextEditingController foot;
  late TextEditingController selection;
  late TextEditingController catSelection;
  late TextEditingController position;
  late TextEditingController category;
  late TextEditingController date;
  late TextEditingController player;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    currentUserId = userProvider.getCurrentUser().userId;
    selectedCountry = TextEditingController();
    selectedState = TextEditingController();
    selectedHeight = TextEditingController();
    foot = TextEditingController();
    catSelection = TextEditingController();
    selection = TextEditingController();
    position = TextEditingController();
    category = TextEditingController();
    date = TextEditingController();
    player = TextEditingController();
    _fetchVideoUrls();
  }

  Future<void> _fetchVideoUrls() async {
    setState(() {
      isLoading = true;
    });
    try {
      final filters = jsonEncode({
        "pais": selectedCountry.text,
        "provincia": selectedState.text,
        "altura": selectedHeight.text,
        "pie_dominante": foot.text,
        "categoria_seleccion": catSelection.text,
        "seleccion_nacional": selection.text,
        "posicion_jugador": position.text,
        "categoria": category.text,
        "fecha": date.text
      });
      final response = await ApiClient().post(
          'auth/random-videos', {"userId": currentUserId, "filters": filters});

      final videos = jsonDecode(response.body)["video"];
      List<InitialVideoModel> videosMapeados = mapListToInitialVideos(videos);
      setState(() {
        _videosRandom.clear();
        _videosRandom.addAll(videosMapeados);
        usuarios.clear();
        usuarios.addAll(listFilterUserFromVideos(videosMapeados));
      });

      if (videosMapeados.isNotEmpty) {
        _initializeVideoPlayer(_currentIndex);
        _initializeNextVideoPlayer(_currentIndex + 1);
      }
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      throw Exception('Error al obtener las URLs de los videos ${error}');
    }
  }

  void filterUsers(String name) {
    print("nombre a filtrar: $name");
    usuariosFiltrados.clear();
    final users = usuarios
        .where((user) => user.user.toLowerCase().contains(name.toLowerCase()))
        .toList();
    setState(() {
      usuariosFiltrados.addAll(users);
    });
    print("len ${usuariosFiltrados.length}");
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _xOffset += details.primaryDelta!;
      _rotation = -_xOffset / 2000;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) async {
    if (_xOffset > 100) {
      matchFunction();
    } else if (_xOffset < -100) {
      rejectFunction();
    }
    setState(() {
      _xOffset = 0;
      _rotation = 0;
    });
  }

  void _initializeVideoPlayer(int index) {
    Uri url = Uri.parse(_videosRandom[index].url);
    currentController = VideoPlayerController.networkUrl(url)
      ..initialize().then((_) {
        setState(() {});
        currentController!.setLooping(true);
        currentController!.play();
      });
  }

  void _initializeNextVideoPlayer(int index) {
    if (_videosRandom.isNotEmpty) {
      Uri nextUrl = Uri.parse(_videosRandom[index].url);
      print(nextUrl);
      nextController = VideoPlayerController.networkUrl(nextUrl)
        ..initialize().then((_) {
          nextController!.setLooping(true);
        });
    }
  }

  @override
  void dispose() {
    currentController?.dispose();
    nextController?.dispose();
    selectedCountry.dispose();
    selectedState.dispose();
    selectedHeight.dispose();
    catSelection.dispose();
    selection.dispose();
    foot.dispose();
    position.dispose();
    category.dispose();
    date.dispose();
    player.dispose();
    super.dispose();
  }

  void _writeRejectionData(int userId, String currentUserId) async {
    FirebaseFirestore.instance
        .collection('Rejects')
        .doc('agente-$currentUserId')
        .collection('AgentRejects')
        .doc('jugador-$userId')
        .set({});
  }

  void _showCustomMenu(BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry = createOverlayEntry(context);
    Overlay.of(context).insert(_overlayEntry!);
  }

  void matchFunction() {
    final userId = _videosRandom[_currentIndex].userId;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MatchProfile(userId: userId)),
    );
  }

  void rejectFunction() {
    //_writeRejectionData(userId, currentUserId);
    currentController!.dispose();
    currentController = nextController;
    _currentIndex = (_currentIndex + 1) % _videosRandom.length;
    _initializeNextVideoPlayer((_currentIndex + 1) % _videosRandom.length);
    print("cindex $_currentIndex");
    currentController!.play();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double scale = 1;
    double height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: height * 0.92,
            child: GestureDetector(
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  isLoading
                      ? loadingWidget()
                      : _videosRandom.isEmpty
                          ? emptyWidget()
                          : Positioned.fill(
                              child: Transform.scale(
                                scale: scale,
                                child: Transform.rotate(
                                  angle: _rotation,
                                  child: Transform.translate(
                                    offset: Offset(_xOffset, 0),
                                    child: SlidableVideo(
                                        controller: currentController!),
                                  ),
                                ),
                              ),
                            ),
                  if (_videosRandom.isNotEmpty)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        width: MediaQuery.of(context).size.width - 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _videosRandom[_currentIndex].user,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24.0,
                                    height: 1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                if (!_videosRandom[_currentIndex].verificado)
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                              ],
                            ),
                            if (_videosRandom[_currentIndex]
                                .description
                                .isNotEmpty) ...[
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                _videosRandom[_currentIndex].description,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  height: 1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                    onTap: () => rejectFunction(),
                                    child: SvgPicture.asset(
                                      'assets/icons/circle-x.svg',
                                      height: 45,
                                      width: 45,
                                      color: const Color(0xFF00E050),
                                      fit: BoxFit.cover,
                                    )),
                                const SizedBox(
                                  width: 20,
                                ),
                                GestureDetector(
                                  onTap: () => matchFunction(),
                                  child: SvgPicture.asset(
                                    'assets/icons/heart.svg',
                                    height: 45,
                                    width: 45,
                                    color: const Color(0xFF00E050),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: showTextField
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (showTextField) {
                                  showContainerResult = false;
                                  player.clear();
                                }

                                showTextField = !showTextField;
                              });
                            },
                            child: Icon(
                              showTextField
                                  ? Icons.close
                                  : Icons.search_outlined,
                              size: 44,
                              color: const Color(0xFF00E050),
                            ),
                          ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: showTextField
                                  ? Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                56, 1, 1, 1),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: iField(player, 'Jugador',
                                              onChanged: (value) {
                                            if (value.length >= 3) {
                                              setState(() {
                                                showContainerResult = true;
                                              });
                                              filterUsers(value);
                                            }
                                          }),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        if (showContainerResult)
                                          userFilterResultWidget(
                                            context,
                                            usuariosFiltrados,
                                          ),
                                      ],
                                    )
                                  : null,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showCustomMenu(context),
                            child: SvgPicture.asset(
                              'assets/icons/filter.svg',
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              color: const Color(0xFF00E050),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_xOffset > 0)
                    Positioned(
                      top: MediaQuery.of(context).size.height / 2 - 50,
                      right: 0,
                      child: SvgPicture.asset(
                        'assets/icons/Matchicon.svg',
                        width: 200,
                        height: 200,
                      ),
                    ),
                  if (_xOffset < 0)
                    Positioned(
                      top: MediaQuery.of(context).size.height / 2 - 50,
                      left: 5,
                      child: SvgPicture.asset(
                        'assets/icons/No Match.svg',
                        width: 200,
                        height: 200,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget loadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF05FF00))),
          SizedBox(height: 20),
          Text(translations!["LoadingVideos..."]),
        ],
      ),
    );
  }

  Widget errorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              _fetchVideoUrls();
            },
            icon: const Icon(
              Icons.refresh,
              size: 48,
              color: Color(0xffffffff),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            translations!["ErrorLoadingVideos!"],
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget emptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              _fetchVideoUrls();
            },
            icon: const Icon(
              Icons.refresh,
              size: 48,
              color: Color(0xffffffff),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            translations!["EndOfVideos"],
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  OverlayEntry createOverlayEntry(BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              _overlayEntry?.remove();
              _overlayEntry = null;
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
            ),
          ),
          Positioned(
            left: offset.dx + size.width - 305,
            top: offset.dy + 105,
            width: 300,
            child: Material(
              borderRadius: BorderRadius.circular(15),
              elevation: 5.0,
              shadowColor: Colors.black.withOpacity(0.4),
              color: const Color(0xFF3B3B3B),
              child: Container(
                padding: const EdgeInsets.all(10),
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
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          cleanFilters();
                          _fetchVideoUrls();
                          _overlayEntry?.remove();
                          _overlayEntry = null;
                        }),
                        child: Text(
                          translations!['clean'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    filterTile(
                      translations!['age_label'],
                      date,
                      anos,
                    ),
                    filterTile(
                      translations!['country_label'],
                      selectedCountry,
                      countries,
                    ),
                    filterTile(
                      translations!['state_label'],
                      selectedState,
                      provincesByCountry[selectedCountry.text != ''
                          ? selectedCountry.text
                          : 'spain'],
                    ),
                    filterTile(
                      translations!['dominant_feet'],
                      foot,
                      piesDominantes,
                    ),
                    filterTile(
                      translations!['height_label'],
                      selectedHeight,
                      alturas,
                    ),
                    filterTile(
                      translations!['national_selection_short'],
                      selection,
                      selecciones,
                    ),
                    filterTile(
                      translations!['national_category'],
                      catSelection,
                      nationalCategories[
                          selection.text != '' ? selection.text : 'male'],
                    ),
                    filterTile(
                      translations!['position_label'],
                      position,
                      posiciones,
                    ),
                    filterTile(
                      translations!['category_label_short'],
                      category,
                      categorias,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void cleanFilters() {
    setState(() {
      selectedCountry.text = '';
      selectedState.text = '';
      selectedHeight.text = '';
      catSelection.text = '';
      selection.text = '';
      foot.text = '';
      position.text = '';
      category.text = '';
      date.text = '';
    });
  }

  Widget filterTile(
      String label, TextEditingController value, Map<String, String> items) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 10),
        DropdownWidget<String>(
          value: value.text,
          items: items,
          onChanged: (String? newValue) {
            setState(() {
              value.text = newValue!;
            });
            _fetchVideoUrls();
          },
          width: 125,
        ),
      ],
    );
  }
}
