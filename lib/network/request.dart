import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:hikari_novel_flutter/models/common/wenku8_node.dart';
import 'package:hikari_novel_flutter/models/resource.dart';

import '../common/log.dart';
import '../models/common/charsets_type.dart';
import '../service/local_storage_service.dart';
import 'api.dart';

/// 网络请求
class Request {
  static const userAgent = {
    HttpHeaders.userAgentHeader:
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0",
  };

  static final _dioCookieJar = CookieJar();
  static final Dio dio = Dio(
    BaseOptions(
      headers: userAgent,
      responseType: ResponseType.bytes, //使用bytes获取原始数据，方便解码
      followRedirects: false, //使302重定向手动处理，以方便传输cookie
      validateStatus: (status) => status != null && status < 400,
    ),
  )..interceptors.add(CookieManager(_dioCookieJar));


  static final Dio _mewxWenku8Dio = Dio(
    BaseOptions(
      headers: {HttpHeaders.userAgentHeader: "Dalvik/2.1.0 (Linux; U; Android 15; 23114RD76B Build/AQ3A.240912.001)"},
      responseType: ResponseType.bytes, //使用bytes获取原始数据，方便解码
    ),
  )..interceptors.add(CookieManager(CookieJar()));

  static Map<String, String> _getMewxWenku8PostForm(String request) => {
    "appver": "1.24-pico-mochi",
    "timetoken": DateTime.now().millisecondsSinceEpoch.toString(),
    // IMPORTANT:
    // The relay expects the `request` field to be Base64 of UTF-8 bytes.
    // Using `String.codeUnits` would Base64-encode UTF-16 code units in Dart,
    // which breaks non-ASCII characters (and can cause login/check-in to fail).
    "request": base64.encode(utf8.encode(request)),
  };

  static String? _sessionCookie;

  static void setSessionCookie(String? value) => _sessionCookie = value;
  static void clearSessionCookie() => _sessionCookie = null;

  static String? get _cookie => _sessionCookie ?? LocalStorageService.instance.getCookie();
/// Clear in-memory cookie jar used by [dio].
  ///
  /// This does NOT touch the persisted cookie stored in [LocalStorageService].
  static Future<void> clearCookieJar() async {
    try {
      _dioCookieJar.deleteAll();
    } catch (_) {
      // ignore
    }
    // Also clear any runtime-only cookie.
    _sessionCookie = null;
  }

  

  /// 初始化 cookie：把本地持久化的 cookie 同步进 Dio 的 CookieJar。
  /// 这能保证首次网络请求就携带 cookie（用于登录态/签到等）。
  static Future<void> initCookie() async {
    try {
      // Clear runtime jar first, then apply persisted cookie.
      await clearCookieJar();

      final cookieStr = LocalStorageService.instance.getCookie();
      if (cookieStr == null || cookieStr.trim().isEmpty) return;

      final Wenku8Node node = LocalStorageService.instance.getWenku8Node();
      final Uri uri = Uri.parse(node.node);

      final List<Cookie> cookies = <Cookie>[];
      for (final part in cookieStr.split(';')) {
        final p = part.trim();
        if (p.isEmpty || !p.contains('=')) continue;
        final kv = p.split('=');
        final name = kv.first.trim();
        final value = kv.sublist(1).join('=').trim();
        if (name.isEmpty) continue;
        cookies.add(Cookie(name, value));
      }

      if (cookies.isNotEmpty) {
        await _dioCookieJar.saveFromResponse(uri, cookies);
      }
    } catch (_) {
      // ignore: best-effort
    }
  }
/// Get cookies currently held in Dio cookie jar for a given URL.
  static Future<List<Cookie>> getCookiesFor(String url) async {
    try {
      return await _dioCookieJar.loadForRequest(Uri.parse(url));
    } catch (_) {
      return <Cookie>[];
    }
  }

  ///获取通用数据（如其他网站的数据，即不用wenku8的cookie）
  /// - [url] 对应网站的url
  static Future<Resource> getCommonData(String url) async {
    try {
      final dio = Dio(BaseOptions(headers: userAgent));
      final response = await dio.get(url);
      return Success(response.data);
    } catch (e) {
      return Error(e.toString());
    }
  }

