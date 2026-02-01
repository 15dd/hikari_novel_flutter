import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'database/database.dart';

class Migration {
  static Future<void> fromOneToTwo(AppDatabase appDatabase) async {
    //删除不必要的键值对
    if (Hive.isBoxOpen("loginInfo")) {
      final loginInfo = await Hive.openBox("loginInfo");
      loginInfo.delete("username");
      loginInfo.delete("password");
    }

    //删除已缓存的章节。因为数据源不一样，不是该数据源的内容在解析器内会出错
    final dir = await getApplicationSupportDirectory();
    final cacheDir = Directory("${dir.path}/cached_chapter");
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }

    //创建新表
    await appDatabase.customStatement('''
          CREATE TABLE read_history_entity_new (
            cid TEXT PRIMARY KEY,
            aid TEXT,
            reader_mode INTEGER,
            is_dual_page INTEGER,
            location INTEGER,
            progress INTEGER,
            is_latest INTEGER
          );
        ''');
    //拷贝旧数据
    await appDatabase.customStatement('''
          INSERT INTO read_history_entity_new (cid, aid, reader_mode, is_dual_page, location, progress, is_latest)
          SELECT cid, aid, reader_mode, is_dual_page, location, progress, is_latest FROM read_history_entity;
        ''');
    //删除旧表
    await appDatabase.customStatement("DROP TABLE read_history_entity;");
    //重命名新表
    await appDatabase.customStatement("ALTER TABLE read_history_entity_new RENAME TO read_history_entity;");
  }
}