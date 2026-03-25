// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_item_dao.dart';

// ignore_for_file: type=lint
mixin _$FileItemDaoMixin on DatabaseAccessor<FileItemDatabase> {
  $FileItemsTable get fileItems => attachedDatabase.fileItems;
  FileItemDaoManager get managers => FileItemDaoManager(this);
}

class FileItemDaoManager {
  final _$FileItemDaoMixin _db;
  FileItemDaoManager(this._db);
  $$FileItemsTableTableManager get fileItems =>
      $$FileItemsTableTableManager(_db.attachedDatabase, _db.fileItems);
}
