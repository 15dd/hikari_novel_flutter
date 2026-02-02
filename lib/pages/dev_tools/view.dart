import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../service/dev_mode_service.dart';

class DevToolsPage extends StatelessWidget {
  const DevToolsPage({super.key});

  Future<Directory> _appDir() async {
    if (Platform.isAndroid) {
      final ext = await getExternalStorageDirectory();
      if (ext != null) return ext;
    }
    return getApplicationDocumentsDirectory();
  }

  Future<File> _logFile() async {
    final dir = await _appDir();
    return File('${dir.path}/html_debug.txt');
  }

  Future<Directory> _dumpDir() async {
    final dir = await _appDir();
    final d = Directory('${dir.path}/html_dumps');
    if (!await d.exists()) {
      await d.create(recursive: true);
    }
    return d;
  }

  Future<void> _showTextFile(BuildContext context, String title, File file) async {
    final exists = await file.exists();
    final content = exists ? await file.readAsString() : '';
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(exists ? content : '暂无内容'),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('关闭')),
        ],
      ),
    );
  }

  Future<void> _clearLog() async {
    final file = await _logFile();
    if (await file.exists()) {
      await file.writeAsString('', flush: true);
    }
    Get.snackbar('开发者工具', '日志已清空');
  }

  Future<List<FileSystemEntity>> _listDumps() async {
    final d = await _dumpDir();
    if (!await d.exists()) return [];
    final items = d.listSync().whereType<File>().toList();
    items.sort((a, b) => b.path.compareTo(a.path));
    return items;
  }

  Future<void> _clearDumps() async {
    final d = await _dumpDir();
    if (await d.exists()) {
      for (final f in d.listSync().whereType<File>()) {
        try {
          await f.delete();
        } catch (_) {}
      }
    }
    Get.snackbar('开发者工具', 'HTML dumps 已清空');
  }

  Future<void> _showDumps(BuildContext context) async {
    final items = await _listDumps();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('HTML dumps (${items.length})'),
        content: SizedBox(
          width: double.maxFinite,
          child: items.isEmpty
              ? const Text('暂无 dumps')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (c, i) {
                    final f = items[i] as File;
                    final name = f.path.split(Platform.pathSeparator).last;
                    return ListTile(
                      dense: true,
                      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () async {
                        Get.back();
                        await _showTextFile(context, name, f);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('关闭')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('开发者工具')),
      body: ListView(
        children: [
          Obx(
            () => SwitchListTile(
              title: const Text('开发者模式'),
              subtitle: const Text('开启后才会自动保存 html_debug.txt 与 HTML dumps'),
              value: DevModeService.instance.enabled.value,
              onChanged: (_) => DevModeService.instance.toggle(),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('查看 html_debug.txt'),
            subtitle: const Text('摘要日志：title + HTML 前 500 字'),
            onTap: () async {
              final file = await _logFile();
              await _showTextFile(context, 'html_debug.txt', file);
            },
          ),
          ListTile(
            title: const Text('清空 html_debug.txt'),
            onTap: _clearLog,
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('查看 HTML dumps'),
            subtitle: const Text('完整 HTML（用于 MT 直接分析）'),
            onTap: () => _showDumps(context),
          ),
          ListTile(
            title: const Text('清空 HTML dumps'),
            onTap: _clearDumps,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<Directory>(
              future: _appDir(),
              builder: (_, snap) {
                final path = snap.data?.path ?? '';
                final s = path.isEmpty
                    ? '路径加载中…'
                    : '本地目录:\n$path\n\nMT 查看：Android/data/<package>/files/\n- html_debug.txt\n- html_dumps/';
                return Text(s, style: const TextStyle(fontSize: 12));
              },
            ),
          ),
        ],
      ),
    );
  }
}
