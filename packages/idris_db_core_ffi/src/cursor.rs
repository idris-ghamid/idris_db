use crate::{IDRISDB_to_i64, CIDRISDBCursor, CIDRISDBQueryCursor, CIDRISDBReader, IDRISDBI64};
use idris_db_core::core::cursor::{IDRISDBCursor, IDRISDBQueryCursor};
use std::ptr;

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_cursor_next(
    cursor: &'static mut CIDRISDBCursor,
    id: IDRISDBI64,
    old_reader: *mut CIDRISDBReader,
) -> *const CIDRISDBReader<'static> {
    let id = IDRISDB_to_i64(id);

    if !old_reader.is_null() {
        drop(Box::from_raw(old_reader));
    }

    let reader = match cursor {
        #[cfg(feature = "native")]
        CIDRISDBCursor::Native(cursor) => cursor.next(id).map(|reader| CIDRISDBReader::Native(reader)),
        #[cfg(feature = "sqlite")]
        CIDRISDBCursor::SQLite(cursor) => cursor.next(id).map(|reader| CIDRISDBReader::SQLite(reader)),
    };
    if let Some(reader) = reader {
        Box::into_raw(Box::new(reader))
    } else {
        ptr::null()
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_cursor_free(cursor: *mut CIDRISDBCursor, reader: *mut CIDRISDBReader) {
    if !cursor.is_null() {
        drop(Box::from_raw(cursor));
    }
    if !reader.is_null() {
        drop(Box::from_raw(reader));
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_query_cursor_next(
    cursor: &'static mut CIDRISDBQueryCursor,
    old_reader: *mut CIDRISDBReader,
) -> *const CIDRISDBReader<'static> {
    if !old_reader.is_null() {
        drop(Box::from_raw(old_reader));
    }

    let reader = match cursor {
        #[cfg(feature = "native")]
        CIDRISDBQueryCursor::Native(cursor) => cursor.next().map(|reader| CIDRISDBReader::Native(reader)),
        #[cfg(feature = "sqlite")]
        CIDRISDBQueryCursor::SQLite(cursor) => cursor.next().map(|reader| CIDRISDBReader::SQLite(reader)),
    };
    if let Some(reader) = reader {
        Box::into_raw(Box::new(reader))
    } else {
        ptr::null()
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_query_cursor_free(
    cursor: *mut CIDRISDBQueryCursor,
    reader: *mut CIDRISDBReader,
) {
    if !cursor.is_null() {
        drop(Box::from_raw(cursor));
    }
    if !reader.is_null() {
        drop(Box::from_raw(reader));
    }
}
