import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/pages/bookshelf/controller.dart';
import 'package:hikari_novel_flutter/pages/bookshelf/widgets/bookshelf_content_view.dart';
import 'package:hikari_novel_flutter/pages/bookshelf/widgets/bookshelf_search_view.dart';

import '../../common/extension.dart';
import '../../common/common_widgets.dart';
import '../../models/page_state.dart';
import '../../widgets/state_page.dart';

class BookshelfPage extends StatelessWidget {
  final controller = Get.put(BookshelfController());
  final searchTextEditController = Get.put(TextEditingController(), tag: "searchTextEditController");

  BookshelfContentController get currentTabController =>
      Get.find<BookshelfContentController>(tag: "BookshelfContentController ${controller.tabController.index}");

  BookshelfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (controller.pageState.value == PageState.bookshelfSearch) {
          controller.pageState.value = PageState.bookshelfContent;
          return;
        }
        if (controller.isSelectionMode.value) {
          currentTabController.exitSelectionMode();
          return;
        }
        Get.back();
      },
      child: Stack(
        children: [
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.bookshelfContent, child: _buildBookshelfContent(context))),
          Obx(() => Offstage(offstage: controller.pageState.value != PageState.bookshelfSearch, child: BookshelfSearchView())),
        ],
      ),
    );
  }

  Widget _buildBookshelfContent(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: _buildAppBar(context),
        body: TabBarView(
          controller: controller.tabController,
          physics: controller.isSelectionMode.value ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
          children: Iterable.generate(6, (index) => BookshelfContentView(classId: index.toString())).toList(),
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    if (controller.isSelectionMode.value) {
      return AppBar(
        automaticallyImplyLeading: false,
        leading: CloseButton(onPressed: currentTabController.exitSelectionMode),
        title: Text(currentTabController.getSelectedNovel().length.toString()),
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        titleSpacing: 0,
        actions: [
          IconButton(onPressed: currentTabController.selectAll, icon: const Icon(Icons.select_all)),
          IconButton(onPressed: currentTabController.deselect, icon: const Icon(Icons.deselect)),
        ],
      );
    }

    return AppBar(
      title: TabBar(
        tabs: controller.tabs.map((e) => Tab(text: e)).toList(),
        controller: controller.tabController,
        dividerHeight: 0,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
      ),
      titleSpacing: 0,
      actions: [
        IconButton(
          onPressed: () async {
            showSnackBar(message: "refresh_bookshelf_tip".tr, context: Get.context!);
            final string = await controller.refreshBookshelf();
            showSnackBar(message: string, context: Get.context!);
          },
          icon: const Icon(Icons.sync),
        ),
        IconButton(onPressed: () => controller.pageState.value = PageState.bookshelfSearch, icon: const Icon(Icons.search)),
      ],
    );
  }

  Widget? _buildBottomBar(BuildContext context) {
    if (controller.isSelectionMode.value && context.isLargeScreen()) return CommonWidgets.bookshelfBottomActionBar(currentTabController, controller);
    return null;
  }
}
