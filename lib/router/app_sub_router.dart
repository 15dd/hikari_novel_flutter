import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/router/route_path.dart';

class AppSubRouter {
  //当前内容路由的名称
  static String currentContentRouteName = RoutePath.logo;

  //子路由ID
  static final int subNavigatorId = 1;

  //子路由Key
  static final GlobalKey<NavigatorState>? subNavigatorKey = Get.nestedKey(subNavigatorId);

  static void _toContentPage(String name, {dynamic arg, bool replace = false}) {
    if (currentContentRouteName == name || replace) {
      Get.offAndToNamed(name, arguments: arg, id: subNavigatorId);
    } else {
      Get.toNamed(name, arguments: arg, id: subNavigatorId);
    }
  }

  static void toNovelDetail({required String aid}) => _toContentPage(RoutePath.novelDetail, arg: aid);

  static void toComment({required String aid}) => _toContentPage(RoutePath.comment, arg: aid);

  static void toReply({required String aid, required String rid}) => _toContentPage(RoutePath.reply, arg: [aid, rid]);

  static void toUserBookshelf({required String uid}) => _toContentPage(RoutePath.userBookshelf, arg: uid);

  static void toBrowsingHistory() => _toContentPage(RoutePath.browsingHistory);

  static void toUserInfo() => _toContentPage(RoutePath.userInfo);

  static void toAbout() => _toContentPage(RoutePath.about);

  static void toSetting() => _toContentPage(RoutePath.setting);

  static void toSearch({required String? author}) => _toContentPage(RoutePath.search, arg: author);

  static void toCacheQueue() => _toContentPage(RoutePath.cacheQueue);

  static void toDevTools() => _toContentPage(RoutePath.devTools);
}
