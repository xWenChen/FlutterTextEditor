// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_item_database.dart';

// ignore_for_file: type=lint
class $FileItemsTable extends FileItems
    with TableInfo<$FileItemsTable, FileItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FileItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentIdMeta = const VerificationMeta(
    'contentId',
  );
  @override
  late final GeneratedColumn<String> contentId = GeneratedColumn<String>(
    'content_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updateTimeMeta = const VerificationMeta(
    'updateTime',
  );
  @override
  late final GeneratedColumn<int> updateTime = GeneratedColumn<int>(
    'update_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contentId,
    filePath,
    title,
    updateTime,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<FileItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content_id')) {
      context.handle(
        _contentIdMeta,
        contentId.isAcceptableOrUnknown(data['content_id']!, _contentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contentIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('update_time')) {
      context.handle(
        _updateTimeMeta,
        updateTime.isAcceptableOrUnknown(data['update_time']!, _updateTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_updateTimeMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    } else if (isInserting) {
      context.missing(_isDeletedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FileItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      updateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}update_time'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $FileItemsTable createAlias(String alias) {
    return $FileItemsTable(attachedDatabase, alias);
  }
}

class FileItem extends DataClass implements Insertable<FileItem> {
  /// 主键：自增 Long 类型 (Int64)
  /// 调用 .autoIncrement() 时，Drift 内部会自动为该字段添加 PRIMARY KEY 约束。
  final int id;

  /// 内容 ID (对应 Room 的 ColumnInfo)
  final String contentId;

  /// 文件地址：允许为空 (对应 Room 的 String?)
  final String? filePath;

  /// 文件标题：允许为空
  final String? title;

  /// 更新时间：Drift 可以直接存 DateTime，也可以存 Int64 毫秒
  final int updateTime;

  /// 是否删除：布尔类型
  final bool isDeleted;
  const FileItem({
    required this.id,
    required this.contentId,
    this.filePath,
    this.title,
    required this.updateTime,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content_id'] = Variable<String>(contentId);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['update_time'] = Variable<int>(updateTime);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  FileItemsCompanion toCompanion(bool nullToAbsent) {
    return FileItemsCompanion(
      id: Value(id),
      contentId: Value(contentId),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      updateTime: Value(updateTime),
      isDeleted: Value(isDeleted),
    );
  }

  factory FileItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileItem(
      id: serializer.fromJson<int>(json['id']),
      contentId: serializer.fromJson<String>(json['contentId']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      title: serializer.fromJson<String?>(json['title']),
      updateTime: serializer.fromJson<int>(json['updateTime']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contentId': serializer.toJson<String>(contentId),
      'filePath': serializer.toJson<String?>(filePath),
      'title': serializer.toJson<String?>(title),
      'updateTime': serializer.toJson<int>(updateTime),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  FileItem copyWith({
    int? id,
    String? contentId,
    Value<String?> filePath = const Value.absent(),
    Value<String?> title = const Value.absent(),
    int? updateTime,
    bool? isDeleted,
  }) => FileItem(
    id: id ?? this.id,
    contentId: contentId ?? this.contentId,
    filePath: filePath.present ? filePath.value : this.filePath,
    title: title.present ? title.value : this.title,
    updateTime: updateTime ?? this.updateTime,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  FileItem copyWithCompanion(FileItemsCompanion data) {
    return FileItem(
      id: data.id.present ? data.id.value : this.id,
      contentId: data.contentId.present ? data.contentId.value : this.contentId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      title: data.title.present ? data.title.value : this.title,
      updateTime: data.updateTime.present
          ? data.updateTime.value
          : this.updateTime,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FileItem(')
          ..write('id: $id, ')
          ..write('contentId: $contentId, ')
          ..write('filePath: $filePath, ')
          ..write('title: $title, ')
          ..write('updateTime: $updateTime, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, contentId, filePath, title, updateTime, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileItem &&
          other.id == this.id &&
          other.contentId == this.contentId &&
          other.filePath == this.filePath &&
          other.title == this.title &&
          other.updateTime == this.updateTime &&
          other.isDeleted == this.isDeleted);
}

class FileItemsCompanion extends UpdateCompanion<FileItem> {
  final Value<int> id;
  final Value<String> contentId;
  final Value<String?> filePath;
  final Value<String?> title;
  final Value<int> updateTime;
  final Value<bool> isDeleted;
  const FileItemsCompanion({
    this.id = const Value.absent(),
    this.contentId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.title = const Value.absent(),
    this.updateTime = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  FileItemsCompanion.insert({
    this.id = const Value.absent(),
    required String contentId,
    this.filePath = const Value.absent(),
    this.title = const Value.absent(),
    required int updateTime,
    required bool isDeleted,
  }) : contentId = Value(contentId),
       updateTime = Value(updateTime),
       isDeleted = Value(isDeleted);
  static Insertable<FileItem> custom({
    Expression<int>? id,
    Expression<String>? contentId,
    Expression<String>? filePath,
    Expression<String>? title,
    Expression<int>? updateTime,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentId != null) 'content_id': contentId,
      if (filePath != null) 'file_path': filePath,
      if (title != null) 'title': title,
      if (updateTime != null) 'update_time': updateTime,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  FileItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? contentId,
    Value<String?>? filePath,
    Value<String?>? title,
    Value<int>? updateTime,
    Value<bool>? isDeleted,
  }) {
    return FileItemsCompanion(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      updateTime: updateTime ?? this.updateTime,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contentId.present) {
      map['content_id'] = Variable<String>(contentId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (updateTime.present) {
      map['update_time'] = Variable<int>(updateTime.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileItemsCompanion(')
          ..write('id: $id, ')
          ..write('contentId: $contentId, ')
          ..write('filePath: $filePath, ')
          ..write('title: $title, ')
          ..write('updateTime: $updateTime, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

abstract class _$FileItemDatabase extends GeneratedDatabase {
  _$FileItemDatabase(QueryExecutor e) : super(e);
  $FileItemDatabaseManager get managers => $FileItemDatabaseManager(this);
  late final $FileItemsTable fileItems = $FileItemsTable(this);
  late final FileItemDao fileItemDao = FileItemDao(this as FileItemDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [fileItems];
}

typedef $$FileItemsTableCreateCompanionBuilder =
    FileItemsCompanion Function({
      Value<int> id,
      required String contentId,
      Value<String?> filePath,
      Value<String?> title,
      required int updateTime,
      required bool isDeleted,
    });
typedef $$FileItemsTableUpdateCompanionBuilder =
    FileItemsCompanion Function({
      Value<int> id,
      Value<String> contentId,
      Value<String?> filePath,
      Value<String?> title,
      Value<int> updateTime,
      Value<bool> isDeleted,
    });

class $$FileItemsTableFilterComposer
    extends Composer<_$FileItemDatabase, $FileItemsTable> {
  $$FileItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updateTime => $composableBuilder(
    column: $table.updateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FileItemsTableOrderingComposer
    extends Composer<_$FileItemDatabase, $FileItemsTable> {
  $$FileItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updateTime => $composableBuilder(
    column: $table.updateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FileItemsTableAnnotationComposer
    extends Composer<_$FileItemDatabase, $FileItemsTable> {
  $$FileItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentId =>
      $composableBuilder(column: $table.contentId, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get updateTime => $composableBuilder(
    column: $table.updateTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$FileItemsTableTableManager
    extends
        RootTableManager<
          _$FileItemDatabase,
          $FileItemsTable,
          FileItem,
          $$FileItemsTableFilterComposer,
          $$FileItemsTableOrderingComposer,
          $$FileItemsTableAnnotationComposer,
          $$FileItemsTableCreateCompanionBuilder,
          $$FileItemsTableUpdateCompanionBuilder,
          (
            FileItem,
            BaseReferences<_$FileItemDatabase, $FileItemsTable, FileItem>,
          ),
          FileItem,
          PrefetchHooks Function()
        > {
  $$FileItemsTableTableManager(_$FileItemDatabase db, $FileItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FileItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FileItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FileItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> contentId = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<int> updateTime = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
              }) => FileItemsCompanion(
                id: id,
                contentId: contentId,
                filePath: filePath,
                title: title,
                updateTime: updateTime,
                isDeleted: isDeleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String contentId,
                Value<String?> filePath = const Value.absent(),
                Value<String?> title = const Value.absent(),
                required int updateTime,
                required bool isDeleted,
              }) => FileItemsCompanion.insert(
                id: id,
                contentId: contentId,
                filePath: filePath,
                title: title,
                updateTime: updateTime,
                isDeleted: isDeleted,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FileItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$FileItemDatabase,
      $FileItemsTable,
      FileItem,
      $$FileItemsTableFilterComposer,
      $$FileItemsTableOrderingComposer,
      $$FileItemsTableAnnotationComposer,
      $$FileItemsTableCreateCompanionBuilder,
      $$FileItemsTableUpdateCompanionBuilder,
      (FileItem, BaseReferences<_$FileItemDatabase, $FileItemsTable, FileItem>),
      FileItem,
      PrefetchHooks Function()
    >;

class $FileItemDatabaseManager {
  final _$FileItemDatabase _db;
  $FileItemDatabaseManager(this._db);
  $$FileItemsTableTableManager get fileItems =>
      $$FileItemsTableTableManager(_db, _db.fileItems);
}
