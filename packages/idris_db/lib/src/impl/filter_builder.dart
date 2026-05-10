part of 'package:idris_db/idris_db.dart';

Pointer<CFilter> _buildFilter(Filter filter, List<Pointer<void>> pointers) {
  switch (filter) {
    case EqualCondition():
      final value = filter.value;
      if (value is double) {
        return IdrisDbCore.b.IDRISDB_filter_between(
          filter.property,
          _idrisDbValue(_adjustLowerFloatBound(value, true, filter.epsilon)),
          _idrisDbValue(_adjustUpperFloatBound(value, true, filter.epsilon)),
          filter.caseSensitive,
        );
      } else {
        return IdrisDbCore.b.IDRISDB_filter_equal(
          filter.property,
          _idrisDbValue(filter.value),
          filter.caseSensitive,
        );
      }
    case GreaterCondition():
      final rawValue = filter.value;
      final value = rawValue is double
          ? _adjustLowerFloatBound(rawValue, false, filter.epsilon)
          : rawValue;
      return IdrisDbCore.b.IDRISDB_filter_greater(
        filter.property,
        _idrisDbValue(value),
        filter.caseSensitive,
      );
    case GreaterOrEqualCondition():
      final rawValue = filter.value;
      final value = rawValue is double
          ? _adjustLowerFloatBound(rawValue, true, filter.epsilon)
          : rawValue;
      return IdrisDbCore.b.IDRISDB_filter_greater_or_equal(
        filter.property,
        _idrisDbValue(value),
        filter.caseSensitive,
      );
    case LessCondition():
      final rawValue = filter.value;
      final value = rawValue is double
          ? _adjustUpperFloatBound(rawValue, false, filter.epsilon)
          : rawValue;
      return IdrisDbCore.b.IDRISDB_filter_less(
        filter.property,
        _idrisDbValue(value),
        filter.caseSensitive,
      );
    case LessOrEqualCondition():
      final rawValue = filter.value;
      final value = rawValue is double
          ? _adjustUpperFloatBound(rawValue, true, filter.epsilon)
          : rawValue;
      return IdrisDbCore.b.IDRISDB_filter_less_or_equal(
        filter.property,
        _idrisDbValue(value),
        filter.caseSensitive,
      );
    case BetweenCondition():
      final rawLower = filter.lower;
      final lower = rawLower is double
          ? _adjustLowerFloatBound(rawLower, true, filter.epsilon)
          : rawLower;
      final rawUpper = filter.upper;
      final upper = rawUpper is double
          ? _adjustUpperFloatBound(rawUpper, true, filter.epsilon)
          : rawUpper;
      return IdrisDbCore.b.IDRISDB_filter_between(
        filter.property,
        _idrisDbValue(lower),
        _idrisDbValue(upper),
        filter.caseSensitive,
      );
    case StartsWithCondition():
      return IdrisDbCore.b.IDRISDB_filter_string_starts_with(
        filter.property,
        _idrisDbValue(filter.value),
        filter.caseSensitive,
      );
    case EndsWithCondition():
      return IdrisDbCore.b.IDRISDB_filter_string_ends_with(
        filter.property,
        _idrisDbValue(filter.value),
        filter.caseSensitive,
      );
    case ContainsCondition():
      return IdrisDbCore.b.IDRISDB_filter_string_contains(
        filter.property,
        _idrisDbValue(filter.value),
        filter.caseSensitive,
      );
    case MatchesCondition():
      return IdrisDbCore.b.IDRISDB_filter_string_matches(
        filter.property,
        _idrisDbValue(filter.wildcard),
        filter.caseSensitive,
      );
    case IsNullCondition():
      return IdrisDbCore.b.IDRISDB_filter_is_null(filter.property);
    case AndGroup():
      if (filter.filters.length == 1) {
        return _buildFilter(filter.filters[0], pointers);
      } else {
        final filtersPtrPtr = malloc<Pointer<CFilter>>(filter.filters.length);
        pointers.add(filtersPtrPtr);
        for (var i = 0; i < filter.filters.length; i++) {
          filtersPtrPtr.setPtrAt(i, _buildFilter(filter.filters[i], pointers));
        }
        return IdrisDbCore.b.IDRISDB_filter_and(filtersPtrPtr, filter.filters.length);
      }
    case OrGroup():
      if (filter.filters.length == 1) {
        return _buildFilter(filter.filters[0], pointers);
      } else {
        final filtersPtrPtr = malloc<Pointer<CFilter>>(filter.filters.length);
        pointers.add(filtersPtrPtr);
        for (var i = 0; i < filter.filters.length; i++) {
          filtersPtrPtr.setPtrAt(i, _buildFilter(filter.filters[i], pointers));
        }
        return IdrisDbCore.b.IDRISDB_filter_or(filtersPtrPtr, filter.filters.length);
      }
    case NotGroup():
      return IdrisDbCore.b.IDRISDB_filter_not(_buildFilter(filter.filter, pointers));
    case ObjectFilter():
      return IdrisDbCore.b.IDRISDB_filter_nested(
        filter.property,
        _buildFilter(filter.filter, pointers),
      );
  }
}

Pointer<CIDRISDBValue> _idrisDbValue(Object? value) {
  if (value == null) {
    return nullptr;
  } else if (value is double) {
    return IdrisDbCore.b.IDRISDB_value_real(value);
    // Need to check int separately from num for proper type handling
    // ignore: avoid_double_and_int_checks
  } else if (value is int) {
    return IdrisDbCore.b.IDRISDB_value_integer(value);
  } else if (value is String) {
    return IdrisDbCore.b.IDRISDB_value_string(IdrisDbCore._toNativeString(value));
  } else if (value is bool) {
    return IdrisDbCore.b.IDRISDB_value_bool(value);
  } else if (value is DateTime) {
    return IdrisDbCore.b.IDRISDB_value_integer(value.toUtc().microsecondsSinceEpoch);
  } else {
    throw ArgumentError('Unsupported filter value type: ${value.runtimeType}');
  }
}

double _adjustLowerFloatBound(double value, bool include, double epsilon) {
  if (value.isFinite) {
    if (include) {
      return value - epsilon;
    } else {
      return value + epsilon;
    }
  } else {
    return value;
  }
}

double _adjustUpperFloatBound(double value, bool include, double epsilon) {
  if (value.isFinite) {
    if (include) {
      return value + epsilon;
    } else {
      return value - epsilon;
    }
  } else {
    return value;
  }
}
