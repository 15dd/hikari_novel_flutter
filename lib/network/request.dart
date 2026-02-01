import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart' as ckjar;
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as in_app_webview;
import 'package:hikari_novel_flutter/models/common/wenku8_node.dart';
import 'package:hikari_novel_flutter/models/custom_exception.dart';
import 'package:hikari_novel_flutter/models/resource.dart';

import '../common/log.dart';
import '../models/common/charsets_type.dart';
import '../service/local_storage_service.dart';
import 'api.dart';

/// 网络请求
class Request {
  static const userAgent = {
    io.HttpHeaders.userAgentHeader:
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0",
  };

  static final _dioCookieJar = ckjar.CookieJar();
  static final Dio dio =
      Dio(
          BaseOptions(
            headers: userAgent,
            responseType: ResponseType.bytes, //使用bytes获取原始数据，方便解码
            followRedirects: false, //使302重定向手动处理
            validateStatus: (status) => status != null, //只要不是 null，就交给拦截器处理,
          ),
        )
        ..interceptors.add(CloudflareInterceptor(cookieJar: _dioCookieJar))
        ..interceptors.add(CookieManager(_dioCookieJar));

  static void initCookie() {
    final localCookie = LocalStorageService.instance.getCookie();

    if (localCookie == null) return;

    final uri = Uri.parse(LocalStorageService.instance.getWenku8Node().node);

    final cookies = localCookie.split(';').map((e) => e.trim()).where((e) => e.contains('=')).map((e) {
      final kv = e.split('=');
      return ckjar.Cookie(kv[0], kv.sublist(1).join('='));
    }).toList();

    _dioCookieJar.saveFromResponse(uri, cookies);
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

      final response = await dio.get(url);

      //检查是否有重定向
      final result = await _checkRedirects(response);

      final raw = result as Uint8List;
      late String decodedHtml;
      switch (charsetsType) {
        case CharsetsType.gbk:
          decodedHtml = GbkDecoder().convert(raw);
        case CharsetsType.big5Hkscs:
          decodedHtml = Big5Decoder().convert(raw);
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
    if (response.statusCode != null && response.statusCode! >= 300 && response.statusCode! < 400) {
      final location = response.headers.value('location');
      if (location != null) {
        final redirectedResponse = await dio.get("${Api.wenku8Node.node}/$location");
        return redirectedResponse.data;
      }
    }
    return response.data;
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
        options: Options(contentType: Headers.formUrlEncodedContentType), //设置为application/x-www-form-urlencoded
      );
      String decodedHtml;
      switch (charsetsType) {
        case CharsetsType.gbk:
          {
            decodedHtml = GbkCodec().decode(response.data as Uint8List);
          }
        case CharsetsType.big5Hkscs:
          {
            decodedHtml = Big5Codec().decode(response.data as Uint8List);
          }
      }
      return Success(decodedHtml);
    } catch (e) {
      Log.e(e.toString());
      return Error(e.toString());
    }
  }
}

class CloudflareInterceptor extends Interceptor {
  final ckjar.CookieJar cookieJar;

  CloudflareInterceptor({required this.cookieJar});

  in_app_webview.InAppWebViewController? webViewController;

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) async {
    final cfMitigated = response.headers['cf-mitigated'];
    if (cfMitigated == null || !cfMitigated.contains('challenge')) {
      handler.next(response);
      return;
    }
    handler.reject(CloudflareChallengeException(requestOptions: response.requestOptions));
  }
}
