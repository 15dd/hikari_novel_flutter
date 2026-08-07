import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/models/browsing_history.dart';

import '../../service/db_service.dart';

class BrowsingHistoryController extends GetxController {
  Rx<PageState> pageState = Rx(PageState.loading);
  String errorMsg = "";
  RxList<BrowsingHistory> list = RxList();

  @override
  void onReady() {
    super.onReady();
    _sync();
  }

  void _sync() async {
    DBService.instance.getWatchableAllBrowsingHistory().listen((history) {
      if (history.isEmpty) {
        pageState.value = PageState.empty;
        return;
      }
      list.clear();
      list.addAll((history.map((e) => BrowsingHistory(aid: e.aid, title: e.title, img: e.img, time: e.time))));
      pageState.value = PageState.success;
    });
  }

  void deleteAllBrowsingHistory() {
    Get.dialog(
      AlertDialog(
        icon: Icon(Icons.delete_forever_outlined),
        title: Text("delete".tr),
        content: Text("delete_all_browsing_history_tip".tr),
        actions: [
          TextButton(onPressed: Get.back, child: Text("cancel".tr)),
          TextButton(
            onPressed: () {
              DBService.instance.deleteAllBrowsingHistory();
              Get.back();
            },
            child: Text("confirm".tr),
          ),
        ],
      ),
    );
  }
}
