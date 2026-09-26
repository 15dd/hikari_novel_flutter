import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/resource.dart';
import 'package:hikari_novel_flutter/models/user_info.dart';
import 'package:hikari_novel_flutter/parser/parser.dart';

import '../../models/page_state.dart';
import '../../service/api_service.dart';
import '../../service/local_storage_service.dart';

class UserInfoController extends GetxController {
  Rx<PageState> pageState = Rx(PageState.loading);
  String errorMsg = "";
  Rxn<UserInfo> userInfo = Rxn();

  @override
  void onReady() {
    super.onReady();

    userInfo.value = LocalStorageService.instance.getUserInfo();
    pageState.value = PageState.success;
  }

  void getPage() async {
    final data = await ApiService.instance.getUserInfo();
    switch (data) {
      case Success():
        {
          userInfo.value = Parser.getUserInfo(data.data);
          LocalStorageService.instance.setUserInfo(userInfo.value!);
          pageState.value = PageState.success;
        }
      case Error():
        {
          errorMsg = data.error;
          pageState.value = PageState.error;
        }
    }
  }
}
