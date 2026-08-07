import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/pages/browsing_history/widgets/browsing_history_card.dart';
import 'package:hikari_novel_flutter/router/app_sub_router.dart';
import 'package:hikari_novel_flutter/widgets/state_page.dart';

import '../../service/db_service.dart';
import 'controller.dart';

class BrowsingHistoryPage extends StatelessWidget {
  BrowsingHistoryPage({super.key});

  final controller = Get.put(BrowsingHistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("browsing_history".tr),
        titleSpacing: 0,
        actions: [
          IconButton(onPressed: controller.deleteAllBrowsingHistory, icon: Icon(Icons.delete_sweep_outlined), tooltip: "delete_all_browsing_history".tr),
        ],
      ),
      body: Stack(
        children: [
          Obx(
            () => Offstage(
              offstage: controller.pageState.value != PageState.success,
              child: ListView(
                children: controller.list.map((item) {
                  return BrowsingHistoryCard(
                    vh: item,
                    onTap: () => AppSubRouter.toNovelDetail(aid: item.aid),
                    onDelete: () => DBService.instance.deleteBrowsingHistory(item.aid),
                  );
                }).toList(),
              ),
            ),
          ),
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.loading, child: LoadingPage())),
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.empty, child: EmptyPage())),
        ],
      ),
    );
  }
}
