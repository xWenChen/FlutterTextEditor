
class BackupOperationInfo {
  OperationType operationType;
  String title;
  String desc;

  BackupOperationInfo({
    this.operationType = OperationType.backup,
    this.title = '',
    this.desc = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupOperationInfo &&
          runtimeType == other.runtimeType &&
          operationType == other.operationType &&
          title == other.title &&
          desc == other.desc;

  @override
  int get hashCode => Object.hash(operationType, title, desc);

  @override
  String toString() {
    return 'BackupOperationInfo{operationType: $operationType, title: $title, desc: $desc}';
  }
}

enum OperationType {
  backup,
  restore;
}

enum OperationState {
  idle,
  waitBackup,
  inBackup,
  endBackup,
  waitRestore,
  inRestore,
  endRestore;
}