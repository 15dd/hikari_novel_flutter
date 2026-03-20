// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BookshelfEntityTable extends BookshelfEntity
    with TableInfo<$BookshelfEntityTable, BookshelfEntityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookshelfEntityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _aidMeta = const VerificationMeta('aid');
  @override
  late final GeneratedColumn<String> aid = GeneratedColumn<String>(
    'aid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bidMeta = const VerificationMeta('bid');
  @override
  late final GeneratedColumn<String> bid = GeneratedColumn<String>(
    'bid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imgMeta = const VerificationMeta('img');
  @override
  late final GeneratedColumn<String> img = GeneratedColumn<String>(
    'img',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [aid, bid, url, title, img, classId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookshelf_entity';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookshelfEntityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('aid')) {
      context.handle(
        _aidMeta,
        aid.isAcceptableOrUnknown(data['aid']!, _aidMeta),
      );
    } else if (isInserting) {
      context.missing(_aidMeta);
    }
    if (data.containsKey('bid')) {
      context.handle(
        _bidMeta,
        bid.isAcceptableOrUnknown(data['bid']!, _bidMeta),
      );
    } else if (isInserting) {
      context.missing(_bidMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('img')) {
      context.handle(
        _imgMeta,
        img.isAcceptableOrUnknown(data['img']!, _imgMeta),
      );
    } else if (isInserting) {
      context.missing(_imgMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {aid};
  @override
  BookshelfEntityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookshelfEntityData(
      aid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aid'],
      )!,
      bid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bid'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      img: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}img'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      )!,
    );
  }

  @override
  $BookshelfEntityTable createAlias(String alias) {
    return $BookshelfEntityTable(attachedDatabase, alias);
  }
}

class BookshelfEntityData extends DataClass
    implements Insertable<BookshelfEntityData> {
  final String aid;
  final String bid;
  final String url;
  final String title;
  final String img;
  final String classId;
  const BookshelfEntityData({
    required this.aid,
    required this.bid,
    required this.url,
    required this.title,
    required this.img,
    required this.classId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['aid'] = Variable<String>(aid);
    map['bid'] = Variable<String>(bid);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    map['img'] = Variable<String>(img);
    map['class_id'] = Variable<String>(classId);
    return map;
  }

  BookshelfEntityCompanion toCompanion(bool nullToAbsent) {
    return BookshelfEntityCompanion(
      aid: Value(aid),
      bid: Value(bid),
      url: Value(url),
      title: Value(title),
      img: Value(img),
      classId: Value(classId),
    );
  }

  factory BookshelfEntityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookshelfEntityData(
      aid: serializer.fromJson<String>(json['aid']),
      bid: serializer.fromJson<String>(json['bid']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      img: serializer.fromJson<String>(json['img']),
      classId: serializer.fromJson<String>(json['classId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'aid': serializer.toJson<String>(aid),
      'bid': serializer.toJson<String>(bid),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'img': serializer.toJson<String>(img),
      'classId': serializer.toJson<String>(classId),
    };
  }

  BookshelfEntityData copyWith({
    String? aid,
    String? bid,
    String? url,
    String? title,
    String? img,
    String? classId,
  }) => BookshelfEntityData(
    aid: aid ?? this.aid,
    bid: bid ?? this.bid,
    url: url ?? this.url,
    title: title ?? this.title,
    img: img ?? this.img,
    classId: classId ?? this.classId,
  );
  BookshelfEntityData copyWithCompanion(BookshelfEntityCompanion data) {
    return BookshelfEntityData(
      aid: data.aid.present ? data.aid.value : this.aid,
      bid: data.bid.present ? data.bid.value : this.bid,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      img: data.img.present ? data.img.value : this.img,
      classId: data.classId.present ? data.classId.value : this.classId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookshelfEntityData(')
          ..write('aid: $aid, ')
          ..write('bid: $bid, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('img: $img, ')
          ..write('classId: $classId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(aid, bid, url, title, img, classId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookshelfEntityData &&
          other.aid == this.aid &&
          other.bid == this.bid &&
          other.url == this.url &&
          other.title == this.title &&
          other.img == this.img &&
          other.classId == this.classId);
}

class BookshelfEntityCompanion extends UpdateCompanion<BookshelfEntityData> {
  final Value<String> aid;
  final Value<String> bid;
  final Value<String> url;
  final Value<String> title;
  final Value<String> img;
  final Value<String> classId;
  final Value<int> rowid;
  const BookshelfEntityCompanion({
    this.aid = const Value.absent(),
    this.bid = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.img = const Value.absent(),
    this.classId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookshelfEntityCompanion.insert({
    required String aid,
    required String bid,
    required String url,
    required String title,
    required String img,
    required String classId,
    this.rowid = const Value.absent(),
  }) : aid = Value(aid),
       bid = Value(bid),
       url = Value(url),
       title = Value(title),
       img = Value(img),
       classId = Value(classId);
  static Insertable<BookshelfEntityData> custom({
    Expression<String>? aid,
    Expression<String>? bid,
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? img,
    Expression<String>? classId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (aid != null) 'aid': aid,
      if (bid != null) 'bid': bid,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (img != null) 'img': img,
      if (classId != null) 'class_id': classId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookshelfEntityCompanion copyWith({
    Value<String>? aid,
    Value<String>? bid,
    Value<String>? url,
    Value<String>? title,
    Value<String>? img,
    Value<String>? classId,
    Value<int>? rowid,
  }) {
    return BookshelfEntityCompanion(
      aid: aid ?? this.aid,
      bid: bid ?? this.bid,
      url: url ?? this.url,
      title: title ?? this.title,
      img: img ?? this.img,
      classId: classId ?? this.classId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (aid.present) {
      map['aid'] = Variable<String>(aid.value);
    }
    if (bid.present) {
      map['bid'] = Variable<String>(bid.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (img.present) {
      map['img'] = Variable<String>(img.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookshelfEntityCompanion(')
          ..write('aid: $aid, ')
          ..write('bid: $bid, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('img: $img, ')
          ..write('classId: $classId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BrowsingHistoryEntityTable extends BrowsingHistoryEntity
    with TableInfo<$BrowsingHistoryEntityTable, BrowsingHistoryEntityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BrowsingHistoryEntityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _aidMeta = const VerificationMeta('aid');
  @override
  late final GeneratedColumn<String> aid = GeneratedColumn<String>(
    'aid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imgMeta = const VerificationMeta('img');
  @override
  late final GeneratedColumn<String> img = GeneratedColumn<String>(
    'img',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [aid, title, img, time];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'browsing_history_entity';
  @override
  VerificationContext validateIntegrity(
    Insertable<BrowsingHistoryEntityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('aid')) {
      context.handle(
        _aidMeta,
        aid.isAcceptableOrUnknown(data['aid']!, _aidMeta),
      );
    } else if (isInserting) {
      context.missing(_aidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('img')) {
      context.handle(
        _imgMeta,
        img.isAcceptableOrUnknown(data['img']!, _imgMeta),
      );
    } else if (isInserting) {
      context.missing(_imgMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {aid};
  @override
  BrowsingHistoryEntityData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BrowsingHistoryEntityData(
      aid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      img: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}img'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
    );
  }

  @override
  $BrowsingHistoryEntityTable createAlias(String alias) {
    return $BrowsingHistoryEntityTable(attachedDatabase, alias);
  }
}

class BrowsingHistoryEntityData extends DataClass
    implements Insertable<BrowsingHistoryEntityData> {
  final String aid;
  final String title;
  final String img;
  final DateTime time;
  const BrowsingHistoryEntityData({
    required this.aid,
    required this.title,
    required this.img,
    required this.time,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['aid'] = Variable<String>(aid);
    map['title'] = Variable<String>(title);
    map['img'] = Variable<String>(img);
    map['time'] = Variable<DateTime>(time);
    return map;
  }

  BrowsingHistoryEntityCompanion toCompanion(bool nullToAbsent) {
    return BrowsingHistoryEntityCompanion(
      aid: Value(aid),
      title: Value(title),
      img: Value(img),
      time: Value(time),
    );
  }

  factory BrowsingHistoryEntityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BrowsingHistoryEntityData(
      aid: serializer.fromJson<String>(json['aid']),
      title: serializer.fromJson<String>(json['title']),
      img: serializer.fromJson<String>(json['img']),
      time: serializer.fromJson<DateTime>(json['time']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'aid': serializer.toJson<String>(aid),
      'title': serializer.toJson<String>(title),
      'img': serializer.toJson<String>(img),
      'time': serializer.toJson<DateTime>(time),
    };
  }

  BrowsingHistoryEntityData copyWith({
    String? aid,
    String? title,
    String? img,
    DateTime? time,
  }) => BrowsingHistoryEntityData(
    aid: aid ?? this.aid,
    title: title ?? this.title,
    img: img ?? this.img,
    time: time ?? this.time,
  );
  BrowsingHistoryEntityData copyWithCompanion(
    BrowsingHistoryEntityCompanion data,
  ) {
    return BrowsingHistoryEntityData(
      aid: data.aid.present ? data.aid.value : this.aid,
      title: data.title.present ? data.title.value : this.title,
      img: data.img.present ? data.img.value : this.img,
      time: data.time.present ? data.time.value : this.time,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BrowsingHistoryEntityData(')
          ..write('aid: $aid, ')
          ..write('title: $title, ')
          ..write('img: $img, ')
          ..write('time: $time')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(aid, title, img, time);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BrowsingHistoryEntityData &&
          other.aid == this.aid &&
          other.title == this.title &&
          other.img == this.img &&
          other.time == this.time);
}

class BrowsingHistoryEntityCompanion
    extends UpdateCompanion<BrowsingHistoryEntityData> {
  final Value<String> aid;
  final Value<String> title;
  final Value<String> img;
  final Value<DateTime> time;
  final Value<int> rowid;
  const BrowsingHistoryEntityCompanion({
    this.aid = const Value.absent(),
    this.title = const Value.absent(),
    this.img = const Value.absent(),
    this.time = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BrowsingHistoryEntityCompanion.insert({
    required String aid,
    required String title,
    required String img,
    required DateTime time,
    this.rowid = const Value.absent(),
  }) : aid = Value(aid),
       title = Value(title),
       img = Value(img),
       time = Value(time);
  static Insertable<BrowsingHistoryEntityData> custom({
    Expression<String>? aid,
    Expression<String>? title,
    Expression<String>? img,
    Expression<DateTime>? time,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (aid != null) 'aid': aid,
      if (title != null) 'title': title,
      if (img != null) 'img': img,
      if (time != null) 'time': time,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BrowsingHistoryEntityCompanion copyWith({
    Value<String>? aid,
    Value<String>? title,
    Value<String>? img,
    Value<DateTime>? time,
    Value<int>? rowid,
  }) {
    return BrowsingHistoryEntityCompanion(
      aid: aid ?? this.aid,
      title: title ?? this.title,
      img: img ?? this.img,
      time: time ?? this.time,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (aid.present) {
      map['aid'] = Variable<String>(aid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (img.present) {
      map['img'] = Variable<String>(img.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BrowsingHistoryEntityCompanion(')
          ..write('aid: $aid, ')
          ..write('title: $title, ')
          ..write('img: $img, ')
          ..write('time: $time, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SearchHistoryEntityTable extends SearchHistoryEntity
    with TableInfo<$SearchHistoryEntityTable, SearchHistoryEntityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryEntityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keywordMeta = const VerificationMeta(
    'keyword',
  );
  @override
  late final GeneratedColumn<String> keyword = GeneratedColumn<String>(
    'keyword',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [keyword];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history_entity';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchHistoryEntityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('keyword')) {
      context.handle(
        _keywordMeta,
        keyword.isAcceptableOrUnknown(data['keyword']!, _keywordMeta),
      );
    } else if (isInserting) {
      context.missing(_keywordMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {keyword};
  @override
  SearchHistoryEntityData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistoryEntityData(
      keyword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keyword'],
      )!,
    );
  }

  @override
  $SearchHistoryEntityTable createAlias(String alias) {
    return $SearchHistoryEntityTable(attachedDatabase, alias);
  }
}

class SearchHistoryEntityData extends DataClass
    implements Insertable<SearchHistoryEntityData> {
  final String keyword;
  const SearchHistoryEntityData({required this.keyword});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['keyword'] = Variable<String>(keyword);
    return map;
  }

  SearchHistoryEntityCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryEntityCompanion(keyword: Value(keyword));
  }

  factory SearchHistoryEntityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistoryEntityData(
      keyword: serializer.fromJson<String>(json['keyword']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'keyword': serializer.toJson<String>(keyword)};
  }

  SearchHistoryEntityData copyWith({String? keyword}) =>
      SearchHistoryEntityData(keyword: keyword ?? this.keyword);
  SearchHistoryEntityData copyWithCompanion(SearchHistoryEntityCompanion data) {
    return SearchHistoryEntityData(
      keyword: data.keyword.present ? data.keyword.value : this.keyword,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryEntityData(')
          ..write('keyword: $keyword')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => keyword.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistoryEntityData && other.keyword == this.keyword);
}

class SearchHistoryEntityCompanion
    extends UpdateCompanion<SearchHistoryEntityData> {
  final Value<String> keyword;
  final Value<int> rowid;
  const SearchHistoryEntityCompanion({
    this.keyword = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchHistoryEntityCompanion.insert({
    required String keyword,
    this.rowid = const Value.absent(),
  }) : keyword = Value(keyword);
  static Insertable<SearchHistoryEntityData> custom({
    Expression<String>? keyword,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (keyword != null) 'keyword': keyword,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchHistoryEntityCompanion copyWith({
    Value<String>? keyword,
    Value<int>? rowid,
  }) {
    return SearchHistoryEntityCompanion(
      keyword: keyword ?? this.keyword,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (keyword.present) {
      map['keyword'] = Variable<String>(keyword.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryEntityCompanion(')
          ..write('keyword: $keyword, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadHistoryEntityTable extends ReadHistoryEntity
    with TableInfo<$ReadHistoryEntityTable, ReadHistoryEntityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadHistoryEntityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cidMeta = const VerificationMeta('cid');
  @override
  late final GeneratedColumn<String> cid = GeneratedColumn<String>(
    'cid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aidMeta = const VerificationMeta('aid');
  @override
  late final GeneratedColumn<String> aid = GeneratedColumn<String>(
    'aid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readerModeMeta = const VerificationMeta(
    'readerMode',
  );
  @override
  late final GeneratedColumn<int> readerMode = GeneratedColumn<int>(
    'reader_mode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDualPageMeta = const VerificationMeta(
    'isDualPage',
  );
  @override
  late final GeneratedColumn<bool> isDualPage = GeneratedColumn<bool>(
    'is_dual_page',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dual_page" IN (0, 1))',
    ),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<int> location = GeneratedColumn<int>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLatestMeta = const VerificationMeta(
    'isLatest',
  );
  @override
  late final GeneratedColumn<bool> isLatest = GeneratedColumn<bool>(
    'is_latest',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_latest" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    cid,
    aid,
    readerMode,
    isDualPage,
    location,
    progress,
    isLatest,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'read_history_entity';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadHistoryEntityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cid')) {
      context.handle(
        _cidMeta,
        cid.isAcceptableOrUnknown(data['cid']!, _cidMeta),
      );
    } else if (isInserting) {
      context.missing(_cidMeta);
    }
    if (data.containsKey('aid')) {
      context.handle(
        _aidMeta,
        aid.isAcceptableOrUnknown(data['aid']!, _aidMeta),
      );
    } else if (isInserting) {
      context.missing(_aidMeta);
    }
    if (data.containsKey('reader_mode')) {
      context.handle(
        _readerModeMeta,
        readerMode.isAcceptableOrUnknown(data['reader_mode']!, _readerModeMeta),
      );
    } else if (isInserting) {
      context.missing(_readerModeMeta);
    }
    if (data.containsKey('is_dual_page')) {
      context.handle(
        _isDualPageMeta,
        isDualPage.isAcceptableOrUnknown(
          data['is_dual_page']!,
          _isDualPageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isDualPageMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    } else if (isInserting) {
      context.missing(_progressMeta);
    }
    if (data.containsKey('is_latest')) {
      context.handle(
        _isLatestMeta,
        isLatest.isAcceptableOrUnknown(data['is_latest']!, _isLatestMeta),
      );
    } else if (isInserting) {
      context.missing(_isLatestMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cid};
  @override
  ReadHistoryEntityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadHistoryEntityData(
      cid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cid'],
      )!,
      aid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aid'],
      )!,
      readerMode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reader_mode'],
      )!,
      isDualPage: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dual_page'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}location'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
      isLatest: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_latest'],
      )!,
    );
  }

  @override
  $ReadHistoryEntityTable createAlias(String alias) {
    return $ReadHistoryEntityTable(attachedDatabase, alias);
  }
}

class ReadHistoryEntityData extends DataClass
    implements Insertable<ReadHistoryEntityData> {
  final String cid;
  final String aid;
  final int readerMode;
  final bool isDualPage;
  final int location;
  final int progress;
  final bool isLatest;
  const ReadHistoryEntityData({
    required this.cid,
    required this.aid,
    required this.readerMode,
    required this.isDualPage,
    required this.location,
    required this.progress,
    required this.isLatest,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cid'] = Variable<String>(cid);
    map['aid'] = Variable<String>(aid);
    map['reader_mode'] = Variable<int>(readerMode);
    map['is_dual_page'] = Variable<bool>(isDualPage);
    map['location'] = Variable<int>(location);
    map['progress'] = Variable<int>(progress);
    map['is_latest'] = Variable<bool>(isLatest);
    return map;
  }

  ReadHistoryEntityCompanion toCompanion(bool nullToAbsent) {
    return ReadHistoryEntityCompanion(
      cid: Value(cid),
      aid: Value(aid),
      readerMode: Value(readerMode),
      isDualPage: Value(isDualPage),
      location: Value(location),
      progress: Value(progress),
      isLatest: Value(isLatest),
    );
  }

  factory ReadHistoryEntityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadHistoryEntityData(
      cid: serializer.fromJson<String>(json['cid']),
      aid: serializer.fromJson<String>(json['aid']),
      readerMode: serializer.fromJson<int>(json['readerMode']),
      isDualPage: serializer.fromJson<bool>(json['isDualPage']),
      location: serializer.fromJson<int>(json['location']),
      progress: serializer.fromJson<int>(json['progress']),
      isLatest: serializer.fromJson<bool>(json['isLatest']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cid': serializer.toJson<String>(cid),
      'aid': serializer.toJson<String>(aid),
      'readerMode': serializer.toJson<int>(readerMode),
      'isDualPage': serializer.toJson<bool>(isDualPage),
      'location': serializer.toJson<int>(location),
      'progress': serializer.toJson<int>(progress),
      'isLatest': serializer.toJson<bool>(isLatest),
    };
  }

  ReadHistoryEntityData copyWith({
    String? cid,
    String? aid,
    int? readerMode,
    bool? isDualPage,
    int? location,
    int? progress,
    bool? isLatest,
  }) => ReadHistoryEntityData(
    cid: cid ?? this.cid,
    aid: aid ?? this.aid,
    readerMode: readerMode ?? this.readerMode,
    isDualPage: isDualPage ?? this.isDualPage,
    location: location ?? this.location,
    progress: progress ?? this.progress,
    isLatest: isLatest ?? this.isLatest,
  );
  ReadHistoryEntityData copyWithCompanion(ReadHistoryEntityCompanion data) {
    return ReadHistoryEntityData(
      cid: data.cid.present ? data.cid.value : this.cid,
      aid: data.aid.present ? data.aid.value : this.aid,
      readerMode: data.readerMode.present
          ? data.readerMode.value
          : this.readerMode,
      isDualPage: data.isDualPage.present
          ? data.isDualPage.value
          : this.isDualPage,
      location: data.location.present ? data.location.value : this.location,
      progress: data.progress.present ? data.progress.value : this.progress,
      isLatest: data.isLatest.present ? data.isLatest.value : this.isLatest,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadHistoryEntityData(')
          ..write('cid: $cid, ')
          ..write('aid: $aid, ')
          ..write('readerMode: $readerMode, ')
          ..write('isDualPage: $isDualPage, ')
          ..write('location: $location, ')
          ..write('progress: $progress, ')
          ..write('isLatest: $isLatest')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    cid,
    aid,
    readerMode,
    isDualPage,
    location,
    progress,
    isLatest,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadHistoryEntityData &&
          other.cid == this.cid &&
          other.aid == this.aid &&
          other.readerMode == this.readerMode &&
          other.isDualPage == this.isDualPage &&
          other.location == this.location &&
          other.progress == this.progress &&
          other.isLatest == this.isLatest);
}

class ReadHistoryEntityCompanion
    extends UpdateCompanion<ReadHistoryEntityData> {
  final Value<String> cid;
  final Value<String> aid;
  final Value<int> readerMode;
  final Value<bool> isDualPage;
  final Value<int> location;
  final Value<int> progress;
  final Value<bool> isLatest;
  final Value<int> rowid;
  const ReadHistoryEntityCompanion({
    this.cid = const Value.absent(),
    this.aid = const Value.absent(),
    this.readerMode = const Value.absent(),
    this.isDualPage = const Value.absent(),
    this.location = const Value.absent(),
    this.progress = const Value.absent(),
    this.isLatest = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadHistoryEntityCompanion.insert({
    required String cid,
    required String aid,
    required int readerMode,
    required bool isDualPage,
    required int location,
    required int progress,
    required bool isLatest,
    this.rowid = const Value.absent(),
  }) : cid = Value(cid),
       aid = Value(aid),
       readerMode = Value(readerMode),
       isDualPage = Value(isDualPage),
       location = Value(location),
       progress = Value(progress),
       isLatest = Value(isLatest);
  static Insertable<ReadHistoryEntityData> custom({
    Expression<String>? cid,
    Expression<String>? aid,
    Expression<int>? readerMode,
    Expression<bool>? isDualPage,
    Expression<int>? location,
    Expression<int>? progress,
    Expression<bool>? isLatest,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cid != null) 'cid': cid,
      if (aid != null) 'aid': aid,
      if (readerMode != null) 'reader_mode': readerMode,
      if (isDualPage != null) 'is_dual_page': isDualPage,
      if (location != null) 'location': location,
      if (progress != null) 'progress': progress,
      if (isLatest != null) 'is_latest': isLatest,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadHistoryEntityCompanion copyWith({
    Value<String>? cid,
    Value<String>? aid,
    Value<int>? readerMode,
    Value<bool>? isDualPage,
    Value<int>? location,
    Value<int>? progress,
    Value<bool>? isLatest,
    Value<int>? rowid,
  }) {
    return ReadHistoryEntityCompanion(
      cid: cid ?? this.cid,
      aid: aid ?? this.aid,
      readerMode: readerMode ?? this.readerMode,
      isDualPage: isDualPage ?? this.isDualPage,
      location: location ?? this.location,
      progress: progress ?? this.progress,
      isLatest: isLatest ?? this.isLatest,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cid.present) {
      map['cid'] = Variable<String>(cid.value);
    }
    if (aid.present) {
      map['aid'] = Variable<String>(aid.value);
    }
    if (readerMode.present) {
      map['reader_mode'] = Variable<int>(readerMode.value);
    }
    if (isDualPage.present) {
      map['is_dual_page'] = Variable<bool>(isDualPage.value);
    }
    if (location.present) {
      map['location'] = Variable<int>(location.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (isLatest.present) {
      map['is_latest'] = Variable<bool>(isLatest.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadHistoryEntityCompanion(')
          ..write('cid: $cid, ')
          ..write('aid: $aid, ')
          ..write('readerMode: $readerMode, ')
          ..write('isDualPage: $isDualPage, ')
          ..write('location: $location, ')
          ..write('progress: $progress, ')
          ..write('isLatest: $isLatest, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NovelDetailEntityTable extends NovelDetailEntity
    with TableInfo<$NovelDetailEntityTable, NovelDetailEntityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NovelDetailEntityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _aidMeta = const VerificationMeta('aid');
  @override
  late final GeneratedColumn<String> aid = GeneratedColumn<String>(
    'aid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [aid, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'novel_detail_entity';
  @override
  VerificationContext validateIntegrity(
    Insertable<NovelDetailEntityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('aid')) {
      context.handle(
        _aidMeta,
        aid.isAcceptableOrUnknown(data['aid']!, _aidMeta),
      );
    } else if (isInserting) {
      context.missing(_aidMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {aid};
  @override
  NovelDetailEntityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NovelDetailEntityData(
      aid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aid'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $NovelDetailEntityTable createAlias(String alias) {
    return $NovelDetailEntityTable(attachedDatabase, alias);
  }
}

class NovelDetailEntityData extends DataClass
    implements Insertable<NovelDetailEntityData> {
  final String aid;
  final String json;
  const NovelDetailEntityData({required this.aid, required this.json});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['aid'] = Variable<String>(aid);
    map['json'] = Variable<String>(json);
    return map;
  }

  NovelDetailEntityCompanion toCompanion(bool nullToAbsent) {
    return NovelDetailEntityCompanion(aid: Value(aid), json: Value(json));
  }

  factory NovelDetailEntityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NovelDetailEntityData(
      aid: serializer.fromJson<String>(json['aid']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'aid': serializer.toJson<String>(aid),
      'json': serializer.toJson<String>(json),
    };
  }

  NovelDetailEntityData copyWith({String? aid, String? json}) =>
      NovelDetailEntityData(aid: aid ?? this.aid, json: json ?? this.json);
  NovelDetailEntityData copyWithCompanion(NovelDetailEntityCompanion data) {
    return NovelDetailEntityData(
      aid: data.aid.present ? data.aid.value : this.aid,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NovelDetailEntityData(')
          ..write('aid: $aid, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(aid, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NovelDetailEntityData &&
          other.aid == this.aid &&
          other.json == this.json);
}

class NovelDetailEntityCompanion
    extends UpdateCompanion<NovelDetailEntityData> {
  final Value<String> aid;
  final Value<String> json;
  final Value<int> rowid;
  const NovelDetailEntityCompanion({
    this.aid = const Value.absent(),
    this.json = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NovelDetailEntityCompanion.insert({
    required String aid,
    required String json,
    this.rowid = const Value.absent(),
  }) : aid = Value(aid),
       json = Value(json);
  static Insertable<NovelDetailEntityData> custom({
    Expression<String>? aid,
    Expression<String>? json,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (aid != null) 'aid': aid,
      if (json != null) 'json': json,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NovelDetailEntityCompanion copyWith({
    Value<String>? aid,
    Value<String>? json,
    Value<int>? rowid,
  }) {
    return NovelDetailEntityCompanion(
      aid: aid ?? this.aid,
      json: json ?? this.json,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (aid.present) {
      map['aid'] = Variable<String>(aid.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NovelDetailEntityCompanion(')
          ..write('aid: $aid, ')
          ..write('json: $json, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BookshelfEntityTable bookshelfEntity = $BookshelfEntityTable(
    this,
  );
  late final $BrowsingHistoryEntityTable browsingHistoryEntity =
      $BrowsingHistoryEntityTable(this);
  late final $SearchHistoryEntityTable searchHistoryEntity =
      $SearchHistoryEntityTable(this);
  late final $ReadHistoryEntityTable readHistoryEntity =
      $ReadHistoryEntityTable(this);
  late final $NovelDetailEntityTable novelDetailEntity =
      $NovelDetailEntityTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bookshelfEntity,
    browsingHistoryEntity,
    searchHistoryEntity,
    readHistoryEntity,
    novelDetailEntity,
  ];
}

typedef $$BookshelfEntityTableCreateCompanionBuilder =
    BookshelfEntityCompanion Function({
      required String aid,
      required String bid,
      required String url,
      required String title,
      required String img,
      required String classId,
      Value<int> rowid,
    });
typedef $$BookshelfEntityTableUpdateCompanionBuilder =
    BookshelfEntityCompanion Function({
      Value<String> aid,
      Value<String> bid,
      Value<String> url,
      Value<String> title,
      Value<String> img,
      Value<String> classId,
      Value<int> rowid,
    });

class $$BookshelfEntityTableFilterComposer
    extends Composer<_$AppDatabase, $BookshelfEntityTable> {
  $$BookshelfEntityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get aid => $composableBuilder(
    column: $table.aid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bid => $composableBuilder(
    column: $table.bid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get img => $composableBuilder(
    column: $table.img,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookshelfEntityTableOrderingComposer
    extends Composer<_$AppDatabase, $BookshelfEntityTable> {
  $$BookshelfEntityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get aid => $composableBuilder(
    column: $table.aid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bid => $composableBuilder(
    column: $table.bid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get img => $composableBuilder(
    column: $table.img,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookshelfEntityTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookshelfEntityTable> {
  $$BookshelfEntityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get aid =>
      $composableBuilder(column: $table.aid, builder: (column) => column);

  GeneratedColumn<String> get bid =>
      $composableBuilder(column: $table.bid, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get img =>
      $composableBuilder(column: $table.img, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);
}

class $$BookshelfEntityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookshelfEntityTable,
          BookshelfEntityData,
          $$BookshelfEntityTableFilterComposer,
          $$BookshelfEntityTableOrderingComposer,
          $$BookshelfEntityTableAnnotationComposer,
          $$BookshelfEntityTableCreateCompanionBuilder,
          $$BookshelfEntityTableUpdateCompanionBuilder,
          (
            BookshelfEntityData,
            BaseReferences<
              _$AppDatabase,
              $BookshelfEntityTable,
              BookshelfEntityData
            >,
          ),
          BookshelfEntityData,
          PrefetchHooks Function()
        > {
  $$BookshelfEntityTableTableManager(
    _$AppDatabase db,
    $BookshelfEntityTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookshelfEntityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookshelfEntityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookshelfEntityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> aid = const Value.absent(),
                Value<String> bid = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> img = const Value.absent(),
                Value<String> classId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookshelfEntityCompanion(
                aid: aid,
                bid: bid,
                url: url,
                title: title,
                img: img,
                classId: classId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String aid,
                required String bid,
                required String url,
                required String title,
                required String img,
                required String classId,
                Value<int> rowid = const Value.absent(),
              }) => BookshelfEntityCompanion.insert(
                aid: aid,
                bid: bid,
                url: url,
                title: title,
                img: img,
                classId: classId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookshelfEntityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookshelfEntityTable,
      BookshelfEntityData,
      $$BookshelfEntityTableFilterComposer,
      $$BookshelfEntityTableOrderingComposer,
      $$BookshelfEntityTableAnnotationComposer,
      $$BookshelfEntityTableCreateCompanionBuilder,
      $$BookshelfEntityTableUpdateCompanionBuilder,
      (
        BookshelfEntityData,
        BaseReferences<
          _$AppDatabase,
          $BookshelfEntityTable,
          BookshelfEntityData
        >,
      ),
      BookshelfEntityData,
      PrefetchHooks Function()
    >;
typedef $$BrowsingHistoryEntityTableCreateCompanionBuilder =
    BrowsingHistoryEntityCompanion Function({
      required String aid,
      required String title,
      required String img,
      required DateTime time,
      Value<int> rowid,
    });
typedef $$BrowsingHistoryEntityTableUpdateCompanionBuilder =
    BrowsingHistoryEntityCompanion Function({
      Value<String> aid,
      Value<String> title,
      Value<String> img,
      Value<DateTime> time,
      Value<int> rowid,
    });

class $$BrowsingHistoryEntityTableFilterComposer
    extends Composer<_$AppDatabase, $BrowsingHistoryEntityTable> {
  $$BrowsingHistoryEntityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get aid => $composableBuilder(
    column: $table.aid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get img => $composableBuilder(
    column: $table.img,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BrowsingHistoryEntityTableOrderingComposer
    extends Composer<_$AppDatabase, $BrowsingHistoryEntityTable> {
  $$BrowsingHistoryEntityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get aid => $composableBuilder(
    column: $table.aid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get img => $composableBuilder(
    column: $table.img,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BrowsingHistoryEntityTableAnnotationComposer
    extends Composer<_$AppDatabase, $BrowsingHistoryEntityTable> {
  $$BrowsingHistoryEntityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get aid =>
      $composableBuilder(column: $table.aid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get img =>
      $composableBuilder(column: $table.img, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);
}

class $$BrowsingHistoryEntityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BrowsingHistoryEntityTable,
          BrowsingHistoryEntityData,
          $$BrowsingHistoryEntityTableFilterComposer,
          $$BrowsingHistoryEntityTableOrderingComposer,
          $$BrowsingHistoryEntityTableAnnotationComposer,
          $$BrowsingHistoryEntityTableCreateCompanionBuilder,
          $$BrowsingHistoryEntityTableUpdateCompanionBuilder,
          (
            BrowsingHistoryEntityData,
            BaseReferences<
              _$AppDatabase,
              $BrowsingHistoryEntityTable,
              BrowsingHistoryEntityData
            >,
          ),
          BrowsingHistoryEntityData,
          PrefetchHooks Function()
        > {
  $$BrowsingHistoryEntityTableTableManager(
    _$AppDatabase db,
    $BrowsingHistoryEntityTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BrowsingHistoryEntityTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BrowsingHistoryEntityTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BrowsingHistoryEntityTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> aid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> img = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BrowsingHistoryEntityCompanion(
                aid: aid,
                title: title,
                img: img,
                time: time,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String aid,
                required String title,
                required String img,
                required DateTime time,
                Value<int> rowid = const Value.absent(),
              }) => BrowsingHistoryEntityCompanion.insert(
                aid: aid,
                title: title,
                img: img,
                time: time,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BrowsingHistoryEntityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BrowsingHistoryEntityTable,
      BrowsingHistoryEntityData,
      $$BrowsingHistoryEntityTableFilterComposer,
      $$BrowsingHistoryEntityTableOrderingComposer,
      $$BrowsingHistoryEntityTableAnnotationComposer,
      $$BrowsingHistoryEntityTableCreateCompanionBuilder,
      $$BrowsingHistoryEntityTableUpdateCompanionBuilder,
      (
        BrowsingHistoryEntityData,
        BaseReferences<
          _$AppDatabase,
          $BrowsingHistoryEntityTable,
          BrowsingHistoryEntityData
        >,
      ),
      BrowsingHistoryEntityData,
      PrefetchHooks Function()
    >;
typedef $$SearchHistoryEntityTableCreateCompanionBuilder =
    SearchHistoryEntityCompanion Function({
      required String keyword,
      Value<int> rowid,
    });
typedef $$SearchHistoryEntityTableUpdateCompanionBuilder =
    SearchHistoryEntityCompanion Function({
      Value<String> keyword,
      Value<int> rowid,
    });

class $$SearchHistoryEntityTableFilterComposer
    extends Composer<_$AppDatabase, $SearchHistoryEntityTable> {
  $$SearchHistoryEntityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchHistoryEntityTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchHistoryEntityTable> {
  $$SearchHistoryEntityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchHistoryEntityTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchHistoryEntityTable> {
  $$SearchHistoryEntityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get keyword =>
      $composableBuilder(column: $table.keyword, builder: (column) => column);
}

class $$SearchHistoryEntityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchHistoryEntityTable,
          SearchHistoryEntityData,
          $$SearchHistoryEntityTableFilterComposer,
          $$SearchHistoryEntityTableOrderingComposer,
          $$SearchHistoryEntityTableAnnotationComposer,
          $$SearchHistoryEntityTableCreateCompanionBuilder,
          $$SearchHistoryEntityTableUpdateCompanionBuilder,
          (
            SearchHistoryEntityData,
            BaseReferences<
              _$AppDatabase,
              $SearchHistoryEntityTable,
              SearchHistoryEntityData
            >,
          ),
          SearchHistoryEntityData,
          PrefetchHooks Function()
        > {
  $$SearchHistoryEntityTableTableManager(
    _$AppDatabase db,
    $SearchHistoryEntityTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoryEntityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoryEntityTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SearchHistoryEntityTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> keyword = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  SearchHistoryEntityCompanion(keyword: keyword, rowid: rowid),
          createCompanionCallback:
              ({
                required String keyword,
                Value<int> rowid = const Value.absent(),
              }) => SearchHistoryEntityCompanion.insert(
                keyword: keyword,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchHistoryEntityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchHistoryEntityTable,
      SearchHistoryEntityData,
      $$SearchHistoryEntityTableFilterComposer,
      $$SearchHistoryEntityTableOrderingComposer,
      $$SearchHistoryEntityTableAnnotationComposer,
      $$SearchHistoryEntityTableCreateCompanionBuilder,
      $$SearchHistoryEntityTableUpdateCompanionBuilder,
      (
        SearchHistoryEntityData,
        BaseReferences<
          _$AppDatabase,
          $SearchHistoryEntityTable,
          SearchHistoryEntityData
        >,
      ),
      SearchHistoryEntityData,
      PrefetchHooks Function()
    >;
typedef $$ReadHistoryEntityTableCreateCompanionBuilder =
    ReadHistoryEntityCompanion Function({
      required String cid,
      required String aid,
      required int readerMode,
      required bool isDualPage,
      required int location,
      required int progress,
      required bool isLatest,
      Value<int> rowid,
    });
typedef $$ReadHistoryEntityTableUpdateCompanionBuilder =
    ReadHistoryEntityCompanion Function({
      Value<String> cid,
      Value<String> aid,
      Value<int> readerMode,
      Value<bool> isDualPage,
      Value<int> location,
      Value<int> progress,
      Value<bool> isLatest,
      Value<int> rowid,
    });

class $$ReadHistoryEntityTableFilterComposer
    extends Composer<_$AppDatabase, $ReadHistoryEntityTable> {
  $$ReadHistoryEntityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cid => $composableBuilder(
    column: $table.cid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aid => $composableBuilder(
    column: $table.aid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readerMode => $composableBuilder(
    column: $table.readerMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDualPage => $composableBuilder(
    column: $table.isDualPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLatest => $composableBuilder(
    column: $table.isLatest,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadHistoryEntityTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadHistoryEntityTable> {
  $$ReadHistoryEntityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cid => $composableBuilder(
    column: $table.cid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aid => $composableBuilder(
    column: $table.aid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readerMode => $composableBuilder(
    column: $table.readerMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDualPage => $composableBuilder(
    column: $table.isDualPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLatest => $composableBuilder(
    column: $table.isLatest,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadHistoryEntityTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadHistoryEntityTable> {
  $$ReadHistoryEntityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cid =>
      $composableBuilder(column: $table.cid, builder: (column) => column);

  GeneratedColumn<String> get aid =>
      $composableBuilder(column: $table.aid, builder: (column) => column);

  GeneratedColumn<int> get readerMode => $composableBuilder(
    column: $table.readerMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDualPage => $composableBuilder(
    column: $table.isDualPage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<bool> get isLatest =>
      $composableBuilder(column: $table.isLatest, builder: (column) => column);
}

class $$ReadHistoryEntityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadHistoryEntityTable,
          ReadHistoryEntityData,
          $$ReadHistoryEntityTableFilterComposer,
          $$ReadHistoryEntityTableOrderingComposer,
          $$ReadHistoryEntityTableAnnotationComposer,
          $$ReadHistoryEntityTableCreateCompanionBuilder,
          $$ReadHistoryEntityTableUpdateCompanionBuilder,
          (
            ReadHistoryEntityData,
            BaseReferences<
              _$AppDatabase,
              $ReadHistoryEntityTable,
              ReadHistoryEntityData
            >,
          ),
          ReadHistoryEntityData,
          PrefetchHooks Function()
        > {
  $$ReadHistoryEntityTableTableManager(
    _$AppDatabase db,
    $ReadHistoryEntityTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadHistoryEntityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadHistoryEntityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadHistoryEntityTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> cid = const Value.absent(),
                Value<String> aid = const Value.absent(),
                Value<int> readerMode = const Value.absent(),
                Value<bool> isDualPage = const Value.absent(),
                Value<int> location = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<bool> isLatest = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadHistoryEntityCompanion(
                cid: cid,
                aid: aid,
                readerMode: readerMode,
                isDualPage: isDualPage,
                location: location,
                progress: progress,
                isLatest: isLatest,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cid,
                required String aid,
                required int readerMode,
                required bool isDualPage,
                required int location,
                required int progress,
                required bool isLatest,
                Value<int> rowid = const Value.absent(),
              }) => ReadHistoryEntityCompanion.insert(
                cid: cid,
                aid: aid,
                readerMode: readerMode,
                isDualPage: isDualPage,
                location: location,
                progress: progress,
                isLatest: isLatest,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadHistoryEntityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadHistoryEntityTable,
      ReadHistoryEntityData,
      $$ReadHistoryEntityTableFilterComposer,
      $$ReadHistoryEntityTableOrderingComposer,
      $$ReadHistoryEntityTableAnnotationComposer,
      $$ReadHistoryEntityTableCreateCompanionBuilder,
      $$ReadHistoryEntityTableUpdateCompanionBuilder,
      (
        ReadHistoryEntityData,
        BaseReferences<
          _$AppDatabase,
          $ReadHistoryEntityTable,
          ReadHistoryEntityData
        >,
      ),
      ReadHistoryEntityData,
      PrefetchHooks Function()
    >;
typedef $$NovelDetailEntityTableCreateCompanionBuilder =
    NovelDetailEntityCompanion Function({
      required String aid,
      required String json,
      Value<int> rowid,
    });
typedef $$NovelDetailEntityTableUpdateCompanionBuilder =
    NovelDetailEntityCompanion Function({
      Value<String> aid,
      Value<String> json,
      Value<int> rowid,
    });

class $$NovelDetailEntityTableFilterComposer
    extends Composer<_$AppDatabase, $NovelDetailEntityTable> {
  $$NovelDetailEntityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get aid => $composableBuilder(
    column: $table.aid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NovelDetailEntityTableOrderingComposer
    extends Composer<_$AppDatabase, $NovelDetailEntityTable> {
  $$NovelDetailEntityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get aid => $composableBuilder(
    column: $table.aid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NovelDetailEntityTableAnnotationComposer
    extends Composer<_$AppDatabase, $NovelDetailEntityTable> {
  $$NovelDetailEntityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get aid =>
      $composableBuilder(column: $table.aid, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$NovelDetailEntityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NovelDetailEntityTable,
          NovelDetailEntityData,
          $$NovelDetailEntityTableFilterComposer,
          $$NovelDetailEntityTableOrderingComposer,
          $$NovelDetailEntityTableAnnotationComposer,
          $$NovelDetailEntityTableCreateCompanionBuilder,
          $$NovelDetailEntityTableUpdateCompanionBuilder,
          (
            NovelDetailEntityData,
            BaseReferences<
              _$AppDatabase,
              $NovelDetailEntityTable,
              NovelDetailEntityData
            >,
          ),
          NovelDetailEntityData,
          PrefetchHooks Function()
        > {
  $$NovelDetailEntityTableTableManager(
    _$AppDatabase db,
    $NovelDetailEntityTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NovelDetailEntityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NovelDetailEntityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NovelDetailEntityTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> aid = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NovelDetailEntityCompanion(
                aid: aid,
                json: json,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String aid,
                required String json,
                Value<int> rowid = const Value.absent(),
              }) => NovelDetailEntityCompanion.insert(
                aid: aid,
                json: json,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NovelDetailEntityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NovelDetailEntityTable,
      NovelDetailEntityData,
      $$NovelDetailEntityTableFilterComposer,
      $$NovelDetailEntityTableOrderingComposer,
      $$NovelDetailEntityTableAnnotationComposer,
      $$NovelDetailEntityTableCreateCompanionBuilder,
      $$NovelDetailEntityTableUpdateCompanionBuilder,
      (
        NovelDetailEntityData,
        BaseReferences<
          _$AppDatabase,
          $NovelDetailEntityTable,
          NovelDetailEntityData
        >,
      ),
      NovelDetailEntityData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BookshelfEntityTableTableManager get bookshelfEntity =>
      $$BookshelfEntityTableTableManager(_db, _db.bookshelfEntity);
  $$BrowsingHistoryEntityTableTableManager get browsingHistoryEntity =>
      $$BrowsingHistoryEntityTableTableManager(_db, _db.browsingHistoryEntity);
  $$SearchHistoryEntityTableTableManager get searchHistoryEntity =>
      $$SearchHistoryEntityTableTableManager(_db, _db.searchHistoryEntity);
  $$ReadHistoryEntityTableTableManager get readHistoryEntity =>
      $$ReadHistoryEntityTableTableManager(_db, _db.readHistoryEntity);
  $$NovelDetailEntityTableTableManager get novelDetailEntity =>
      $$NovelDetailEntityTableTableManager(_db, _db.novelDetailEntity);
}
