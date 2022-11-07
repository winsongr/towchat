import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:towchat/moduls/messages_model.dart';

class Chat extends StatefulWidget {
  const Chat({
    Key? key,
  }) : super(key: key);

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  late TextEditingController _messageController;

  late IO.Socket socket;

  void _sendMessage() {
    String messageText = _messageController.text.trim();
    _messageController.text = '';
    print(messageText);
    if (messageText != '') {
      var messagePost = {
        "roomId": "634aa1a081e27050142653d5",
        "userId": "634a9be1bf4bee51d435b6a8",
        "content": "$messageText ",
        "contentType": "TEXT"
      };
      socket.emit("send", messagePost);
    }
  }

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    initSocket();
  }

  Future<void> initSocket() async {
    print('Connecting to chat service');
    socket = IO.io('http://43.204.209.21', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
    socket.emit("join", '634aa1a081e27050142653d5');
    socket.onConnect((_) {
      print('connected to websocket');
    });
    // socket.emit("join", {"634aa1a081e27050142653d5"});
    socket.on('newChat', (message) {
      print(message);
      setState(() {
        MessagesModel.messages.add(message);
      });
    });
    socket.on('allChats', (messages) {
      print(messages);
      setState(() {
        MessagesModel.messages.addAll(messages);
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.maybeOf(context)!.size;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: size.width * 0.60,
              child: const Text(
                'Chat',
                style: TextStyle(fontSize: 15, color: Colors.white),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 60,
            width: size.width,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              reverse: true,
              cacheExtent: 1000,
              itemCount: MessagesModel.messages.length,
              itemBuilder: (BuildContext context, int index) {
                var message = MessagesModel
                    .messages[MessagesModel.messages.length - index - 1];
                return ChatBubble(
                  clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
                  alignment: Alignment.topRight,
                  margin: const EdgeInsets.only(top: 5, bottom: 5),
                  backGroundColor: Colors.yellow[100],
                  child: Container(
                    constraints: BoxConstraints(maxWidth: size.width * 0.7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('@${message['content']}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 10)),
                        Text('${message['message']}',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16))
                      ],
                    ),
                  ),
                );
                // : ChatBubble(
                //     clipper:
                //         ChatBubbleClipper1(type: BubbleType.receiverBubble),
                //     alignment: Alignment.topLeft,
                //     margin: const EdgeInsets.only(top: 5, bottom: 5),
                //     backGroundColor: Colors.grey[100],
                //     child: Container(
                //       constraints:
                //           BoxConstraints(maxWidth: size.width * 0.7),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text('${message['sender']} @${message['time']}',
                //               style: const TextStyle(
                //                   color: Colors.grey, fontSize: 10)),
                //           Text('${message['message']}',
                //               style: const TextStyle(
                //                   color: Colors.black, fontSize: 16))
                //         ],
                //       ),
                //     ),
                //   );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 60,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: size.width * 0.80,
                    padding: const EdgeInsets.only(left: 10, right: 5),
                    child: TextField(
                      controller: _messageController,
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        hintText: "Message",
                        labelStyle:
                            TextStyle(fontSize: 15, color: Colors.black),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        disabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        counterText: '',
                      ),
                      style: const TextStyle(fontSize: 15),
                      keyboardType: TextInputType.text,
                      maxLength: 500,
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.20,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.redAccent),
                      onPressed: () {
                        _sendMessage();
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
