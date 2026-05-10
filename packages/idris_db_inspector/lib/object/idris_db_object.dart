class IDRISDBObject {
  const IDRISDBObject(this.data);

  final Map<String, dynamic> data;

  dynamic getValue(String propertyName) => data[propertyName];

  IDRISDBObject? getNested(String propertyName, {String? linkCollection}) {
    final data = this.data[propertyName] as Map<String, dynamic>?;
    if (data != null) {
      return IDRISDBObject(data);
    } else {
      return null;
    }
  }

  List<IDRISDBObject?>? getNestedList(
    String propertyName, {
    String? linkCollection,
  }) {
    final list = data[propertyName] as List<dynamic>?;
    if (list == null) {
      return null;
    }

    final objects = <IDRISDBObject?>[];
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      if (item == null) {
        objects.add(null);
      } else {
        objects.add(IDRISDBObject(item as Map<String, dynamic>));
      }
    }

    return objects;
  }
}
