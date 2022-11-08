// ignore_for_file: depend_on_referenced_packages, library_prefixes

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:towchat/moduls/messages_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class UserChat extends StatefulWidget {
  const UserChat({super.key});

  @override
  State<UserChat> createState() => _UserChatState();
}

class _UserChatState extends State<UserChat> {
  late IO.Socket socket;

  final List<types.Message> _messages = [];
  final _user = const types.User(id: '634a9be1bf4bee51d435b6a8');

  @override
  void initState() {
    super.initState();
    _loadMessages();
    initSocket();
  }

  @override
  void dispose() {
    socket.disconnect();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User 1"),
      ),
      body: Chat(
        theme: const DefaultChatTheme(
          inputBackgroundColor: Colors.red,
        ),
        messages: _messages,
        onAttachmentPressed: _handleAttachmentPressed,
        onMessageTap: _handleMessageTap,
        onPreviewDataFetched: _handlePreviewDataFetched,
        onSendPressed: _handleSendPressed,
        showUserAvatars: true,
        showUserNames: true,
        user: _user,
      ),
    );
  }

  // void _addMessage(types.Message message) {
  //   setState(() {
  //     _messages.insert(0, message);
  //   });
  // }

  void _handleAttachmentPressed() {
    // showModalBottomSheet<void>(
    //   context: context,
    //   builder: (BuildContext context) => SafeArea(
    //     child: SizedBox(
    //       height: 144,
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.stretch,
    //         children: <Widget>[
    //           TextButton(
    //             onPressed: () {
    //               Navigator.pop(context);
    //               _handleImageSelection();
    //             },
    //             child: const Align(
    //               alignment: AlignmentDirectional.centerStart,
    //               child: Text('Photo'),
    //             ),
    //           ),
    //           TextButton(
    //             onPressed: () {
    //               Navigator.pop(context);
    //               _handleFileSelection();
    //             },
    //             child: const Align(
    //               alignment: AlignmentDirectional.centerStart,
    //               child: Text('File'),
    //             ),
    //           ),
    //           TextButton(
    //             onPressed: () => Navigator.pop(context),
    //             child: const Align(
    //               alignment: AlignmentDirectional.centerStart,
    //               child: Text('Cancel'),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    //   if (message is types.FileMessage) {
    //     var localPath = message.uri;

    //     if (message.uri.startsWith('http')) {
    //       try {
    //         final index =
    //             _messages.indexWhere((element) => element.id == message.id);
    //         final updatedMessage =
    //             (_messages[index] as types.FileMessage).copyWith(
    //           isLoading: true,
    //         );

    //         setState(() {
    //           _messages[index] = updatedMessage;
    //         });

    //         final client = http.Client();
    //         final request = await client.get(Uri.parse(message.uri));
    //         final bytes = request.bodyBytes;
    //         final documentsDir = (await getApplicationDocumentsDirectory()).path;
    //         localPath = '$documentsDir/${message.name}';

    //         if (!File(localPath).existsSync()) {
    //           final file = File(localPath);
    //           await file.writeAsBytes(bytes);
    //         }
    //       } finally {
    //         final index =
    //             _messages.indexWhere((element) => element.id == message.id);
    //         final updatedMessage =
    //             (_messages[index] as types.FileMessage).copyWith(
    //           isLoading: null,
    //         );

    //         setState(() {
    //           _messages[index] = updatedMessage;
    //         });
    //       }
    //     }

    //     await OpenFilex.open(localPath);
    //   }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    //   final index = _messages.indexWhere((element) => element.id == message.id);
    //   final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
    //     previewData: previewData,
    //   );

    //   setState(() {
    //     _messages[index] = updatedMessage;
    //   });
  }

  void _handleSendPressed(types.PartialText message) {
    if (message.text != '') {
      var messagePost = {
        "roomId": "634aa1a081e27050142653d5",
        "userId": "634a9be1bf4bee51d435b6a8",
        "content": "${message.text} ",
        "contentType": "TEXT"
      };
      socket.emit("send", jsonEncode(messagePost));
    }
  }

  _loadMessages() async {
    var url = Uri.parse(
        'http://13.235.33.199/get_all_messages/634aa1a081e27050142653d5');

    http.Response response = await http.get(url);

    List<MessagesModel> allMsg = [];
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      for (var msg in data['data']['data']) {
        final MessagesModel messagesModel = MessagesModel.fromJson(msg);
        final textMessage = types.TextMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: "${messagesModel.userId}",
          text: "${messagesModel.content}",
        );
        _messages.add(textMessage);
        setState(() {});
      }

      return allMsg;
    } else {
      debugPrint('Error retrieving');
    }
  }
}
