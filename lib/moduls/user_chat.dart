// ignore_for_file: depend_on_referenced_packages, library_prefixes

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:towchat/moduls/messages_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class UserChat extends StatefulWidget {
  const UserChat({super.key});

  @override
  State<UserChat> createState() => _UserChatState();
}

class _UserChatState extends State<UserChat> {
  late IO.Socket socket;
  late TextEditingController _messageController;

  List<MessagesModel> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _messageController = TextEditingController();

    initSocket();
  }

  @override
  void dispose() {
    socket.disconnect();
    _messageController.dispose();

    super.dispose();
  }

  Future<void> initSocket() async {
    debugPrint('Connecting to chat service');
    socket = IO.io('http://43.204.209.21', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
    socket.emit("join", '634aa1a081e27050142653d5');
    socket.on('send', (data) {
      _loadMessages();
    });
    socket.onConnect((_) {
      debugPrint('connected to websocket');
    });
  }

  _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.attach_file),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {},
              decoration: const InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  _buildMessage(MessagesModel message, bool isMe) {
    final container = Container(
      margin: isMe
          ? const EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
              left: 80.0,
            )
          : const EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
            ),
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
        color: isMe ? Colors.grey.shade200 : const Color(0xFFFFEFEE),
        borderRadius: isMe
            ? const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
              )
            : const BorderRadius.only(
                topRight: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Text(
          //   message.,
          //   style: TextStyle(
          //     color: Colors.grey,
          //     fontSize: 16.0,
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),
          // SizedBox(height: 8.0),
          Text(
            message.content.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (isMe) {
      return container;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text(
          "user 1",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.more_horiz),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  child: ListView.builder(
                    // reverse: true,
                    padding: const EdgeInsets.only(top: 15.0),
                    itemCount: _messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final MessagesModel message = _messages[index];
                      return _buildMessage(message, true);
                    },
                  ),
                ),
              ),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    String messageText = _messageController.text;
    _messageController.text = '';
    print(messageText);
    if (messageText != '') {
      var messagePost = {
        "roomId": "634aa1a081e27050142653d5",
        "userId": "634a9be1bf4bee51d435b6a8",
        "content": "$messageText ",
        "contentType": "TEXT"
      };
      socket.emit("send", jsonEncode(messagePost));
    }
  }

  _loadMessages() async {
    _messages = [];
    var url = Uri.parse(
        'http://13.235.33.199/get_all_messages/634aa1a081e27050142653d5');

    http.Response response = await http.get(url);

    List<MessagesModel> allMsg = [];
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      for (var msg in data['data']['data']) {
        final messagesModel = MessagesModel.fromJson(msg);
        // _messages.add(messagesModel);
        _messages.add(messagesModel);
        setState(() {});
      }

      return allMsg;
    } else {
      debugPrint('Error retrieving');
    }
  }
}
