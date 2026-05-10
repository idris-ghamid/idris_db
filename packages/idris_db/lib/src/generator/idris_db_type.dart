part of 'idris_db_generator.dart';

extension on DartType {
  bool get isDartCoreDateTime =>
      element != null &&
      element!.name == 'DateTime' &&
      element!.library?.name == 'dart.core';

  IdrisDbType? get _primitiveIDRISDBType {
    if (isDartCoreBool) {
      return IdrisDbType.bool;
    } else if (isDartCoreInt) {
      if (alias?.element.name == 'byte') {
        return IdrisDbType.byte;
      } else if (alias?.element.name == 'short') {
        return IdrisDbType.int;
      } else {
        return IdrisDbType.long;
      }
    } else if (isDartCoreDouble) {
      if (alias?.element.name == 'float') {
        return IdrisDbType.float;
      } else {
        return IdrisDbType.double;
      }
    } else if (isDartCoreString) {
      return IdrisDbType.string;
    } else if (isDartCoreDateTime) {
      return IdrisDbType.dateTime;
    } else if (this is DynamicType) {
      return IdrisDbType.json;
    } else if (element != null && element!.embeddedAnnotation != null) {
      return IdrisDbType.object;
    }

    return null;
  }

  DartType get scalarType {
    if (isDartCoreList) {
      final parameterizedType = this as ParameterizedType;
      final typeArguments = parameterizedType.typeArguments;
      if (typeArguments.isNotEmpty) {
        return typeArguments[0];
      }
    }
    return this;
  }

  IdrisDbType? get propertyType {
    final primitiveType = _primitiveIDRISDBType;
    if (primitiveType != null) {
      return primitiveType;
    }

    if (isDartCoreList) {
      switch (scalarType._primitiveIDRISDBType) {
        case IdrisDbType.bool:
          return IdrisDbType.boolList;
        case IdrisDbType.byte:
          return IdrisDbType.byteList;
        case IdrisDbType.int:
          return IdrisDbType.intList;
        case IdrisDbType.float:
          return IdrisDbType.floatList;
        case IdrisDbType.long:
          return IdrisDbType.longList;
        case IdrisDbType.double:
          return IdrisDbType.doubleList;
        case IdrisDbType.dateTime:
          return IdrisDbType.dateTimeList;
        case IdrisDbType.string:
          return IdrisDbType.stringList;
        case IdrisDbType.object:
          return IdrisDbType.objectList;
        case IdrisDbType.json:
          return IdrisDbType.json;
        // Needed for exhaustiveness checking
        // ignore: no_default_cases
        default:
          return null;
      }
    } else if (isDartCoreMap) {
      final keyType = (this as ParameterizedType).typeArguments[0];
      final valueType = (this as ParameterizedType).typeArguments[1];
      if (keyType.isDartCoreString && valueType is DynamicType) {
        return IdrisDbType.json;
      }
    }

    return null;
  }

  bool get supportsJsonConversion {
    final element = this.element;
    if (element is ClassElement) {
      // check if the class has a toJson() method returning Map<String,dynamic>
      // and a fromJson factory
      final toJson = element.getMethod('toJson');
      final fromJson = element.getNamedConstructor('fromJson');
      if (toJson != null && fromJson != null) {
        final toJsonReturnType = toJson.returnType;
        final fromJsonParameterType =
            fromJson.formalParameters.firstOrNull?.type;
        if (toJsonReturnType.isDartCoreMap &&
            toJsonReturnType is ParameterizedType &&
            toJsonReturnType.typeArguments[0].isDartCoreString &&
            toJsonReturnType.typeArguments[1] is DynamicType &&
            fromJsonParameterType != null &&
            fromJsonParameterType.isDartCoreMap &&
            fromJsonParameterType is ParameterizedType &&
            fromJsonParameterType.typeArguments[0].isDartCoreString &&
            fromJsonParameterType.typeArguments[1] is DynamicType) {
          return true;
        }
      }
    }
    return false;
  }
}
