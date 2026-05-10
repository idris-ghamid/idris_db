import 'package:flutter/material.dart';
import 'package:idris_db/idris_db.dart';
import 'package:idris_db_inspector/object/idris_db_object.dart';
import 'package:idris_db_inspector/object/object_view.dart';
import 'package:idris_db_inspector/object/property_builder.dart';
import 'package:idris_db_inspector/object/property_value.dart';

class EmbeddedPropertyView extends StatelessWidget {
  const EmbeddedPropertyView({
    required this.property,
    required this.schemas,
    required this.object,
    required this.onUpdate,
    super.key,
  });

  final IdrisDbPropertySchema property;
  final Map<String, IdrisDbSchema> schemas;
  final IDRISDBObject object;
  final void Function(String path, dynamic value) onUpdate;

  @override
  Widget build(BuildContext context) {
    if (property.type == IdrisDbType.object) {
      final child = object.getNested(property.name);
      return PropertyBuilder(
        property: property.name,
        type: property.target!,
        value: child == null ? const NullValue() : null,
        children: [
          if (child != null)
            ObjectView(
              schemaName: property.target!,
              schemas: schemas,
              object: child,
              onUpdate: onUpdate,
            ),
        ],
      );
    } else {
      // Handle objectList type
      final children = object.getNestedList(property.name);
      final childrenLength = children != null ? '(${children.length})' : '';
      return PropertyBuilder(
        property: property.name,
        type: 'List<${property.target}> $childrenLength',
        value: children == null ? const NullValue() : null,
        children: [
          for (var i = 0; i < (children?.length ?? 0); i++)
            PropertyBuilder(
              property: '[$i]',
              type: property.target!,
              value: children![i] == null ? const NullValue() : null,
              children: [
                if (children[i] != null)
                  ObjectView(
                    schemaName: property.target!,
                    schemas: schemas,
                    object: children[i]!,
                    onUpdate: (path, value) {
                      onUpdate('$i.$path', value);
                    },
                  ),
              ],
            ),
        ],
      );
    }
  }
}
