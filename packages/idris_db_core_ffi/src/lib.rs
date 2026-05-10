#![allow(clippy::missing_safety_doc)]

use core::slice;
use idris_db_core::core::cursor::IDRISDBCursor;
use idris_db_core::core::instance::IDRISDBInstance;
use idris_db_core::core::reader::IDRISDBReader;
use idris_db_core::core::value::IDRISDBValue;
use idris_db_core::core::writer::IDRISDBWriter;

#[cfg(feature = "native")]
use idris_db_core::native::native_instance::NativeInstance;

#[cfg(feature = "sqlite")]
use idris_db_core::sqlite::sqlite_instance::SQLiteInstance;

#[macro_use]
mod error;
pub mod cursor;
pub mod dart;
pub mod filter;
pub mod insert;
pub mod instance;
pub mod query;
pub mod reader;
pub mod update;
pub mod value;
pub mod watcher;
pub mod writer;

#[cfg(all(feature = "sqlite", target_arch = "wasm32", target_os = "unknown"))]
pub mod web;

#[cfg(feature = "native")]
type NInstance = <NativeInstance as IDRISDBInstance>::Instance;
#[cfg(feature = "sqlite")]
type SInstance = <SQLiteInstance as IDRISDBInstance>::Instance;

#[cfg(feature = "native")]
type NTxn = <NativeInstance as IDRISDBInstance>::Txn;
#[cfg(feature = "sqlite")]
type STxn = <SQLiteInstance as IDRISDBInstance>::Txn;

#[cfg(feature = "native")]
type NInsert<'a> = <NativeInstance as IDRISDBInstance>::Insert<'a>;
#[cfg(feature = "sqlite")]
type SInsert<'a> = <SQLiteInstance as IDRISDBInstance>::Insert<'a>;

#[cfg(feature = "native")]
type NObjectWriter<'a> = <NInsert<'a> as IDRISDBWriter<'a>>::ObjectWriter;
#[cfg(feature = "sqlite")]
type SObjectWriter<'a> = <SInsert<'a> as IDRISDBWriter<'a>>::ObjectWriter;

#[cfg(feature = "native")]
type NListWriter<'a> = <NInsert<'a> as IDRISDBWriter<'a>>::ListWriter;
#[cfg(feature = "sqlite")]
type SListWriter<'a> = <SInsert<'a> as IDRISDBWriter<'a>>::ListWriter;

#[cfg(feature = "native")]
type NCursor<'a> = <NativeInstance as IDRISDBInstance>::Cursor<'a>;
#[cfg(feature = "sqlite")]
type SCursor<'a> = <SQLiteInstance as IDRISDBInstance>::Cursor<'a>;

#[cfg(feature = "native")]
type NReader<'a> = <NCursor<'a> as IDRISDBCursor>::Reader<'a>;
#[cfg(feature = "sqlite")]
type SReader<'a> = <SCursor<'a> as IDRISDBCursor>::Reader<'a>;

#[cfg(feature = "sqlite")]
type SObjectReader<'a> = <SReader<'a> as IDRISDBReader>::ObjectReader<'a>;

#[cfg(feature = "native")]
type NListReader<'a> = <NReader<'a> as IDRISDBReader>::ListReader<'a>;
#[cfg(feature = "sqlite")]
type SListReader<'a> = <SReader<'a> as IDRISDBReader>::ListReader<'a>;

#[cfg(feature = "native")]
type NQueryBuilder<'a> = <NativeInstance as IDRISDBInstance>::QueryBuilder<'a>;
#[cfg(feature = "sqlite")]
type SQueryBuilder<'a> = <SQLiteInstance as IDRISDBInstance>::QueryBuilder<'a>;

#[cfg(feature = "native")]
type NQuery = <NativeInstance as IDRISDBInstance>::Query;
#[cfg(feature = "sqlite")]
type SQuery = <SQLiteInstance as IDRISDBInstance>::Query;

#[cfg(feature = "native")]
type NQueryCursor<'a> = <NativeInstance as IDRISDBInstance>::QueryCursor<'a>;
#[cfg(feature = "sqlite")]
type SQueryCursor<'a> = <SQLiteInstance as IDRISDBInstance>::QueryCursor<'a>;

pub enum CIDRISDBInstance {
    #[cfg(feature = "native")]
    Native(NInstance),
    #[cfg(feature = "sqlite")]
    SQLite(SInstance),
}

pub enum CIDRISDBTxn {
    #[cfg(feature = "native")]
    Native(NTxn),
    #[cfg(feature = "sqlite")]
    SQLite(STxn),
}

