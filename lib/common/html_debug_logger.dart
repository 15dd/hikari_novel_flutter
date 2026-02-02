import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../service/dev_mode_service.dart';

class HtmlDebugLogger {
  static bool get _enabled {
    try {
      return DevModeService.instance.enabled.value;
    } catch (_) {
      return false;
    }
  }

  static String _safe(String s) => s.replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '_');

  static Future<File> _logFile() async {
    final dir = await _baseDir();
    return File('${dir.path}/html_debug.txt');
  }

  static Future<Directory> _dumpDir() async {
    final dir = await _baseDir();
    final d = Directory('${dir.path}/html_dumps');
    if (!await d.exists()) {
      await d.create(recursive: true);
    }
    return d;
  }

  static Future<Directory> _baseDir() async {
    if (Platform.isAndroid) {
      final ext = await getExternalStorageDirectory();
      if (ext != null) return ext;
    }
    return getApplicationDocumentsDirectory();
  }

  static Future<void> log({
    required String scene,
    String? url,
    String? title,
    String? htmlPreview,
    Map<String, dynamic>? headers,
  }) async {
    if (!_enabled) return;
    try {
      final file = await _logFile();
      final buffer = StringBuffer();
      buffer.writeln('==============================');
      buffer.writeln('time: ${DateTime.now().toIso8601String()}');
      buffer.writeln('scene: $scene');
      if (url != null) buffer.writeln('url: $url');
      if (title != null) buffer.writeln('title: $title');
      if (headers != null) {
        buffer.writeln('headers:');
        headers.forEach((k, v) {
          buffer.writeln('  $k: $v');
        });
      }
      if (htmlPreview != null) {
        buffer.writeln('html preview:');
        buffer.writeln(htmlPreview);
      }
      buffer.writeln('');
      await file.writeAsString(buffer.toString(), mode: FileMode.append, flush: true);
    } catch (_) {}
  }

  static Future<void> dumpHtml({
    required String scene,
    required String html,
    String? url,
    String? title,
    Map<String, dynamic>? headers,
  }) async {
    if (!_enabled) return;
    try {
      final d = await _dumpDir();
      final ts = DateTime.now().toIso8601String().replaceAll(':', '').replaceAll('-', '');
      final name = 'html_dump_${ts}_${_safe(scene)}.html';
      final f = File('${d.path}/$name');

      const maxBytes = 1024 * 1024 * 2;
      final content = html.length > maxBytes ? html.substring(0, maxBytes) : html;
      await f.writeAsString(content, flush: true);

      final meta = <String, dynamic>{
        'time': DateTime.now().toIso8601String(),
        'scene': scene,
        if (url != null) 'url': url,
        if (title != null) 'title': title,
        if (headers != null) 'headers': headers,
      };
      final metaFile = File('${d.path}/' + name.replaceAll('.html', '.meta.json'));
      await metaFile.writeAsString(const JsonEncoder.withIndent('  ').convert(meta), flush: true);

      final preview = html.length > 500 ? html.substring(0, 500) : html;
      await log(scene: scene, url: url, title: title, htmlPreview: preview, headers: headers);
    } catch (_) {}
  }
}
