import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/pages/recommend/controller.dart';
import 'package:hikari_novel_flutter/pages/recommend/widgets/recommend_block_view.dart';
import 'package:hikari_novel_flutter/widgets/keep_alive_wrapper.dart';
import 'package:hikari_novel_flutter/widgets/state_page.dart';

class RecommendView extends StatelessWidget {
  RecommendView({super.key});

  final controller = Get.put(RecommendController());

  @override
  Widget build(BuildContext context) {
    return KeepAliveWrapper(
      child: Stack(
        children: [
          Obx(
            () => Offstage(
              offstage: controller.pageState.value != PageState.success,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: EasyRefresh(
                  onRefresh: controller.getRecommend,
                  child: ListView(
                    children:
                        controller.data.map((item) {
                          return RecommendBlockView(block: item);
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
              child: ErrorMessage(msg: controller.errorMsg, action: controller.getRecommend),
            ),
          ),
        ],
      ),
    );
  }
}
