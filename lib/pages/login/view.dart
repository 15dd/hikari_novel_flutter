import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/main.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/widgets/state_page.dart';

import '../../router/route_path.dart';
import 'controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: CloseButton(onPressed: Get.back),
          title: Obx(() => Text(controller.currentUrl.value)),
          actions: controller.pageState.value == PageState.success
              ? [
                  IconButton(
                    onPressed: () async {
                      if (await controller.inAppWebViewController?.canGoBack() == true) {
                        controller.inAppWebViewController?.goBack();
                      }
                    },
                    icon: Icon(Icons.arrow_upward),
                    tooltip: "back_to_previous_web_page".tr,
                  ),
                  IconButton(onPressed: () => controller.inAppWebViewController?.reload(), icon: Icon(Icons.refresh), tooltip: "refresh_web_page".tr),
                ]
              : [],
        ),
        body: Stack(
          children: [
            Obx(
              () => Offstage(
                offstage: controller.pageState.value != PageState.success,
                child: Column(
                  children: [
                    Obx(
                      () => AnimatedContainer(
                        curve: Curves.easeInOut,
                        duration: const Duration(milliseconds: 350),
                        height: controller.showLoading.value ? 4 : 0,
                        child: LinearProgressIndicator(key: ValueKey(controller.loadingProgress), value: controller.loadingProgress / 100),
                      ),
                    ),
                    Expanded(
                      child: SafeArea(
                        child: InAppWebView(
                          key: controller.webViewKey,
                          webViewEnvironment: webViewEnvironment,
                          initialUrlRequest: URLRequest(url: WebUri(controller.url)),
                          initialSettings: controller.settings,
                          onWebViewCreated: (webController) {
                            controller.inAppWebViewController = webController;
                          },
                          onLoadStart: (webController, webUri) {
                            controller.currentUrl.value = webUri.toString();
                          },
                          onLoadStop: (webController, webUri) async {
                            if (webUri != null) {
                              controller.saveCookie(webUri);
                            }

                            if (webUri.toString() == controller.url) {
                              await webController.evaluateJavascript(
                                //去掉<浏览器进程>选项，防止获取到临时cookie
                                source: """
                                  var select = document.querySelector('select[name="usecookie"]');
                                  if (select) {
                                    for (var i = 0; i < select.options.length; i++) {
                                      if (select.options[i].value === "0") {
                                        select.remove(i);
                                        break;
                                      }
                                    }
                                  }
                                """,
                              );
                            }
                          },
                          onProgressChanged: (webController, progress) {
                            controller.showLoading.value = progress != 100;
                            controller.loadingProgress.value = progress;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(
              () => Offstage(
                offstage: controller.pageState.value != PageState.error,
                child: ErrorMessage(msg: controller.errorMsg, action: () => Get.offAllNamed(RoutePath.welcome), buttonText: "re_login".tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
