import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:towchat/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: SizedBox(height: Get.height,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: ((context, index) {
            return ListTile(
              title: Text("User$index"),
              onTap: () {
                Get.toNamed(Routes.CHAT, arguments: {'user id': index});
              },
            );
          }),
        ),
      ),
    );
  }
}
