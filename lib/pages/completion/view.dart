import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/pages/completion/controller.dart';
import 'package:hikari_novel_flutter/widgets/keep_alive_wrapper.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../../widgets/novel_cover_card.dart';
import '../../widgets/state_page.dart';

class CompletionView extends StatelessWidget {
  CompletionView({super.key});

  final controller = Get.put(CompletionController());

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
                  onRefresh: () => controller.getPage(false),
                  onLoad: () => controller.getPage(true),
                  child: ResponsiveGridList(
                    minItemWidth: 100,
                    horizontalGridSpacing: 4,
                    verticalGridSpacing: 4,
                    children:
                        controller.data.map((item) {
                          return NovelCoverCard(novelCover: item);
                        }).toList(),
                  ),
                ),
              ),
            ),
          ),
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.loading, child: LoadingPage())),
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.error, child: ErrorMessage(msg: controller.errorMsg, action:() => controller.getPage(false)))),
        ],
      ),
    );
  }
}
