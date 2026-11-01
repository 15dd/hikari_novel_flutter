import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/common/constants.dart';
import 'package:hikari_novel_flutter/main.dart';
import 'package:hikari_novel_flutter/models/common/wenku8_node.dart';
import 'package:hikari_novel_flutter/service/api_service.dart';

/// 在内置浏览器里打开当前节点，通过 Cloudflare 的人机验证。拿到 `cf_clearance` 后保存并返回 true。
/// WebView 和请求用同一个 User-Agent，Cloudflare 才认这个放行 cookie。
class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final _node = ApiService.instance.wenku8Node;
  final _cookieManager = CookieManager.instance(webViewEnvironment: webViewEnvironment);
  bool _done = false;
  int _progress = 0;

  // 按 https 取：站点可能跳到 http 页面（会被系统拦成报错页），按 http 地址取不到只走 https 的 cf_clearance
  Future<List<Cookie>> _cookies() => _cookieManager.getCookies(url: WebUri("${_node.node}/"));

  Future<void> _finish(List<Cookie> cookies) async {
    if (_done) return;
    _done = true;
    ApiService.instance.saveCfCookie(_node, cookies.map((e) => "${e.name}=${e.value}"));
    Get.back(result: true);
  }

  Future<void> _check() async {
    final cookies = await _cookies();
    if (cookies.any((e) => e.name == "cf_clearance")) await _finish(cookies);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: CloseButton(onPressed: Get.back),
        title: Text("cloudflare_verify".tr),
        actions: [TextButton(onPressed: () async => _finish(await _cookies()), child: Text("confirm".tr))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_progress < 100) LinearProgressIndicator(value: _progress / 100),
            Expanded(
              child: InAppWebView(
                webViewEnvironment: webViewEnvironment,
                initialUrlRequest: URLRequest(url: WebUri("${_node.node}/")),
                initialSettings: InAppWebViewSettings(isInspectable: kDebugMode, userAgent: kHeader["User-Agent"], javaScriptEnabled: true),
                onLoadStop: (_, _) => _check(),
                onProgressChanged: (_, progress) => setState(() => _progress = progress),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
