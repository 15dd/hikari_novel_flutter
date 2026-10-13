import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/router/route_path.dart';
import 'package:hikari_novel_flutter/service/api_service.dart';

import '../../models/resource.dart';
import '../../parser/parser.dart';
import '../../models/custom_exception.dart';
import '../../service/local_storage_service.dart';

class LoginController extends GetxController {
  Rx<PageState> pageState = PageState.success.obs;
  final errorMsg = "".obs;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final checkcodeController = TextEditingController();
  final Rxn<Uint8List> captcha = Rxn<Uint8List>();
  final RxBool submitting = false.obs;
  final RxBool needCheckcode = false.obs;

  bool _prepared = false;

  @override
  void onInit() {
    super.onInit();
    unawaited(_prepare());
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    checkcodeController.dispose();
    super.onClose();
  }

  Future<bool> _prepare() async {
    final result = await ApiService.instance.prepareLogin();
    switch (result) {
      case Success():
        _prepared = true;
        final html = "${result.data}";
        if (html.contains("checkcode")) {
          needCheckcode.value = true;
          await refreshCaptcha();
        } else {
          needCheckcode.value = false;
          captcha.value = null;
        }
        return true;
      case Error():
        errorMsg.value = _loginError("${result.error}");
        return false;
    }
  }

  Future<void> refreshCaptcha({bool keepError = false}) async {
    final result = await ApiService.instance.fetchCheckcode();
    switch (result) {
      case Success() when result.data is Uint8List:
        captcha.value = result.data as Uint8List;
        if (!keepError) errorMsg.value = "";
      case Success():
        captcha.value = null;
        errorMsg.value = _loginError("${result.data}");
      case Error():
        captcha.value = null;
        errorMsg.value = _loginError("${result.error}");
    }
  }

  Future<void> submit() async {
    if (submitting.value) return;
    submitting.value = true;
    var entered = false;
    if (!_prepared) {
      final ok = await _prepare();
      if (!ok) {
        submitting.value = false;
        return;
      }
    }
    final result = await ApiService.instance.login(
      username: usernameController.text,
      password: passwordController.text,
      checkcode: needCheckcode.value ? checkcodeController.text : null,
    );
    switch (result) {
      case Success():
        try {
          await _getUserInfo();
          entered = true;
          Get.offAllNamed(RoutePath.main);
        } catch (e) {
          final raw = e.toString();
          errorMsg.value = _loginError(raw);
          if (!raw.contains(cloudflare429ExceptionMessage)) {
            LocalStorageService.instance.setCookie(null);
            ApiService.instance.deleteCookie();
            pageState.value = PageState.error;
          }
        }
      case Error():
        final raw = "${result.error}";
        errorMsg.value = _loginError(raw);
        if (needCheckcode.value && !raw.contains(cloudflare429ExceptionMessage)) {
          checkcodeController.clear();
          await refreshCaptcha(keepError: true);
        }
    }
    if (!entered) submitting.value = false;
  }

  String _loginError(String raw) {
    if (raw.contains(cloudflare403ExceptionMessage) ||
        raw.contains(cloudflareChallengeExceptionMessage) ||
        raw.contains(cloudflare429ExceptionMessage)) {
      return raw;
    }
    const phrases = [
      "用户不存在",
      "密码错误",
      "校验码错误",
      "验证码过期",
      "用戶不存在",
      "密碼錯誤",
      "校驗碼錯誤",
      "驗證碼過期",
    ];
    for (final phrase in phrases) {
      if (raw.contains(phrase)) return phrase;
    }
    return "login_failed".tr;
  }

  Future<void> _getUserInfo() async {
    final data = await ApiService.instance.getUserInfo();
    switch (data) {
      case Success():
        LocalStorageService.instance.setUserInfo(Parser.getUserInfo(data.data));
      case Error():
        throw data.error;
    }
  }
}
