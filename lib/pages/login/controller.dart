import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/main.dart';
import 'package:hikari_novel_flutter/models/common/wenku8_node.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/common/constants.dart';
import 'package:hikari_novel_flutter/router/route_path.dart';
import 'package:hikari_novel_flutter/service/api_service.dart';

import '../../common/database/database.dart';
import '../../models/resource.dart';
import '../../network/parser.dart';
import '../../service/db_service.dart';
import '../../service/local_storage_service.dart';

class LoginController extends GetxController {
  RxBool showLoading = true.obs;
  RxInt loadingProgress = 0.obs;
  final CookieManager cookieManager = CookieManager.instance(webViewEnvironment: webViewEnvironment);
  InAppWebViewController? inAppWebViewController;
  final GlobalKey webViewKey = GlobalKey();
  final InAppWebViewSettings settings = InAppWebViewSettings(isInspectable: kDebugMode, userAgent: kUserAgent["User-Agent"], javaScriptEnabled: true);
  RxString currentUrl = "".obs;

  Rx<PageState> pageState = PageState.success.obs;
  String errorMsg = "";

  String get url => "${ApiService.instance.wenku8Node.node}/login.php";

  @override
  void onInit() {
    super.onInit();
    cookieManager.deleteAllCookies();
  }

  Future<void> saveCookie(WebUri uri) async {
    showLoading.value = false;

    //存储cookie
    if (uri.toString().contains("wenku8") == true) {
      final getCookie = await cookieManager.getCookies(url: uri);

      bool hasCookie = ["jieqiUserInfo", "jieqiVisitInfo"].every(
        (keyword) => getCookie.any((cookieItem) => cookieItem.name.contains(keyword)),
      ); //getCookie.any((cookieItem) => cookieItem.name == "jieqiUserInfo");
      if (hasCookie) {
        String cookie = "jieqiUserInfo=${getCookie.firstWhere((cookieItem) => cookieItem.name == "jieqiUserInfo").value};";
        cookie += "jieqiVisitInfo=${getCookie.firstWhere((cookieItem) => cookieItem.name == "jieqiVisitInfo").value}";
        LocalStorageService.instance.setCookie(cookie);
        ApiService.instance.initCookie();

        try {
          await _getUserInfo();
          await _refreshBookshelf();
        } catch (e) {
          LocalStorageService.instance.setCookie(null); //清空cookie
          ApiService.instance.deleteCookie();

          final controller = inAppWebViewController;
          if (controller != null) {
            inAppWebViewController = null;
            controller.dispose(); //销毁webview，停止加载网页
          }

          errorMsg = e.toString();
          pageState.value = PageState.error;

          return;
        }

        Get.offAllNamed(RoutePath.main);
      }
    }
  }

  Future<void> _getUserInfo() async {
    final data = await ApiService.instance.getUserInfo();
    switch (data) {
      case Success():
        LocalStorageService.instance.setUserInfo(Parser.getUserInfo(data.data));
      case Error():
        {
          throw data.error;
        }
    }
  }

  Future<void> _refreshBookshelf() async {
    await DBService.instance.deleteAllBookshelf();

    final futures = Iterable.generate(6, (index) async {
      await _insertAll(index);
    });
    await Future.wait(futures);
  }

  Future<void> _insertAll(int index) async {
    final result = await ApiService.instance.getBookshelf(classId: index);
    switch (result) {
      case Success():
        {
          final bookshelf = Parser.getBookshelf(result.data, index);
          if (bookshelf.list.isNotEmpty) {
            final insertData = bookshelf.list.map((e) {
              return BookshelfEntityData(aid: e.aid, bid: e.bid, url: e.url, title: e.title, img: e.img, classId: bookshelf.classId.toString());
            });
            await DBService.instance.insertAllBookshelf(insertData);
          }
        }
      case Error():
        {
          throw result.error;
        }
    }
  }
}
