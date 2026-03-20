import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/common/app_translations.dart';
import 'package:hikari_novel_flutter/common/constants.dart';
import 'package:hikari_novel_flutter/common/util.dart';
import 'package:hikari_novel_flutter/network/request.dart';
import 'package:hikari_novel_flutter/router/app_pages.dart';
import 'package:hikari_novel_flutter/router/route_path.dart';
import 'package:hikari_novel_flutter/service/db_service.dart';
import 'package:hikari_novel_flutter/service/dev_mode_service.dart';
import 'package:hikari_novel_flutter/service/local_storage_service.dart';
import 'package:hikari_novel_flutter/service/tts_service.dart';
import 'package:jiffy/jiffy.dart';

final localhostServer = InAppLocalhostServer(documentRoot: 'assets');
WebViewEnvironment? webViewEnvironment;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Get.put(LocalStorageService()).init();
  Get.put(DevModeService()).init();
  Get.put(DBService()).init();
  await Get.put(TtsService()).init();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    final availableVersion = await WebViewEnvironment.getAvailableVersion();
    assert(availableVersion != null, 'Failed to find an installed WebView2 runtime or non-stable Microsoft Edge installation.');
    webViewEnvironment = await WebViewEnvironment.create(settings: WebViewEnvironmentSettings(userDataFolder: 'custom_path'));
  } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  _init();
  await Jiffy.setLocale(Util.getCurrentLocale().toString());
  Request.initCookie(); //初始化cookie

  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //自定义颜色
    Color brandColor = LocalStorageService.instance.getCustomColor();
    //深浅模式
    ThemeMode currentThemeValue = LocalStorageService.instance.getThemeMode();
    //是否动态取色
    bool isDynamicColor = LocalStorageService.instance.getIsDynamicColor();

    if (Platform.isAndroid) {
      return AndroidApp(brandColor: brandColor, isDynamicColor: isDynamicColor, currentThemeValue: currentThemeValue);
    } else {
      return OtherApp(brandColor: brandColor, currentThemeValue: currentThemeValue);
    }
  }
}

class AndroidApp extends StatelessWidget {
  const AndroidApp({super.key, required this.brandColor, required this.isDynamicColor, required this.currentThemeValue});

  final Color brandColor;
  final bool isDynamicColor;
  final ThemeMode currentThemeValue;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: ((ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme? lightColorScheme;
        ColorScheme? darkColorScheme;
        if (lightDynamic != null && darkDynamic != null && isDynamicColor) {
          // dynamic取色成功
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // dynamic取色失败，采用品牌色
          lightColorScheme = ColorScheme.fromSeed(seedColor: brandColor, brightness: Brightness.light);
          darkColorScheme = ColorScheme.fromSeed(seedColor: brandColor, brightness: Brightness.dark);
        }
        return BuildMainApp(lightColorScheme: lightColorScheme, darkColorScheme: darkColorScheme, currentThemeValue: currentThemeValue);
      }),
    );
  }
}

class OtherApp extends StatelessWidget {
  const OtherApp({super.key, required this.brandColor, required this.currentThemeValue});

  final Color brandColor;
  final ThemeMode currentThemeValue;

  @override
  Widget build(BuildContext context) {
    return BuildMainApp(
      lightColorScheme: ColorScheme.fromSeed(seedColor: brandColor, brightness: Brightness.light),
      darkColorScheme: ColorScheme.fromSeed(seedColor: brandColor, brightness: Brightness.dark),
      currentThemeValue: currentThemeValue,
    );
  }
}

class BuildMainApp extends StatelessWidget {
  const BuildMainApp({super.key, required this.lightColorScheme, required this.darkColorScheme, required this.currentThemeValue});

  final ColorScheme lightColorScheme;
  final ColorScheme darkColorScheme;
  final ThemeMode currentThemeValue;

  @override
  Widget build(BuildContext context) {
    final SnackBarThemeData snackBarTheme = SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      actionTextColor: lightColorScheme.primary,
      backgroundColor: lightColorScheme.onSurface,
      closeIconColor: lightColorScheme.surface,
      contentTextStyle: TextStyle(color: lightColorScheme.surface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      showCloseIcon: true,
    );

    return GetMaterialApp(
      title: kAppName,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: currentThemeValue == ThemeMode.dark ? darkColorScheme : lightColorScheme,
        snackBarTheme: snackBarTheme,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{TargetPlatform.android: ZoomPageTransitionsBuilder(allowEnterRouteSnapshotting: false)},
        ),
        //页面切换动画
        fontFamily: Platform.isWindows ? "Microsoft YaHei" : null,
      ),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: currentThemeValue == ThemeMode.light ? lightColorScheme : darkColorScheme),
      translations: AppTranslations(),
      locale: Util.getCurrentLocale(),
      fallbackLocale: Locale("zh", "CN"),
      getPages: AppRoutes.mainRoutePages,
      initialRoute: LocalStorageService.instance.getCookie() != null ? RoutePath.main : RoutePath.welcome, //初始页面
    );
  }
}

void _init() {
  // 小白条、导航栏沉浸
  if (Platform.isAndroid) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  }

  EasyRefresh.defaultHeaderBuilder = () => ClassicHeader(
    dragText: "drag_text_refresh".tr,
    armedText: "armed_text_refresh".tr,
    readyText: "ready_text_refresh".tr,
    processingText: "processing_text_refresh".tr,
    processedText: "processed_text_refresh".tr,
    noMoreText: "no_more_text".tr,
    failedText: "failed_text_refresh".tr,
    messageText: "message_text".tr,
  );
  EasyRefresh.defaultFooterBuilder = () => ClassicFooter(
    dragText: "drag_text_load".tr,
    armedText: "armed_text_load".tr,
    readyText: "ready_text_load".tr,
    processingText: "processing_text_load".tr,
    processedText: "processed_text_load".tr,
    noMoreText: "no_more_text".tr,
    failedText: "failed_text_load".tr,
    messageText: "message_text".tr,
  );
}