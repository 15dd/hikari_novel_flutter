import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/pages/category/controller.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../../widgets/keep_alive_wrapper.dart';
import '../../widgets/novel_cover_card.dart';
import '../../widgets/state_page.dart';

class CategoryView extends StatelessWidget {
  CategoryView({super.key});

  final controller = Get.put(CategoryController());

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
                label: Row(children: [Obx(() => Text(controller.category.value)), Icon(Icons.arrow_drop_down_outlined)]),
                onPressed: () {
                  showMenu(context: context, position: RelativeRect.fill, items: _getTagList());
                },
                padding: EdgeInsets.zero,
              ),
              SizedBox(width: 10),
              ActionChip(
                label: Row(children: [Obx(() => Text(controller.sortText.value)), Icon(Icons.arrow_drop_down_outlined)]),
                onPressed: () {
                  showMenu(context: context, position: RelativeRect.fill, items: _getSortList());
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

  List<PopupMenuItem> _getTagList() {
    return [
      PopupMenuItem(
        child: Text("school".tr),
        onTap: () {
          controller.category.value = "school".tr;
        },
      ),
      PopupMenuItem(
        child: Text("youth".tr),
        onTap: () {
          controller.category.value = "youth".tr;
        },
      ),
      PopupMenuItem(
        child: Text("love".tr),
        onTap: () {
          controller.category.value = "love".tr;
        },
      ),
      PopupMenuItem(
        child: Text("healing".tr),
        onTap: () {
          controller.category.value = "healing".tr;
        },
      ),
      PopupMenuItem(
        child: Text("group_portrait".tr),
        onTap: () {
          controller.category.value = "group_portrait".tr;
        },
      ),
      PopupMenuItem(
        child: Text("sports".tr),
        onTap: () {
          controller.category.value = "sports".tr;
        },
      ),
      PopupMenuItem(
        child: Text("music".tr),
        onTap: () {
          controller.category.value = "music".tr;
        },
      ),
      PopupMenuItem(
        child: Text("food".tr),
        onTap: () {
          controller.category.value = "food".tr;
        },
      ),
      PopupMenuItem(
        child: Text("travel".tr),
        onTap: () {
          controller.category.value = "travel".tr;
        },
      ),
      PopupMenuItem(
        child: Text("joy".tr),
        onTap: () {
          controller.category.value = "joy".tr;
        },
      ),
      PopupMenuItem(
        child: Text("manage".tr),
        onTap: () {
          controller.category.value = "manage".tr;
        },
      ),
      PopupMenuItem(
        child: Text("workplace".tr),
        onTap: () {
          controller.category.value = "workplace".tr;
        },
      ),
      PopupMenuItem(
        child: Text("battle_of_wits".tr),
        onTap: () {
          controller.category.value = "battle_of_wits".tr;
        },
      ),
      PopupMenuItem(
        child: Text("brain_cavity".tr),
        onTap: () {
          controller.category.value = "brain_cavity".tr;
        },
      ),
      PopupMenuItem(
        child: Text("otaku_culture".tr),
        onTap: () {
          controller.category.value = "otaku_culture".tr;
        },
      ),
      PopupMenuItem(
        child: Text("pass_through".tr),
        onTap: () {
          controller.category.value = "pass_through".tr;
        },
      ),
      PopupMenuItem(
        child: Text("fantasy".tr),
        onTap: () {
          controller.category.value = "fantasy".tr;
        },
      ),
      PopupMenuItem(
        child: Text("magic".tr),
        onTap: () {
          controller.category.value = "magic".tr;
        },
      ),
      PopupMenuItem(
        child: Text("supernatural_ability".tr),
        onTap: () {
          controller.category.value = "supernatural_ability".tr;
        },
      ),
      PopupMenuItem(
        child: Text("fighting".tr),
        onTap: () {
          controller.category.value = "fighting".tr;
        },
      ),
      PopupMenuItem(
        child: Text("science_fiction".tr),
        onTap: () {
          controller.category.value = "science_fiction".tr;
        },
      ),
      PopupMenuItem(
        child: Text("machine_warfare".tr),
        onTap: () {
          controller.category.value = "machine_warfare".tr;
        },
      ),
      PopupMenuItem(
        child: Text("warfare".tr),
        onTap: () {
          controller.category.value = "warfare".tr;
        },
      ),
      PopupMenuItem(
        child: Text("adventure".tr),
        onTap: () {
          controller.category.value = "adventure".tr;
        },
      ),
      PopupMenuItem(
        child: Text("dragon_proud_sky".tr),
        onTap: () {
          controller.category.value = "dragon_proud_sky".tr;
        },
      ),
      PopupMenuItem(
        child: Text("suspense".tr),
        onTap: () {
          controller.category.value = "suspense".tr;
        },
      ),
      PopupMenuItem(
        child: Text("crime".tr),
        onTap: () {
          controller.category.value = "crime".tr;
        },
      ),
      PopupMenuItem(
        child: Text("revenge".tr),
        onTap: () {
          controller.category.value = "revenge".tr;
        },
      ),
      PopupMenuItem(
        child: Text("darkness".tr),
        onTap: () {
          controller.category.value = "darkness".tr;
        },
      ),
      PopupMenuItem(
        child: Text("hunting_for_novelty".tr),
        onTap: () {
          controller.category.value = "hunting_for_novelty".tr;
        },
      ),
      PopupMenuItem(
        child: Text("thrilling".tr),
        onTap: () {
          controller.category.value = "thrilling".tr;
        },
      ),
      PopupMenuItem(
        child: Text("spy".tr),
        onTap: () {
          controller.category.value = "spy".tr;
        },
      ),
      PopupMenuItem(
        child: Text("apocalypse".tr),
        onTap: () {
          controller.category.value = "apocalypse".tr;
        },
      ),
      PopupMenuItem(
        child: Text("game".tr),
        onTap: () {
          controller.category.value = "game".tr;
        },
      ),
      PopupMenuItem(
        child: Text("battle_royale_game".tr),
        onTap: () {
          controller.category.value = "battle_royale_game".tr;
        },
      ),
      PopupMenuItem(
        child: Text("childhood_sweetheart".tr),
        onTap: () {
          controller.category.value = "childhood_sweetheart".tr;
        },
      ),
      PopupMenuItem(
        child: Text("younger_sisiter".tr),
        onTap: () {
          controller.category.value = "younger_sisiter".tr;
        },
      ),
      PopupMenuItem(
        child: Text("daughter".tr),
        onTap: () {
          controller.category.value = "daughter".tr;
        },
      ),
      PopupMenuItem(
        child: const Text("JK"),
        onTap: () {
          controller.category.value = "JK".tr;
        },
      ),
      PopupMenuItem(
        child: const Text("JC"),
        onTap: () {
          controller.category.value = "JC";
        },
      ),
      PopupMenuItem(
        child: Text("princess".tr),
        onTap: () {
          controller.category.value = "princess".tr;
        },
      ),
      PopupMenuItem(
        child: Text("sexual_conversion".tr),
        onTap: () {
          controller.category.value = "sexual_conversion".tr;
        },
      ),
      PopupMenuItem(
        child: Text("cross_dressing".tr),
        onTap: () {
          controller.category.value = "cross_dressing".tr;
        },
      ),
      PopupMenuItem(
        child: Text("extra_human".tr),
        onTap: () {
          controller.category.value = "extra_human".tr;
        },
      ),
      PopupMenuItem(
        child: Text("harem".tr),
        onTap: () {
          controller.category.value = "harem".tr;
        },
      ),
      PopupMenuItem(
        child: Text("lily".tr),
        onTap: () {
          controller.category.value = "lily".tr;
        },
      ),
      PopupMenuItem(
        child: Text("danmei".tr),
        onTap: () {
          controller.category.value = "danmei".tr;
        },
      ),
      PopupMenuItem(
        child: Text("ntr".tr),
        onTap: () {
          controller.category.value = "ntr".tr;
        },
      ),
      PopupMenuItem(
        child: Text("female_perspective".tr),
        onTap: () {
          controller.category.value = "female_perspective".tr;
        },
      ),
    ];
  }

  List<PopupMenuItem> _getSortList() {
    return [
      PopupMenuItem(
        child: Text("sort_by_update".tr),
        onTap: () {
          controller.sortValue = "0";
          controller.sortText.value = "sort_by_update".tr;
        },
      ),
      PopupMenuItem(
        child: Text("sort_by_heat".tr),
        onTap: () {
          controller.sortValue = "1";
          controller.sortText.value = "sort_by_heat".tr;
        },
      ),
      PopupMenuItem(
        child: Text("sort_by_completion".tr),
        onTap: () {
          controller.sortValue = "2";
          controller.sortText.value = "sort_by_completion".tr;
        },
      ),
      PopupMenuItem(
        child: Text("sort_by_animated".tr),
        onTap: () {
          controller.sortValue = "3";
          controller.sortText.value = "sort_by_animated".tr;
        },
      ),
    ];
  }
}
