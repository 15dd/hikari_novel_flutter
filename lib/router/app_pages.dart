import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/pages/about/view.dart';
import 'package:hikari_novel_flutter/pages/cache_queue/view.dart';
import 'package:hikari_novel_flutter/pages/dev_tools/view.dart';
import 'package:hikari_novel_flutter/pages/comment/view.dart';
import 'package:hikari_novel_flutter/pages/home/view.dart';
import 'package:hikari_novel_flutter/pages/login/view.dart';
import 'package:hikari_novel_flutter/pages/main/view.dart';
import 'package:hikari_novel_flutter/pages/novel_detail/view.dart';
import 'package:hikari_novel_flutter/pages/photo/view.dart';
import 'package:hikari_novel_flutter/pages/reader/view.dart';
import 'package:hikari_novel_flutter/pages/reader/widgets/reader_setting.dart';
import 'package:hikari_novel_flutter/pages/reply/view.dart';
import 'package:hikari_novel_flutter/pages/search/view.dart';
import 'package:hikari_novel_flutter/pages/setting/view.dart';
import 'package:hikari_novel_flutter/pages/user_bookshelf/view.dart';
import 'package:hikari_novel_flutter/pages/user_info/view.dart';
import 'package:hikari_novel_flutter/pages/welcome/view.dart';
import 'package:hikari_novel_flutter/router/route_path.dart';

import '../pages/browsing_history/view.dart';
import '../widgets/state_page.dart';

class AppRoutes {
  static final List<GetPage<dynamic>> mainRoutePages = [
    CustomGetPage(name: RoutePath.main, page: () => MainPage()),
    CustomGetPage(name: RoutePath.home, page: () => HomePage()),
    CustomGetPage(name: RoutePath.login, page: () => LoginPage()),
    CustomGetPage(name: RoutePath.photo, page: () => PhotoPage()),
    CustomGetPage(name: RoutePath.reader, page: () => ReaderPage()),
    CustomGetPage(name: RoutePath.welcome, page: () => WelcomePage()),
    CustomGetPage(name: RoutePath.readerSetting, page: () => ReaderSettingPage()),
  ];

  static Route<dynamic>? subRoutePages(RouteSettings settings) {
    switch (settings.name) {
      case RoutePath.logo:
        return GetPageRoute(settings: settings, page: () => LogoPage());
      case RoutePath.novelDetail:
        {
          var args = settings.arguments as String;
          return GetPageRoute(settings: settings, page: () => NovelDetailPage(aid: args));
        }
      case RoutePath.comment:
        {
          var args = settings.arguments as String;
          return GetPageRoute(settings: settings, page: () => CommentPage(aid: args));
        }
      case RoutePath.reply:
        {
          var args = settings.arguments as List<String>;
          return GetPageRoute(settings: settings, page: () => ReplyPage(aid: args[0], rid: args[1]));
        }
      case RoutePath.userBookshelf:
        {
          var args = settings.arguments as String;
          return GetPageRoute(settings: settings, page: () => UserBookshelfPage(uid: args));
        }
      case RoutePath.browsingHistory:
        return GetPageRoute(settings: settings, page: () => BrowsingHistoryPage());
      case RoutePath.userInfo:
        return GetPageRoute(settings: settings, page: () => UserInfoPage());
      case RoutePath.about:
        return GetPageRoute(settings: settings, page: () => AboutPage());
      case RoutePath.setting:
        return GetPageRoute(settings: settings, page: () => SettingPage());
      case RoutePath.search:
        {
          var args = settings.arguments as String?;
          return GetPageRoute(settings: settings, page: () => SearchPage(author: args));
        }
      case RoutePath.cacheQueue:
        return GetPageRoute(settings: settings, page: () => CacheQueuePage());
      case RoutePath.devTools:
        return GetPageRoute(settings: settings, page: () => const DevToolsPage());
      default:
        return null;
    }
  }
}

class CustomGetPage extends GetPage<dynamic> {
  CustomGetPage({required super.name, required super.page, this.fullscreen = false, super.transitionDuration})
    : super(
        curve: Curves.linear,
        transition: Transition.native,
        showCupertinoParallax: false,
        popGesture: false,
        fullscreenDialog: fullscreen != null && fullscreen,
      );
  late final bool? fullscreen;
}