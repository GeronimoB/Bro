import 'package:bro_app_to/Screens/agent/bottom_navigation_bar.dart';
import 'package:bro_app_to/Screens/player/bottom_navigation_bar_player.dart';
import 'package:bro_app_to/components/chat_item.dart';
import 'package:bro_app_to/providers/user_provider.dart';
import 'package:bro_app_to/utils/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../infrastructure/firebase_message_repository.dart';
import '../src/auth/data/models/user_model.dart';

class ChatPage extends StatefulWidget {
  final UserModel friend;

  const ChatPage({
    super.key,
    required this.friend,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  OverlayEntry? _overlayEntry;

  String _buildSenderId() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.getCurrentUser();
    return user.isAgent ? "agente_${user.userId}" : "jugador_${user.userId}";
  }

  String _buildReceiverId() {
    final friend = widget.friend;
    return friend.isAgent
        ? "agente_${friend.userId}"
        : "jugador_${friend.userId}";
  }

  void _sendMessage() async {
    final String text = _messageController.text;
    if (text.isNotEmpty) {
      Message message = Message(
        senderId: _buildSenderId(),
        receiverId: _buildReceiverId(),
        message: text,
      );

      try {
        await FirebaseMessageRepository().sendMessage(message);
      } catch (e) {
        print(e);
      }

      setState(() {
        _messages.add(text);
        _messageController.clear();
      });
      _messageFocusNode.unfocus();
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(_buildSenderId());
    print(_buildReceiverId());
    return WillPopScope(
      onWillPop: () async {
        print("si entro aca");
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final user = userProvider.getCurrentUser();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => user.isAgent
                  ? const CustomBottomNavigationBar(initialIndex: 2)
                  : const CustomBottomNavigationBarPlayer(initialIndex: 3)),
        );

        return false;
      },
      child: Container(
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
          backgroundColor: Colors.transparent,
          extendBody: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipOval(
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/fot.png',
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/fot.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      );
                    },
                    image: widget.friend.imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  "${widget.friend.name} ${widget.friend.lastName}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Color(0xFF00E050)),
                  onPressed: () {
                    _showCustomMenu(context);
                  },
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF00E050),
              ),
              onPressed: () {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                final user = userProvider.getCurrentUser();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => user.isAgent
                          ? const CustomBottomNavigationBar(initialIndex: 2)
                          : const CustomBottomNavigationBarPlayer(
                              initialIndex: 3)),
                );
              },
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(_buildSenderId())
                        .collection('messages')
                        .doc(_buildReceiverId())
                        .collection('chats')
                        .orderBy("date", descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.docs.length < 1) {
                          return const Center(
                            child: Text("Saluda!"),
                          );
                        }
                        return ListView.builder(
                            itemCount: snapshot.data.docs.length,
                            reverse: true,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              Timestamp timestamp =
                                  snapshot.data.docs[index]['date'];
                              DateTime dateTime = timestamp.toDate();
                              if (snapshot.data.docs[index]['type'] == "text") {
                                return chatItem(
                                  snapshot.data.docs[index]['message'],
                                  dateTime,
                                  snapshot.data.docs[index]['sent'],
                                  snapshot.data.docs[index]['read'],
                                );
                              }
                            });
                      }
                      return const Center(child: CircularProgressIndicator());
                    }),
              ),
              _buildTextComposer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: const Color(0xff3EAE64), width: 1),
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                style: const TextStyle(color: Colors.white),
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Enviar un mensaje...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.photo_camera_outlined,
                  color: Color(0xff00E050), size: 26),
              onPressed: () {
                // Acciones para enviar imágenes.
              },
            ),
            IconButton(
              icon: const Icon(Icons.attach_file,
                  color: Color(0xff00E050), size: 26),
              onPressed: () {
                // Acciones para adjuntar archivos.
              },
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xff00E050), size: 26),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showCustomMenu(BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry(context);
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
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
            left: offset.dx + size.width - 230,
            top: offset.dy + 95,
            width: 220,
            child: Material(
              borderRadius: BorderRadius.circular(15),
              elevation: 5.0,
              shadowColor: Colors.black.withOpacity(
                  0.4), // Ajusta la opacidad de la sombra según sea necesario
              color: const Color(0xFF3B3B3B),
              child: Container(
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
                    ListTile(
                      title: const Text('Ver Perfil',
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        _overlayEntry?.remove();
                        _overlayEntry = null;
                      },
                    ),
                    ListTile(
                      title: const Text('Anclar arriba',
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        _overlayEntry?.remove();
                        _overlayEntry = null;
                      },
                    ),
                    ListTile(
                      title: const Text('Buscar',
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        _overlayEntry?.remove();
                        _overlayEntry = null;
                      },
                    ),
                    ListTile(
                      title: const Text('Silenciar notificaciones',
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        _overlayEntry?.remove();
                        _overlayEntry = null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
