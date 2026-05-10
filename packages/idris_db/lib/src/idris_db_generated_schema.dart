part of 'package:idris_db/idris_db.dart';

/// @nodoc
@protected
final class IdrisDbGeneratedSchema {
  /// @nodoc
  const IdrisDbGeneratedSchema({
    required this.schema,
    required this.converter,
    this.embeddedSchemas,
    this.getEmbeddedSchemas,
  });

  /// @nodoc
  @protected
  final IdrisDbSchema schema;

  /// @nodoc
  @protected
  final List<IdrisDbGeneratedSchema>? embeddedSchemas;

  /// @nodoc
  @protected
  final List<IdrisDbGeneratedSchema> Function()? getEmbeddedSchemas;

  /// @nodoc
  @protected
  List<IdrisDbGeneratedSchema> get allEmbeddedSchemas =>
      embeddedSchemas ?? getEmbeddedSchemas?.call() ?? [];

  /// @nodoc
  @protected
  bool get isEmbedded => embeddedSchemas == null && getEmbeddedSchemas == null;

  /// @nodoc
  @protected
  final IDRISDBObjectConverter<dynamic, dynamic> converter;
}

/// @nodoc
@protected
final class IDRISDBObjectConverter<ID, OBJ> {
  /// @nodoc
  const IDRISDBObjectConverter({
    required this.serialize,
    required this.deserialize,
    this.deserializeProperty,
  });

  /// @nodoc
  final Serialize<OBJ> serialize;

  /// @nodoc
  final Deserialize<OBJ> deserialize;

  /// @nodoc
  final DeserializeProp? deserializeProperty;

  /// @nodoc
  Type get type => OBJ;

  /// @nodoc
  T withType<T>(
    T Function<TId, TObj>(IDRISDBObjectConverter<TId, TObj> converter) f,
  ) => f(this);
}

/// @nodoc
typedef GetId<OBJ> = int Function(OBJ);

/// @nodoc
typedef IDRISDBWriter = Pointer<CIdrisDbWriter>;

/// @nodoc
typedef IDRISDBReader = Pointer<CIdrisDbReader>;

/// @nodoc
typedef Serialize<T> = int Function(IDRISDBWriter writer, T object);

/// @nodoc
typedef Deserialize<T> = T Function(IDRISDBReader reader);

/// @nodoc
typedef DeserializeProp = dynamic Function(IDRISDBReader reader, int property);
