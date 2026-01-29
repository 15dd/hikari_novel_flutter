import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/database/database.dart';
import '../../models/common/wenku8_node.dart';
import '../../models/resource.dart';
import '../../network/api.dart';
import '../../network/request.dart';
import '../../network/parser.dart';
import '../../router/route_path.dart';
import '../../service/db_service.dart';
import '../../service/local_storage_service.dart';

/// Native username/password login.
///
/// Notes:
/// - We intentionally **do not** include captcha / troubleshooting / settings
///   entries here (per the Flutter refactor requirements).
/// - A WebView login page is still available as a fallback.
class LoginFormController extends GetxController {
  final RxBool isSubmitting = false.obs;

  /// Attempt to login with username/password.
  ///
  /// If login succeeds, this will save cookie + credentials and then refresh
  /// user info + bookshelf before entering main page.
  Future<void> login({
    required String username,
    required String password,
    String usecookieSeconds = "86400", // 1 day by default
  }) async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    try {
      // Clear previous cookie to avoid stale sessions.
      await Request.clearCookieJar();

      final url = "${Api.wenku8Node.node}/login.php";

      // Wenku8 historically expects form fields: action/login, username,
      // password, usecookie, and sometimes checkcode.
      final Resource res = await Request.postForm(
        url,
        data: {
          "action": "login",
          "username": username,
          "password": password,
          "usecookie": usecookieSeconds,
          // Keep the field to be compatible with older endpoints; left empty.
          "checkcode": "",
        },
        charsetsType: Api.charsetsType,
      );

      if (res is Error) {
        _showError(res.error.toString());
        return;
      }

      // Extract cookie from Dio cookie jar.
      final cookies = await Request.getCookiesFor(Api.wenku8Node.node);
      final hasLoginCookie =
          cookies.any((c) => c.name.contains("jieqiUserInfo")) &&
          cookies.any((c) => c.name.contains("jieqiVisitInfo"));

      if (!hasLoginCookie) {
        // The response body usually contains the failure reason.
        final msg = (res as Success).data?.toString() ?? "";
        final snippet = msg.trim().isEmpty
            ? "登录失败：未获取到登录 Cookie。建议点击左下角“去网页登录”作为备用登录。"
            : (msg.length > 140 ? "${msg.substring(0, 140)}..." : msg);
        _showError(snippet);
        return;
      }

      final cookieHeader = cookies.map((c) => "${c.name}=${c.value}").join("; ");
      LocalStorageService.instance.setCookie(cookieHeader);
      LocalStorageService.instance.setUsername(username);
      LocalStorageService.instance.setPassword(password);

      await _getUserInfo();
      await _refreshBookshelf();
      Get.offAllNamed(RoutePath.main);
    } catch (e) {
      _showError(e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _getUserInfo() async {
    final data = await Api.getUserInfo();
    switch (data) {
      case Success():
        LocalStorageService.instance.setUserInfo(Parser.getUserInfo(data.data));
      case Error():
        _showError(data.error.toString());
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
    final result = await Api.getBookshelf(classId: index);
    switch (result) {
      case Success():
        final bookshelf = Parser.getBookshelf(result.data, index);
        if (bookshelf.list.isNotEmpty) {
          final insertData = bookshelf.list.map((e) {
            return BookshelfEntityData(
              aid: e.aid,
              bid: e.bid,
              url: e.url,
              title: e.title,
              img: e.img,
              classId: bookshelf.classId.toString(),
            );
          });
          await DBService.instance.insertAllBookshelf(insertData);
        }
      case Error():
        _showError(result.error.toString());
    }
  }

  void _showError(String message) {
    Get.dialog(
      AlertDialog(
        title: Text("error".tr),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("confirm".tr),
          ),
        ],
      ),
    );
  }
}
