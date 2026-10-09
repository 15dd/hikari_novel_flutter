import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/pages/bookshelf/controller.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../../../models/page_state.dart';
import '../../../router/app_sub_router.dart';
import '../../../widgets/keep_alive_wrapper.dart';
import '../../../widgets/novel_cover_card.dart';
import '../../../widgets/state_page.dart';

class BookshelfContentView extends StatelessWidget {
  final String classId;
  final BookshelfContentController controller;

  BookshelfContentView({super.key, required this.classId})
    : controller = Get.put(BookshelfContentController(classId: classId), tag: "BookshelfContentController $classId");

  @override
  Widget build(BuildContext context) {
    return KeepAliveWrapper(
      child: Stack(
        children: [
          Obx(
            () => Offstage(
              offstage: controller.pageState.value != PageState.success,
              child: Obx(
                () => controller.bookshelf.value?.list.isNotEmpty == true
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: ResponsiveGridList(
                          minItemWidth: 100,
                          horizontalGridSpacing: 4,
                          verticalGridSpacing: 4,
                          children: controller.bookshelf.value!.list.map((item) {
                            return BookshelfCoverCard(
                              bookshelfNovelInfo: item,
                              onTap: () {
                                if (controller.isSelectionMode) {
                                  controller.toggleCoverSelection(item.aid);
                                } else {
                                  AppSubRouter.toNovelDetail(aid: item.aid);
                                }
                              },
                              onLongPress: () {
                                if (!controller.isSelectionMode) {
                                  controller.enterSelectionMode();
                                  controller.toggleCoverSelection(item.aid);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      )
                    : EmptyPage(),
              ),
            ),
          ),
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.loading, child: const LoadingPage())),
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.empty, child: const EmptyPage())),
          Obx(
            () => Offstage(
              offstage: controller.pageState.value != PageState.error,
              child: ErrorMessage(
                msg: controller.loadError.value ?? "",
                action: controller.retry,
                buttonText: "refresh",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
