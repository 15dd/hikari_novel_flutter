import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:hikari_novel_flutter/common/migration.dart';
import 'package:path_provider/path_provider.dart';
import 'entity.dart';

part "database.g.dart";

@DriftDatabase(tables: [BookshelfEntity, BrowsingHistoryEntity, SearchHistoryEntity, ReadHistoryEntity, NovelDetailEntity])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; //版本号

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from == 1 && to == 2) {
        Migration.fromOneToTwo(this);
      }
    },
  );

  Future<void> insertAllBookshelf(Iterable<BookshelfEntityData> data) => batch((b) => b.insertAll(bookshelfEntity, data));

  Future<void> deleteAllBookshelf() => delete(bookshelfEntity).go();

  Future<void> deleteDefaultBookshelf() => (delete(bookshelfEntity)..where((i) => i.classId.equals("0"))).go();

  Stream<List<BookshelfEntityData>> getBookshelfByClassId(String classId) => (select(bookshelfEntity)..where((i) => i.classId.equals(classId))).watch();

  Future<List<BookshelfEntityData>> getAllBookshelf() => select(bookshelfEntity).get();

  Future<List<BookshelfEntityData>> getBookshelfByKeyword(String keyword) =>
      (select(bookshelfEntity)..where((i) => i.title.contains(keyword).equals(true))).get();

  Future<void> upsertBrowsingHistory(BrowsingHistoryEntityData data) => into(browsingHistoryEntity).insertOnConflictUpdate(data);

  Stream<List<BrowsingHistoryEntityData>> getWatchableAllBrowsingHistory() => select(browsingHistoryEntity).watch();

  Future<void> deleteBrowsingHistory(String aid) => (delete(browsingHistoryEntity)..where((i) => i.aid.equals(aid))).go();

  Future<void> deleteAllBrowsingHistory() => delete(browsingHistoryEntity).go();

  Future<void> upsertSearchHistory(SearchHistoryEntityData data) => into(searchHistoryEntity).insertOnConflictUpdate(data);

  Stream<List<SearchHistoryEntityData>> getAllSearchHistory() => select(searchHistoryEntity).watch();

  Future<void> deleteAllSearchHistory() => delete(searchHistoryEntity).go();

  Future<void> upsertReadHistory(ReadHistoryEntityData data) => transaction(() async {
    await (update(readHistoryEntity)
      ..where((i) => i.isLatest.equals(true) & i.aid.equals(data.aid))).write(RawValuesInsertable({readHistoryEntity.isLatest.name: Variable<bool>(false)}));
    await into(readHistoryEntity).insertOnConflictUpdate(data);
  });

  Future<ReadHistoryEntityData?> getReadHistoryByCid(String cid) => (select(readHistoryEntity)..where((i) => i.cid.equals(cid))).getSingleOrNull();

  Stream<ReadHistoryEntityData?> getLastestReadHistoryByAid(String aid) =>
      (select(readHistoryEntity)..where((i) => i.aid.equals(aid) & i.isLatest.equals(true))).watchSingleOrNull();

  Stream<ReadHistoryEntityData?> getWatchableReadHistoryByCid(String cid) => (select(readHistoryEntity)..where((i) => i.cid.equals(cid))).watchSingleOrNull();

  /// - [cids] 该卷下所有小说的cid
  Stream<List<ReadHistoryEntityData>> getWatchableReadHistoryByVolume(List<String> cids) => (select(readHistoryEntity)..where((i) => i.cid.isIn(cids))).watch();

  Future<void> deleteReadHistoryByCid(String cid) => (delete(readHistoryEntity)..where((i) => i.cid.equals(cid))).go();

  Future<void> upsertReadHistoryDirectly(ReadHistoryEntityData data) => into(readHistoryEntity).insertOnConflictUpdate(data);

  Future<void> deleteAllReadHistory() => delete(readHistoryEntity).go();

  Future<void> upsertNovelDetail(NovelDetailEntityData data) => into(novelDetailEntity).insertOnConflictUpdate(data);

  Future<NovelDetailEntityData?> getNovelDetail(String aid) => (select(novelDetailEntity)..where((i) => i.aid.equals(aid))).getSingleOrNull();

  Future<void> deleteAllNovelDetail() => delete(novelDetailEntity).go();
}

QueryExecutor _openConnection() =>
    driftDatabase(name: "hikari_novel_database", native: const DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory));
