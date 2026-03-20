import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';

import '../../models/recommend_block.dart';
import '../../models/resource.dart';
import '../../network/api.dart';
import '../../network/parser.dart';

class RecommendController extends GetxController {
  final RxList<RecommendBlock> data = RxList();

  Rx<PageState> pageState = Rx(PageState.loading);
  String errorMsg = "";

  @override
  void onReady() {
    super.onReady();
    getRecommend();
  }

  Future<IndicatorResult> getRecommend() async {
    pageState.value = PageState.loading;

    final result = await Api.getRecommend();
    switch (result) {
      case Success():
        data.clear();
        data.addAll(Parser.getRecommend(result.data));
        pageState.value = PageState.success;
        return IndicatorResult.success;
      case Error():
        errorMsg = result.error;
        pageState.value = PageState.error;
        return IndicatorResult.fail;
    }
  }
}
