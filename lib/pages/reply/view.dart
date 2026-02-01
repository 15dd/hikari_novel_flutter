import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/pages/reply/controller.dart';
import 'package:hikari_novel_flutter/pages/reply/widgets/reply_card.dart';

import '../../models/page_state.dart';
import '../../widgets/state_page.dart';

class ReplyPage extends StatelessWidget {
  final String aid;
  final String rid;

  late final ReplyController controller;

  ReplyPage({super.key, required this.aid, required this.rid}) {
    controller = Get.put(ReplyController(aid: aid, rid: rid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("reply".tr),
        titleSpacing: 0,
        // leading: BackButton(onPressed: () => Get.back(id: AppSubRouter.subNavigatorId)),
      ),
      body: Stack(
        children: [
          Obx(
            () => Offstage(
              offstage: controller.pageState.value != PageState.success,
              child: EasyRefresh(
                onRefresh: () => controller.getPage(false),
                onLoad: () => controller.getPage(true),
                child: ListView(
                  children:
                      controller.data.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return ReplyCard(item: item, number: index);
                      }).toList(),
                ),
              ),
            ),
          ),
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.loading, child: LoadingPage())),
          Obx(
            () => Offstage(
              offstage: controller.pageState.value != PageState.error,
              child: ErrorMessage(msg: controller.errorMsg, onRetry: () async => controller.getPage(false)),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => Offstage(
          offstage: controller.pageState.value != PageState.success,
          child: FloatingActionButton(
            child: Icon(Icons.comment_outlined),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text("reply".tr),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: controller.replyContentController,
                        decoration: InputDecoration(labelText: "reply_content".tr, border: OutlineInputBorder()),
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: Get.back, child: Text("cancel".tr)),
                    TextButton(
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(await controller.sendReply())));
                        Get.back();
                      },
                      child: Text("reply".tr),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
