import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/pages/ranking/controller.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../../widgets/keep_alive_wrapper.dart';
import '../../widgets/novel_cover_card.dart';
import '../../widgets/state_page.dart';

class RankingView extends StatelessWidget {
  RankingView({super.key});

  final controller = Get.put(RankingController());

  @override
  Widget build(BuildContext context) {
    return KeepAliveWrapper(
      child: Column(
        children: [
          SizedBox(height: 4),
          Row(
            children: [
              SizedBox(width: 14),
              ActionChip(
                label: Row(children: [Obx(() => Text(controller.ranking.value)), Icon(Icons.arrow_drop_down_outlined)]),
                onPressed: () {
                  showMenu(context: context, position: RelativeRect.fill, items: _getRankingList());
                },
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          SizedBox(height: 4),
          Expanded(
            child: Stack(
              children: [
                Obx(
                  () => Offstage(
                    offstage: controller.pageState.value != PageState.success,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: EasyRefresh(
                        controller: controller.easyRefreshController,
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
                Obx(() => Offstage(offstage: controller.pageState.value != PageState.pleaseSelect, child: PleaseSelectPage())),
                Obx(() => Offstage(offstage: controller.pageState.value != PageState.loading, child: LoadingPage())),
                Obx(
                  () => Offstage(
                    offstage: controller.pageState.value != PageState.error,
                    child: ErrorMessage(msg: controller.errorMsg, action: () => controller.getPage(false)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuItem> _getRankingList() {
    return [
      PopupMenuItem(
        child: Text("last_update".tr),
        onTap: () {
          controller.ranking.value = "last_update".tr;
        },
      ),
      PopupMenuItem(
        child: Text("post_date".tr),
        onTap: () {
          controller.ranking.value = "post_date".tr;
        },
      ),
      PopupMenuItem(
        child: Text("all_visit".tr),
        onTap: () {
          controller.ranking.value = "all_visit".tr;
        },
      ),
      PopupMenuItem(
        child: Text("all_vote".tr),
        onTap: () {
          controller.ranking.value = "all_vote".tr;
        },
      ),
      PopupMenuItem(
        child: Text("good_num".tr),
        onTap: () {
          controller.ranking.value = "good_num".tr;
        },
      ),
      PopupMenuItem(
        child: Text("day_visit".tr),
        onTap: () {
          controller.ranking.value = "day_visit".tr;
        },
      ),
      PopupMenuItem(
        child: Text("day_vote".tr),
        onTap: () {
          controller.ranking.value = "day_vote".tr;
        },
      ),
      PopupMenuItem(
        child: Text("month_visit".tr),
        onTap: () {
          controller.ranking.value = "month_visit".tr;
        },
      ),
      PopupMenuItem(
        child: Text("month_vote".tr),
        onTap: () {
          controller.ranking.value = "month_vote".tr;
        },
      ),
      PopupMenuItem(
        child: Text("week_visit".tr),
        onTap: () {
          controller.ranking.value = "week_visit".tr;
        },
      ),
      PopupMenuItem(
        child: Text("week_vote".tr),
        onTap: () {
          controller.ranking.value = "week_vote".tr;
        },
      ),
      PopupMenuItem(
        child: Text("size".tr),
        onTap: () {
          controller.ranking.value = "size".tr;
        },
      ),
      PopupMenuItem(
        child: Text("animated".tr),
        onTap: () {
          controller.ranking.value = "animated".tr;
        },
      ),
      PopupMenuItem(
        child: Text("not_animated".tr),
        onTap: () {
          controller.ranking.value = "not_animated".tr;
        },
      ),
    ];
  }
}
