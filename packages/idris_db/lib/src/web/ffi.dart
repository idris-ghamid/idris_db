import 'dart:typed_data';

import 'package:idris_db/idris_db.dart';
import 'package:idris_db/src/web/web.dart';

/// @nodoc
typedef Pointer<T> = int;

/// @nodoc
class NativeType {}

/// @nodoc
@tryInline
Pointer<T> ptrFromAddress<T>(int addr) => addr;

// Late is required for lazy initialization after IdrisDbCore is ready
/// @nodoc
JSIDRISDB get b => (IdrisDbCore.b as Object) as JSIDRISDB;

/// @nodoc
extension PointerX on int {
  /// @nodoc
  @tryInline
  Pointer<T> cast<T>() => this;

  /// @nodoc
  @tryInline
  Pointer<void> get ptrValue => b.u32Heap[address ~/ 4];

  /// @nodoc
  @tryInline
  set ptrValue(Pointer<void> ptr) => b.u32Heap[address ~/ 4] = ptr;

  /// @nodoc
  @tryInline
  void setPtrAt(int index, Pointer<void> ptr) {
    b.u32Heap[address ~/ 4 + index] = ptr;
  }

  /// @nodoc
  @tryInline
  bool get boolValue => b.u8Heap[address] != 0;

  /// @nodoc
  @tryInline
  int get u32Value => b.u32Heap[address ~/ 4];

  /// @nodoc
  @tryInline
  int get address => this;

  /// @nodoc
  @tryInline
  Uint8List asU8List(int length) =>
      b.u8Heap.buffer.asUint8List(address, length);

  /// @nodoc
  @tryInline
  Uint16List asU16List(int length) =>
      b.u16Heap.buffer.asUint16List(address, length);
}

/// @nodoc
const nullptr = 0;

/// @nodoc
class Native<T> {
  /// ignored to avoid "unused constructor parameters" warning
  // ignore: avoid_unused_constructor_parameters
  const Native({String? symbol});
}

/// @nodoc
class Void {}

/// @nodoc
class Bool {}

/// @nodoc
class Uint8 {}

/// @nodoc
class Int8 {}

/// @nodoc
class Uint16 {}

/// @nodoc
class Uint32 {}

/// @nodoc
typedef Char = Uint8;

/// @nodoc
class Int32 {}

/// @nodoc
class Int64 {}

/// @nodoc
class Float {}

/// @nodoc
class Double {}

/// @nodoc
class Opaque {}

/// @nodoc
class NativeFunction<T> {}

/// @nodoc
const Map<Type, int> _sizes = {
  int: 4, // pointer
  Void: 0,
  Bool: 1,
  Uint8: 1,
  Int8: 1,
  Uint16: 2,
  Uint32: 4,
  Int32: 4,
  Int64: 8,
  Float: 4,
  Double: 8,
};

/// @nodoc
Pointer<T> malloc<T>([int length = 1]) {
  final addr = b.malloc(length * _sizes[T]!);
  return addr;
}

/// @nodoc
void free(Pointer<void> ptr) {
  b.free(ptr.address);
}
