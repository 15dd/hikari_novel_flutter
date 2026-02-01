import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/hive_registrar.g.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/common/language.dart';
import '../models/common/wenku8_node.dart';
import '../models/dual_page_mode.dart';
import '../models/reader_direction.dart';
import '../models/user_info.dart';

class LocalStorageService extends GetxService {
  static LocalStorageService get instance => Get.find<LocalStorageService>();

  late final Box<dynamic> _setting;
  late final Box<dynamic> _loginInfo;
  late final Box<dynamic> _reader;

  static const String kCookie = "cookie",
      kUserInfo = "user_info",
      kLanguage = "language",
      kIsAutoCheckUpdate = "isAutoCheckUpdate",
      kWenku8Node = "wenku8Node",
      kIsDynamicColor = "isDynamicColor",
      kCustomColor = "customColor",
      kThemeMode = "themeMode",
      kDefaultHomePage = "defaultHomePage",
      kReadMode = "readMode",
      kIsRelativeTime = "isRelativeTime",
      kReaderDirection = "readerDirection",
      kReaderFontSize = "readerFontSize",
      kReaderLineSpacing = "readerLineSpacing",
      kReaderWakeLock = "readerWakeLock",
      kReaderLeftMargin = "readerLeftMargin",
      kReaderTopMargin = "readerTopMargin",
      kReaderRightMargin = "readerRightMargin",
      kReaderBottomMargin = "readerBottomMargin",
      kReaderDualPageMode = "readerDualPageMode",
      kReaderDualPageSpacing = "readerDualPageSpacing",
      kReaderImmersionMode = "readerImmersionMode",
      kReaderStatusBar = "readerStatusBar",
      kReaderDayBgColor = "readerDayBgColor",
      kReaderDayTextColor = "readerDayTextColor",
      kReaderNightBgColor = "readerNightBgColor",
      kReaderNightTextColor = "readerNightTextColor",
      kReaderDayBgImage = "readerDayBgImage",
      kReaderNightBgImage = "readerNightBgImage",
      kReaderTextFamily = "readerTextFamily",
      kReaderTextStyleFilePath = "readerTextStyleFilePath",
      kReaderPageTurningAnimation = "readerPageTurningAnimation";

  Future<void> init() async {
    final Directory dir = await getApplicationSupportDirectory();
    final String path = dir.path;
    Hive.init("$path/hive");
    Hive.registerAdapters();
    _setting = await Hive.openBox("setting");
    _loginInfo = await Hive.openBox("loginInfo");
    _reader = await Hive.openBox("reader");
  }

  void setCookie(String? value) => _loginInfo.put(kCookie, value);

  String? getCookie() => _loginInfo.get(kCookie);

  void setUserInfo(UserInfo value) => _setting.put(kUserInfo, value);

  UserInfo? getUserInfo() => _setting.get(kUserInfo);

  void setIsAutoCheckUpdate(bool enabled) => _setting.put(kIsAutoCheckUpdate, enabled);

  bool getIsAutoCheckUpdate() => _setting.get(kIsAutoCheckUpdate, defaultValue: true);

  void setThemeMode(ThemeMode tm) => _setting.put(kThemeMode, tm.index);

  ThemeMode getThemeMode() => ThemeMode.values[_setting.get(kThemeMode, defaultValue: ThemeMode.system.index)];

  void setCustomColor(Color color) => _setting.put(kCustomColor, color.toARGB32());

  Color getCustomColor() => Color(_setting.get(kCustomColor, defaultValue: Colors.blue.toARGB32()));

  void setIsDynamicColor(bool enabled) => _setting.put(kIsDynamicColor, enabled);

  bool getIsDynamicColor() => _setting.get(kIsDynamicColor, defaultValue: true);

  void setIsRelativeTime(bool enabled) => _setting.put(kIsRelativeTime, enabled);

  bool getIsRelativeTime() => _setting.get(kIsRelativeTime, defaultValue: false);

  void setLanguage(Language value) => _setting.put(kLanguage, value.index);

  Language getLanguage() => Language.values[_setting.get(kLanguage, defaultValue: Language.followSystem.index)];

  void setWenku8Node(Wenku8Node value) => _setting.put(kWenku8Node, value.index);

  Wenku8Node getWenku8Node() => Wenku8Node.values[_setting.get(kWenku8Node, defaultValue: Wenku8Node.wwwWenku8Net.index)];

  ReaderDirection getReaderDirection() => ReaderDirection.values[_reader.get(kReaderDirection, defaultValue: ReaderDirection.upToDown.index)];

