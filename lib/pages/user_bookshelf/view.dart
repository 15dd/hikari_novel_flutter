import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/pages/user_bookshelf/controller.dart';
import 'package:hikari_novel_flutter/pages/user_bookshelf/widgets/user_novel_card.dart';

import '../../models/page_state.dart';
import '../../widgets/state_page.dart';

class UserBookshelfPage extends StatelessWidget {
  final String uid;

  late final UserBookshelfController controller;

  UserBookshelfPage({super.key, required this.uid}) {
    controller = Get.put(UserBookshelfController(uid: uid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("user_bookshelf".tr), titleSpacing: 0),
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
    if (controller.list.value == null) return LoadingPage();
    if (controller.list.value!.isEmpty) return EmptyPage();
    return ListView.builder(
      itemCount: controller.list.value!.length,
      itemBuilder: (context, index) => UserNovelCard(novelCover: controller.list.value![index]),
    );
  }
}
