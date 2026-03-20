import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/pages/user_info/controller.dart';
import 'package:hikari_novel_flutter/pages/user_info/widgets/item_text.dart';

import '../../models/page_state.dart';
import '../../widgets/state_page.dart';

class UserInfoPage extends StatelessWidget {
  UserInfoPage({super.key});

  final controller = Get.put(UserInfoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("user_information".tr), titleSpacing: 0),
      body: Stack(
        children: [
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.success, child: _buildPage())),
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.loading, child: LoadingPage())),
          Obx(
            () => Offstage(
              offstage: controller.pageState.value != PageState.error,
              child: ErrorMessage(msg: controller.errorMsg, action: controller.getPage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    return controller.userInfo.value == null
        ? Container()
        : Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                ItemText(title: "UID", desc: controller.userInfo.value!.uid),
                ItemText(title: "username".tr, desc: controller.userInfo.value!.username),
                ItemText(title: "level".tr, desc: controller.userInfo.value!.userLevel),
                ItemText(title: "Email", desc: controller.userInfo.value!.email),
                ItemText(title: "register_date".tr, desc: controller.userInfo.value!.registerDate),
                ItemText(title: "contribution_point".tr, desc: controller.userInfo.value!.contribution),
                ItemText(title: "experience_point".tr, desc: controller.userInfo.value!.experience),
                ItemText(title: "current_point".tr, desc: controller.userInfo.value!.point),
                ItemText(title: "max_bookshelf_capacity".tr, desc: controller.userInfo.value!.maxBookshelfNum),
                ItemText(title: "daily_recommendation_limit".tr, desc: controller.userInfo.value!.maxRecommendNum),
              ],
            ),
          );
  }
}
