import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/user_info.dart';
import 'package:hikari_novel_flutter/router/route_path.dart';

import '../../service/local_storage_service.dart';

class MyController extends GetxController {
  Rxn<UserInfo> userInfo = Rxn(LocalStorageService.instance.getUserInfo());

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void logout() {
    LocalStorageService.instance.setCookie(null);
    Get.offAndToNamed(RoutePath.welcome);
  }
}
