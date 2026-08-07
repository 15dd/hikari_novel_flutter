import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  RxInt tabIndex = 0.obs; //保存tab索引位置

  late TabController tabController;
  final List tabs = ["recommend".tr, "category".tr, "ranking".tr, "completion".tr];

  @override
  void onInit() {
    tabController = TabController(length: tabs.length, vsync: this, initialIndex: tabIndex.value);
    super.onInit();
  }
}
