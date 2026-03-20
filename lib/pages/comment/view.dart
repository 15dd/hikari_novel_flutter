import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/pages/comment/controller.dart';
import 'package:hikari_novel_flutter/pages/comment/widgets/comment_card.dart';

import '../../widgets/state_page.dart';

class CommentPage extends StatelessWidget {
  final String aid;

  late final CommentController controller;

  CommentPage({super.key, required this.aid}) {
    controller = Get.put(CommentController(aid: aid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("comment".tr), titleSpacing: 0),
      body: Stack(
        children: [
          Obx(
            () => Offstage(
              offstage: controller.pageState.value != PageState.success,
              child: NotificationListener<UserScrollNotification>(
                onNotification: (UserScrollNotification notification) {
                  final direction = notification.direction;
                  if (direction == ScrollDirection.forward) {
                    controller.showFab();
                  } else if (direction == ScrollDirection.reverse) {
                    controller.hideFab();
                  }
                  return false;
                },
                child: EasyRefresh(
                  onRefresh: () => controller.getPage(false),
                  onLoad: () => controller.getPage(true),
                  child: ListView(
                    children: controller.data.map((item) {
                      return CommentCard(aid: aid, item: item);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.loading, child: LoadingPage())),
          Obx(
            () => Offstage(
              offstage: controller.pageState.value != PageState.error,
              child: ErrorMessage(msg: controller.errorMsg, action: () => controller.getPage(false)),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => Offstage(
          offstage: controller.pageState.value != PageState.success,
          child: SlideTransition(
            position: controller.animation,
            child: FloatingActionButton(
              child: Icon(Icons.comment_outlined),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: Text("send_comment".tr),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: controller.commentTitleController,
                          decoration: InputDecoration(labelText: "theme".tr, border: OutlineInputBorder()),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: controller.commentContentController,
                          decoration: InputDecoration(labelText: "content".tr, border: OutlineInputBorder()),
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: Get.back, child: Text("cancel".tr)),
                      TextButton(
                        onPressed: () async {
                          showSnackBar(message: await controller.sendComment(), context: Get.context!);
                          Get.back();
                        },
                        child: Text("send".tr),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