  void setReaderDirection(ReaderDirection value) => _reader.put(kReaderDirection, value.index);

  double getReaderFontSize() => _reader.get(kReaderFontSize, defaultValue: 16.0);

  void setReaderFontSize(double value) => _reader.put(kReaderFontSize, value);

  double getReaderLineSpacing() => _reader.get(kReaderLineSpacing, defaultValue: 1.5);

  void setReaderLineSpacing(double value) => _reader.put(kReaderLineSpacing, value);

  bool getReaderWakeLock() => _reader.get(kReaderWakeLock, defaultValue: false);

  void setReaderWakeLock(bool enabled) => _reader.put(kReaderWakeLock, enabled);

  double getReaderLeftMargin() => _reader.get(kReaderLeftMargin, defaultValue: 20.0);

  void setReaderLeftMargin(double value) => _reader.put(kReaderLeftMargin, value);

  double getReaderTopMargin() => _reader.get(kReaderTopMargin, defaultValue: 20.0);

  void setReaderTopMargin(double value) => _reader.put(kReaderTopMargin, value);

  double getReaderRightMargin() => _reader.get(kReaderRightMargin, defaultValue: 20.0);

  void setReaderRightMargin(double value) => _reader.put(kReaderRightMargin, value);

  double getReaderBottomMargin() => _reader.get(kReaderBottomMargin, defaultValue: 20.0);

  void setReaderBottomMargin(double value) => _reader.put(kReaderBottomMargin, value);

  DualPageMode getReaderDualPageMode() => DualPageMode.values[_reader.get(kReaderDualPageMode, defaultValue: DualPageMode.auto.index)];

  void setReaderDualPageMode(DualPageMode value) => _reader.put(kReaderDualPageMode, value.index);

  double getReaderDualPageSpacing() => _reader.get(kReaderDualPageSpacing, defaultValue: 20.0);

  void setReaderDualPageSpacing(double value) => _reader.put(kReaderDualPageSpacing, value);

  bool getReaderImmersionMode() => _reader.get(kReaderImmersionMode, defaultValue: false);

  void setReaderImmersionMode(bool enabled) => _reader.put(kReaderImmersionMode, enabled);

  bool getReaderStatusBar() => _reader.get(kReaderStatusBar, defaultValue: true);

  void setReaderStatusBar(bool enabled) => _reader.put(kReaderStatusBar, enabled);

  String? getReaderTextFamily() => _reader.get(kReaderTextFamily, defaultValue: null);

  void setReaderTextFamily(String? value) => _reader.put(kReaderTextFamily, value);

  String? getReaderTextStyleFilePath() => _reader.get(kReaderTextStyleFilePath, defaultValue: null);

  void setReaderTextStyleFilePath(String? value) => _reader.put(kReaderTextStyleFilePath, value);

  bool getReaderPageTurningAnimation() => _reader.get(kReaderPageTurningAnimation, defaultValue: true);

  void setReaderPageTurningAnimation(bool enabled) => _reader.put(kReaderPageTurningAnimation, enabled);

  Color? getReaderDayBgColor() {
    final result = _reader.get(kReaderDayBgColor, defaultValue: null);
    return result == null ? null : Color(result);
  }

  void setReaderDayBgColor(Color? value) => _reader.put(kReaderDayBgColor, value?.toARGB32());

  Color? getReaderDayTextColor() {
    final result = _reader.get(kReaderDayTextColor, defaultValue: null);
    return result == null ? null : Color(result);
  }

  void setReaderDayTextColor(Color? value) => _reader.put(kReaderDayTextColor, value?.toARGB32());

  Color? getReaderNightBgColor() {
    final result = _reader.get(kReaderNightBgColor, defaultValue: null);
    return result == null ? null : Color(result);
  }

  void setReaderNightBgColor(Color? value) => _reader.put(kReaderNightBgColor, value?.toARGB32());

  Color? getReaderNightTextColor() {
    final result = _reader.get(kReaderNightTextColor, defaultValue: null);
    return result == null ? null : Color(result);
  }

  void setReaderNightTextColor(Color? value) => _reader.put(kReaderNightTextColor, value?.toARGB32());

  String? getReaderDayBgImage() => _reader.get(kReaderDayBgImage, defaultValue: null);

  void setReaderDayBgImage(String? value) => _reader.put(kReaderDayBgImage, value);

  String? getReaderNightBgImage() => _reader.get(kReaderDayBgImage, defaultValue: null);

  void setReaderNightBgImage(String? value) => _reader.put(kReaderDayBgImage, value);
}
