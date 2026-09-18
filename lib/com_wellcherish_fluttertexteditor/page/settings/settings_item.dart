
class SettingsItem {
  String id;
  String name;
  String desc;
  String pageRouteName;

  SettingsItem({
    this.id = '',
    this.name = '',
    this.desc = '',
    this.pageRouteName = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SettingsItem && runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              desc == other.desc &&
              pageRouteName == other.pageRouteName;

  @override
  int get hashCode => Object.hash(id, name, desc, pageRouteName);

  @override
  String toString() {
    return '''{
      "id": $id,
      "name": $name,
      "desc": $desc,
      "pageRouteName": $pageRouteName,
    }''';
  }

  static const String dataSyncId = "dataSync";
}