pub enum CIDRISDBCursor<'a> {
    #[cfg(feature = "native")]
    Native(NCursor<'a>),
    #[cfg(feature = "sqlite")]
    SQLite(SCursor<'a>),
}

pub enum CIDRISDBWriter<'a> {
    #[cfg(feature = "native")]
    Native(NInsert<'a>),
    #[cfg(feature = "native")]
    NativeObject(NObjectWriter<'a>),
    #[cfg(feature = "native")]
    NativeList(NListWriter<'a>),
    #[cfg(feature = "sqlite")]
    SQLite(SInsert<'a>),
    #[cfg(feature = "sqlite")]
    SQLiteObject(SObjectWriter<'a>),
    #[cfg(feature = "sqlite")]
    SQLiteList(SListWriter<'a>),
}

pub enum CIDRISDBReader<'a> {
    #[cfg(feature = "native")]
    Native(NReader<'a>),
    #[cfg(feature = "native")]
    NativeList(NListReader<'a>),
    #[cfg(feature = "sqlite")]
    SQLite(SReader<'a>),
    #[cfg(feature = "sqlite")]
    SQLiteObject(SObjectReader<'a>),
    #[cfg(feature = "sqlite")]
    SQLiteList(SListReader<'a>),
}

pub struct CIDRISDBUpdate(pub(crate) Vec<(u16, Option<IDRISDBValue>)>);

pub enum CIDRISDBQueryBuilder<'a> {
    #[cfg(feature = "native")]
    Native(NQueryBuilder<'a>),
    #[cfg(feature = "sqlite")]
    SQLite(SQueryBuilder<'a>),
}

pub enum CIDRISDBQuery {
    #[cfg(feature = "native")]
    Native(NQuery),
    #[cfg(feature = "sqlite")]
    SQLite(SQuery),
}

pub enum CIDRISDBQueryCursor<'a> {
    #[cfg(feature = "native")]
    Native(NQueryCursor<'a>),
    #[cfg(feature = "sqlite")]
    SQLite(SQueryCursor<'a>),
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_string(chars: *const u16, length: u32) -> *const String {
    let chars = slice::from_raw_parts(chars, length as usize);
    let value = String::from_utf16_lossy(chars);
    Box::into_raw(Box::new(value))
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_string_free(value: *mut String) {
    if !value.is_null() {
        drop(Box::from_raw(value));
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_buffer_free(value: *mut u8, capacity: u32) {
    if !value.is_null() {
        drop(Vec::from_raw_parts(value, 0, capacity as usize));
    }
}

fn dart_fast_hash(value: &str) -> i64 {
    let mut hash = 0xcbf29ce484222325;

    let utf16 = value.encode_utf16();
    for char in utf16 {
        hash ^= (char >> 8) as u64;
        hash = hash.wrapping_mul(0x100000001b3);
        hash ^= (char & 0xFF) as u64;
        hash = hash.wrapping_mul(0x100000001b3);
    }

    hash as i64
}

#[cfg(not(target_arch = "wasm32"))]
type IDRISDBI64 = i64;

#[cfg(not(target_arch = "wasm32"))]
#[inline]
pub(crate) fn i64_to_IDRISDB(value: i64) -> IDRISDBI64 {
    value
}

#[cfg(not(target_arch = "wasm32"))]
#[inline]
pub(crate) fn IDRISDB_to_i64(value: IDRISDBI64) -> i64 {
    value
}

#[cfg(target_arch = "wasm32")]
type IDRISDBI64 = f64;

#[cfg(target_arch = "wasm32")]
#[inline]
pub(crate) fn i64_to_IDRISDB(value: i64) -> IDRISDBI64 {
    value as f64
}

#[cfg(target_arch = "wasm32")]
#[inline]
pub(crate) fn IDRISDB_to_i64(value: IDRISDBI64) -> i64 {
    if value.is_finite() {
        value as i64
    } else {
        i64::MIN
    }
}

// Export malloc and free for WASM
#[cfg(target_arch = "wasm32")]
#[no_mangle]
pub extern "C" fn malloc(size: usize) -> *mut u8 {
    use std::alloc::{alloc, Layout};
    if size == 0 {
        return std::ptr::null_mut();
    }
    unsafe {
        let layout = Layout::from_size_align_unchecked(size, 8);
        alloc(layout)
    }
}

#[cfg(target_arch = "wasm32")]
#[no_mangle]
pub extern "C" fn free(_ptr: *mut u8) {
    // For now, we intentionally leak memory since we don't track allocation sizes
    // This is a known limitation - in production, we'd need a proper allocator
    // that tracks metadata or uses a different allocation strategy
}
