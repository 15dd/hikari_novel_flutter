import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/pages/bookshelf/controller.dart';
import 'package:hikari_novel_flutter/widgets/state_page.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../../../models/novel_cover.dart';
import '../../../widgets/novel_cover_card.dart';

class BookshelfSearchView extends StatelessWidget {
  BookshelfSearchView({super.key});

  final controller = Get.put(BookshelfSearchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: controller.back),
        title: SizedBox(
          height: kToolbarHeight,
          child: TextField(
            controller: controller.searchTextEditController,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: "keyword".tr,
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.searchTextEditController.clear();
                  controller.data.clear();
                  controller.pageState.value = PageState.placeholder;
                },
              ),
              border: InputBorder.none,
            ),
            onChanged: (text) {
              if (text.isEmpty) {
                controller.data.clear();
                controller.pageState.value = PageState.placeholder;
                return;
              }
              controller.getBookshelfByKeyword();
            },
          ),
        ),
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          Obx(
            () => Offstage(
              offstage: controller.pageState.value != PageState.success,
              child:
                  controller.data.isEmpty == true
                      ? Container()
                      : Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Obx(
                          () => ResponsiveGridList(
                            minItemWidth: 100,
                            horizontalGridSpacing: 4,
                            verticalGridSpacing: 4,
                            children:
                                controller.data.map((item) {
                                  return NovelCoverCard(novelCover: NovelCover(item.title, item.img, item.aid));
                                }).toList(),
                          ),
                        ),
                      ),
            ),
          ),
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.empty, child: EmptyPage())),
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.placeholder, child: Container()))
        ],
      ),
    );
  }
}
