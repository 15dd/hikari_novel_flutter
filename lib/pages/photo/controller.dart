import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhotoController extends GetxController {
  final pageController = PageController();

  @override
  void onReady() {
    super.onReady();
    if (Get.arguments["gallery_mode"]) {
      pageController.jumpToPage(Get.arguments["index"]);
    }
  }
}