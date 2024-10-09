import 'package:bro_app_to/Screens/chat_page.dart';
import 'package:bro_app_to/components/chat_avatar.dart';
import 'package:bro_app_to/utils/chat_preview.dart';
import 'package:bro_app_to/utils/current_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../components/app_bar_title.dart';
import '../infrastructure/firebase_message_repository.dart';
import '../providers/user_provider.dart';

class MensajesPage extends StatelessWidget {
  MensajesPage({super.key});
  final FirebaseMessageRepository messageRepository =
      FirebaseMessageRepository();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.getCurrentUser();

    return Container(
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
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: appBarTitle(translations!["MESSAGE"]),
        ),
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            StreamBuilder<List<ChatPreview>>(
              stream: messageRepository.streamLastMessagesWithUsers(
                  user.userId, user.isAgent, context),
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
                      child:
                          Text('${translations!["error"]}: ${snapshot.error}'),
                    ),
                  );
                } else {
                  final messagesWithUsers = snapshot.data ?? [];

                  if (messagesWithUsers.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          translations!["noMessages"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 22.0,
                          ),
                        ),
                      ),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      itemCount: messagesWithUsers.length,
                      itemBuilder: (context, index) {
                        final chat = messagesWithUsers[index];

                        return GestureDetector(
                          onTap: () async {
                            final userParsedId = user.isAgent
                                ? "agente_${user.userId}"
                                : "jugador_${user.userId}";
                            final friendParsedId = chat.friendUser.isAgent
                                ? "agente_${chat.friendUser.userId}"
                                : "jugador_${chat.friendUser.userId}";
                            await FirebaseMessageRepository()
                                .markAllMessagesAsRead(
                              userParsedId,
                              friendParsedId,
                            );

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  friend: chat.friendUser,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                            child: ChatWidget(
                              key: ValueKey(index),
                              chat: chat,
                              onDelete: () {},
                              first: index == 0,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class ChatWidget extends StatefulWidget {
  final ChatPreview chat;
  final VoidCallback onDelete;
  final bool first;
  const ChatWidget(
      {Key? key,
      required this.chat,
      required this.onDelete,
      required this.first})
      : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget>
    with SingleTickerProviderStateMixin {
  late final controller = SlidableController(this);
  Color backgroundColor = Colors.transparent;
  @override
  void initState() {
    super.initState();
    controller.animation.addListener(() {
      setState(() {
        final currentRatio = controller.animation.value;
        if (currentRatio > 0) {
          backgroundColor = Colors.grey;
        } else {
          backgroundColor = Colors.transparent;
        }
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String fullName =
        '${widget.chat.friendUser.name} ${widget.chat.friendUser.lastName}';
    String trimmedName =
        fullName.length > 16 ? fullName.substring(0, 16) + '...' : fullName;

    return Slidable(
      key: widget.key!,
      controller: controller,
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        dismissible: DismissiblePane(onDismissed: _deleteMessage),
        children: [
          SlidableAction(
            autoClose: false,
            flex: 1,
            onPressed: (contexto) {
              final controller2 = Slidable.of(contexto);

              controller2!.dismiss(
                ResizeRequest(
                  const Duration(milliseconds: 300),
                  () {
                    _deleteMessage();
                  },
                ),
                duration: const Duration(milliseconds: 300),
              );
            },
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xff05FF00),
            icon: Icons.close,
            label: null,
            spacing: 8,
          ),
        ],
      ),
      child: Container(
        height: 101,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.center,
            end: Alignment.centerRight,
            colors: [
              Color.fromARGB(255, 62, 62, 62),
              Color.fromARGB(0, 44, 44, 44),
            ],
          ),
          color: backgroundColor,
          border: Border(
            top: widget.first
                ? const BorderSide(
                    color: Color.fromARGB(255, 62, 174, 100), width: 2)
                : BorderSide.none,
            bottom: const BorderSide(
                color: Color.fromARGB(255, 62, 174, 100), width: 2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const SizedBox(width: 16.0),
              chatAvatar(widget.chat.count, widget.chat.friendUser.imageUrl),
              const SizedBox(width: 18.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          trimmedName,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        if (widget.chat.friendUser.verificado)
                          const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 16,
                          ),
                      ],
                    ),
                    Text(
                      widget.chat.message,
                      style: const TextStyle(
                          fontSize: 12.0,
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: widget.chat.isMuted || widget.chat.isPinned
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: [
                  if (widget.chat.isMuted || widget.chat.isPinned)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.chat.isMuted)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.notifications_off,
                              color: Color.fromARGB(255, 204, 203, 203),
                              size: 24,
                            ),
                          ),
                        if (widget.chat.isPinned)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.push_pin,
                              color: Color.fromARGB(255, 204, 203, 203),
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.chat.time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color.fromARGB(255, 204, 203, 203),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteMessage() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.getCurrentUser();
      final sender =
          user.isAgent ? "agente_${user.userId}" : "jugador_${user.userId}";
      final friend = widget.chat.friendUser;
      final receiver = friend.isAgent
          ? "agente_${friend.userId}"
          : "jugador_${friend.userId}";
      await FirebaseMessageRepository().deleteAllMessages(sender, receiver);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