  ///获取wenku8数据
  /// - [url] 对应的url
  /// - [charsetsType] response解码的方式
  static Future<Resource> get(String url, {required CharsetsType charsetsType}) async {
    try {
      if (!url.contains("?")) url += "?";
      switch (charsetsType) {
        case CharsetsType.gbk:
          url += "&charset=gbk";
        case CharsetsType.big5Hkscs:
          url += "&charset=big5";
      }

      Log.d("$url ${charsetsType.name}");

      final response = await dio.get(url, options: _cookie != null ? Options(headers: {...dio.options.headers, "Cookie": _cookie}) : null);

      //检查是否有重定向
      final html = await _checkRedirects(response);

      String decodedHtml;
      switch (charsetsType) {
        case CharsetsType.gbk:
          decodedHtml = GbkDecoder().convert(html as Uint8List);
        case CharsetsType.big5Hkscs:
          decodedHtml = Big5Decoder().convert(html as Uint8List);
      }
      return Success(decodedHtml);
    } catch (e) {
      Log.e(e.toString());
      return Error(e.toString());
    }
  }

  /// 检查Response包中是否要求重定向
  /// - [response] 要检查的Response包
  static Future<dynamic> _checkRedirects(Response response) async {
  // Manually follow redirects because `followRedirects` is disabled.
  // This is important for Wenku8 login: the server often sets cookies on a 302 chain.
  Response current = response;
  int hop = 0;

  while (current.statusCode != null &&
      current.statusCode! >= 300 &&
      current.statusCode! < 400 &&
      hop < 6) {
    final location = current.headers.value('location');
    if (location == null || location.trim().isEmpty) break;

    // Resolve relative redirects against the current request URI.
    final baseUri = current.realUri;
    final nextUri = baseUri.resolve(location);

    Log.d("Redirect[${hop + 1}]: $baseUri -> $nextUri");

    // IMPORTANT:
    // Do NOT manually inject Cookie header here. CookieManager will attach cookies
    // stored from previous responses automatically.
    current = await dio.getUri(
      nextUri,
      options: Options(
        headers: {...dio.options.headers},
      ),
    );
    hop++;
  }

  return current.data;
}

  /// 以post方法进行http请求
  /// body以Content-Type: application/x-www-form-urlencoded的形式进行发送
  /// - [url] 要请求的url
  /// - [data] 此post请求的body，当body中含有url编码的内容时，需要使用String类型而非Map类型！目前不知道是什么原因，可能是因为dio的二次编码？
  /// - [charsetsType] response解码的方式
  static Future<Resource> postForm(String url, {required Object? data, required CharsetsType charsetsType}) async {
    try {
      final response = await dio.post(
        url,
        data: data,
        options: _cookie != null
            ? Options(
                headers: {...dio.options.headers, "Cookie": _cookie},
                contentType: Headers.formUrlEncodedContentType, //设置为application/x-www-form-urlencoded
              )
            : Options(
                contentType: Headers.formUrlEncodedContentType, //设置为application/x-www-form-urlencoded
              ),
      );

      // ✅ 与 GET 一样：手动处理 302 重定向（否则可能拿不到最终 Cookie）
      final raw = await _checkRedirects(response);

      String decodedHtml;
      switch (charsetsType) {
        case CharsetsType.gbk:
          {
            decodedHtml = GbkCodec().decode(raw as Uint8List);
          }
        case CharsetsType.big5Hkscs:
          {
            decodedHtml = Big5Codec().decode(raw as Uint8List);
          }
      }
      return Success(decodedHtml);
    } catch (e) {
      Log.e(e.toString());
      return Error(e);
    }
  }

  /// 以post方法向mewx的中转站进行http请求
  /// body以Content-Type: application/x-www-form-urlencoded的形式进行发送
  /// - [request] 要请求的内容（以base64形式进行编码）
  /// - [charsetsType] response解码的方式
  static Future<Resource> postFormToMewxWenku8(String request, {required CharsetsType charsetsType}) async {
    try {
      switch (charsetsType) {
        case CharsetsType.gbk:
          request += "&t=0";
          break;
        case CharsetsType.big5Hkscs:
          request += "&t=1";
          break;
      }

      final response = await _mewxWenku8Dio.post(
        "https://wenku8-relay.mewx.org",
        data: _getMewxWenku8PostForm(request),
        options: Options(
          contentType: Headers.formUrlEncodedContentType, //设置为application/x-www-form-urlencoded
          responseType: ResponseType.plain,
        ),
      );
      return Success(response.data);
    } catch (e) {
      Log.e(e.toString());
      return Error(e);
    }
  }

}