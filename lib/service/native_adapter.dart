import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

/// 用系统自带的网络栈发请求：安卓是 Cronet（和 Chrome 同一套 TLS），苹果是 NSURLSession（和 Safari / WebView 同一套）。
/// Dart 自己的 TLS 指纹和浏览器不一样，Cloudflare 会据此拦截；WebView 通过验证后拿到的 cf_clearance，用同样指纹的请求才不容易被再次质询。
///
/// - 安卓设备没有 Google 服务时，编译加上 `--dart-define=cronetHttpNoPlay=true` 用内置的 Cronet；都不可用时退回 [fallback]（Dart 自己的网络层）
/// - 苹果端关掉系统的 cookie 处理：cookie 由 Dio 的 cookie jar 自己管，免得两边各发一份
/// - 其他平台返回 null，继续用 Dart 自己的网络层
HttpClientAdapter? nativeAdapter(HttpClientAdapter Function() fallback) {
  if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) return null;
  return _SplitCookies(NativeAdapter(
    createFallbackAdapter: (_, _) => fallback(),
    createCupertinoConfiguration: () => URLSessionConfiguration.ephemeralSessionConfiguration()
      ..httpShouldSetCookies = false
      ..httpCookieAcceptPolicy = NSHTTPCookieAcceptPolicy.NSHTTPCookieAcceptPolicyNever,
  ));
}

/// 系统网络栈经 http 包转过来时，多条 Set-Cookie 被合成一条逗号拼接的，cookie jar 按一条解析会失败或存错。这里拆回多条。
class _SplitCookies implements HttpClientAdapter {
  _SplitCookies(this._inner);

  final HttpClientAdapter _inner;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final res = await _inner.fetch(options, requestStream, cancelFuture);
    final v = res.headers['set-cookie'];
    if (v != null) res.headers['set-cookie'] = splitSetCookie(v);
    return res;
  }

  @override
  void close({bool force = false}) => _inner.close(force: force);
}

// 和 http 包 headersSplitValues 拆 set-cookie 的规则一样：逗号后面紧跟 `名字=` 才算下一条，expires 里的逗号不拆
final _setCookieSplitter = RegExp(r"[ \t]*,[ \t]*(?=[!#$%&'*+\-.^_`|~0-9A-Za-z]+=)");

List<String> splitSetCookie(List<String> values) => [for (final v in values) ...v.split(_setCookieSplitter)];
