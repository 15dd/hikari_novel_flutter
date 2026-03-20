import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/common/extension.dart';
import 'package:hikari_novel_flutter/pages/main/controller.dart';
import 'package:hikari_novel_flutter/pages/novel_detail/controller.dart';

import '../../common/log.dart';
import '../../common/common_widgets.dart';
import '../../router/app_pages.dart';
import '../../router/app_sub_router.dart';
import '../../router/route_path.dart';
import '../bookshelf/controller.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final controller = Get.put(MainController());

  @override
  Widget build(BuildContext context) {
    return context.isLargeScreen() ? _buildLargeScreenScaffold() : _buildSmallScreenScaffold();
  }

  Widget _buildSmallScreenScaffold() {
    return Stack(
      children: [
        Obx(
          () => Scaffold(
            body: IndexedStack(index: controller.selectedIndex.value, children: controller.pages),
            bottomNavigationBar: Obx(() {
              if (controller.showBookshelfBottomActionBar.value) {
                BookshelfController bookshelfController = Get.find();
                BookshelfContentController currentTabController = Get.find(tag: "BookshelfContentController ${bookshelfController.tabController.index}");
                return CommonWidgets.bookshelfBottomActionBar(currentTabController, bookshelfController, edgeToEdge: true);
              } else {
                return NavigationBar(
                  selectedIndex: controller.selectedIndex.value,
                  onDestinationSelected: (index) => controller.selectedIndex.value = index,
                  destinations: [
                    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: "home".tr),
                    NavigationDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: "bookshelf".tr),
                    NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: "my".tr),
                  ],
                );
              }
            }),
          ),
        ),
        Obx(() => Offstage(offstage: !controller.showContent.value, child: _buildContentNavigator(controller))),
      ],
    );
  }

  Widget _buildLargeScreenScaffold() {
    return Scaffold(
      body: Row(
        children: [
          Obx(
            () => NavigationRail(
              labelType: NavigationRailLabelType.all, //显示所有标签
              destinations: [
                NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text("home".tr)),
                NavigationRailDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: Text("bookshelf".tr)),
                NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text("my".tr)),
              ],
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: (index) => controller.selectedIndex.value = index,
            ),
          ),
          Obx(
            () => Expanded(
              flex: 1,
              child: IndexedStack(index: controller.selectedIndex.value, children: controller.pages),
            ),
          ),
          Expanded(flex: 1, child: _buildContentNavigator(controller)),
        ],
      ),
    );
  }
}

//子路由
Widget _buildContentNavigator(MainController controller) {
  return PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) {
        //单独处理内层返回事件
        try {
          NovelDetailController novelDetailController = Get.find();
          if (novelDetailController.isSelectionMode.value) {
            novelDetailController.exitSelectionMode();
            return;
          }
        } catch (_, _) {
          Log.i("novelDetailController is null");
        }

        //下面是通用处理方式
        if (Navigator.canPop(Get.context!)) {
          Get.back();
          return;
        } else if (AppSubRouter.subNavigatorKey!.currentState!.canPop()) {
          AppSubRouter.subNavigatorKey!.currentState!.pop();
          return;
        }
      }
    },
    child: ClipRect(
      child: Navigator(
        key: AppSubRouter.subNavigatorKey,
        initialRoute: RoutePath.logo,
        observers: [SubNavigatorObserver()],
        onGenerateRoute: (settings) => AppRoutes.subRoutePages(settings),
      ),
    ),
  );
}

//子路由监听
class SubNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (previousRoute != null) {
      var routeName = route.settings.name ?? "";
      AppSubRouter.currentContentRouteName = routeName;
      Get.find<MainController>().showContent.value = routeName != RoutePath.logo;
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    var routeName = previousRoute?.settings.name ?? "";
    AppSubRouter.currentContentRouteName = routeName;
    Get.find<MainController>().showContent.value = routeName != RoutePath.logo;
  }
}
