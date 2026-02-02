import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/widgets/state_page.dart';

import '../models/page_state.dart';
import '../models/resource.dart';
import '../network/parser.dart';

abstract class BaseListPageController<T> extends GetxController {
  /// ###### 页面初始状态
  abstract Rx<PageState> pageState;
  String errorMsg = "";

  int _maxNum = 1;
  int _index = 0;
  final RxList<T> data = RxList();

  @override
  void onReady() {
    super.onReady();
    getPage(false);
  }

  Future<Resource> getData(int index);

  List<T> getParser(String html);

  Future<IndicatorResult> getPage(bool loadMore) async {
    try {
      if (!loadMore) {
        pageState.value = PageState.loading;
        data.clear();
        _index = 0;
      }
      if (_index >= _maxNum) return IndicatorResult.noMore;

      _index += 1;
      final result = await getData(_index);

      switch (result) {
        case Success():
          {
            // 站点页面结构偶尔会变；解析失败时不要直接崩溃（release 下会白屏）
            if (!loadMore) _maxNum = Parser.getMaxNum(result.data);
            data.addAll(getParser(result.data));

            pageState.value = PageState.success;
            return IndicatorResult.success;
          }
        case Error():
          {
            if (!loadMore) {
              pageState.value = PageState.error;
              errorMsg = result.error;
            } else {
              showErrorDialog(result.error.toString(), [TextButton(onPressed: Get.back, child: Text("confirm".tr))]);
            }
            if (_index > 0) {
              _index -= 1;
            }
            return IndicatorResult.fail;
          }
      }
    } catch (e) {
      // 兜底：网络/解析/空指针等异常都落到错误页，避免白屏
      if (!loadMore) {
        pageState.value = PageState.error;
        errorMsg = e.toString();
      } else {
        showErrorDialog(e.toString(), [TextButton(onPressed: Get.back, child: Text("confirm".tr))]);
      }
      if (_index > 0) {
        _index -= 1;
      }
      return IndicatorResult.fail;
    }
  }
}
