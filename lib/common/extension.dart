import 'package:enough_convert/enough_convert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension Controller on GetInterface {
  T findOrPut<T>(T Function() creator) {
    try {
      return Get.find<T>();
    } catch (_) {
      final instance = creator();
      Get.put<T>(instance);
      return instance;
    }
  }
}

extension ScreenInfo on BuildContext {
  bool isLargeScreen() => MediaQuery.of(this).size.width > MediaQuery.of(this).size.height;
}

extension UrlEncodingIfNotAscii on String {
  String gbkUrlEncodingIfNotAscii() {
    final bytes = GbkCodec().encode(this);
    return _encode(bytes);
  }

  String big5UrlEncodingIfNotAscii() {
    final bytes = Big5Codec().encode(this);
    return _encode(bytes);
  }

  // 只对非 ASCII 字节进行 %XX 编码
  String _encode(List<int> bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      if (byte >= 0x00 && byte <= 0x7F) {
        // ASCII字符不编码
        buffer.write(String.fromCharCode(byte));
      } else {
        // 非ASCII字符转成 %XX 大写十六进制
        buffer.write('%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}');
      }
    }
    return buffer.toString();
  }
}