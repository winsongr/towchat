import 'package:flutter/material.dart';
import 'package:towchat/moduls/user_chat.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        centerTitle: false,
      ),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                title: const Text("User 1"),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const UserChat()));
                },
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () {},
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
