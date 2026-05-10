use crate::{i64_to_IDRISDB, CIDRISDBReader, IDRISDBI64};
use idris_db_core::core::reader::IDRISDBReader;
use std::{ptr, vec};

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_read_id(reader: &'static CIDRISDBReader) -> IDRISDBI64 {
    let id = match reader {
        #[cfg(feature = "native")]
        CIDRISDBReader::Native(reader) => reader.read_id(),
        #[cfg(feature = "native")]
        CIDRISDBReader::NativeList(reader) => reader.read_id(),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLite(reader) => reader.read_id(),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteObject(reader) => reader.read_id(),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteList(reader) => reader.read_id(),
    };
    i64_to_IDRISDB(id)
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_read_null(reader: &'static CIDRISDBReader, index: u32) -> u8 {
    let is_null = match reader {
        #[cfg(feature = "native")]
        CIDRISDBReader::Native(reader) => reader.is_null(index),
        #[cfg(feature = "native")]
        CIDRISDBReader::NativeList(reader) => reader.is_null(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLite(reader) => reader.is_null(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteObject(reader) => reader.is_null(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteList(reader) => reader.is_null(index),
    };
    if is_null {
        1
    } else {
        0
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_read_bool(reader: &'static CIDRISDBReader, index: u32) -> u8 {
    let value = match reader {
        #[cfg(feature = "native")]
        CIDRISDBReader::Native(reader) => reader.read_bool(index),
        #[cfg(feature = "native")]
        CIDRISDBReader::NativeList(reader) => reader.read_bool(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLite(reader) => reader.read_bool(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteObject(reader) => reader.read_bool(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteList(reader) => reader.read_bool(index),
    };
    if value.unwrap_or(false) {
        1
    } else {
        0
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_read_byte(reader: &'static CIDRISDBReader, index: u32) -> u8 {
    match reader {
        #[cfg(feature = "native")]
        CIDRISDBReader::Native(reader) => reader.read_byte(index),
        #[cfg(feature = "native")]
        CIDRISDBReader::NativeList(reader) => reader.read_byte(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLite(reader) => reader.read_byte(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteObject(reader) => reader.read_byte(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteList(reader) => reader.read_byte(index),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_read_int(reader: &'static CIDRISDBReader, index: u32) -> i32 {
    match reader {
        #[cfg(feature = "native")]
        CIDRISDBReader::Native(reader) => reader.read_int(index),
        #[cfg(feature = "native")]
        CIDRISDBReader::NativeList(reader) => reader.read_int(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLite(reader) => reader.read_int(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteObject(reader) => reader.read_int(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteList(reader) => reader.read_int(index),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_read_float(reader: &'static CIDRISDBReader, index: u32) -> f32 {
    match reader {
        #[cfg(feature = "native")]
        CIDRISDBReader::Native(reader) => reader.read_float(index),
        #[cfg(feature = "native")]
        CIDRISDBReader::NativeList(reader) => reader.read_float(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLite(reader) => reader.read_float(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteObject(reader) => reader.read_float(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteList(reader) => reader.read_float(index),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_read_long(reader: &'static CIDRISDBReader, index: u32) -> IDRISDBI64 {
    let value = match reader {
        #[cfg(feature = "native")]
        CIDRISDBReader::Native(reader) => reader.read_long(index),
        #[cfg(feature = "native")]
        CIDRISDBReader::NativeList(reader) => reader.read_long(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLite(reader) => reader.read_long(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteObject(reader) => reader.read_long(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteList(reader) => reader.read_long(index),
    };
    i64_to_IDRISDB(value)
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_read_double(reader: &'static CIDRISDBReader, index: u32) -> f64 {
    match reader {
        #[cfg(feature = "native")]
        CIDRISDBReader::Native(reader) => reader.read_double(index),
        #[cfg(feature = "native")]
        CIDRISDBReader::NativeList(reader) => reader.read_double(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLite(reader) => reader.read_double(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteObject(reader) => reader.read_double(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteList(reader) => reader.read_double(index),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_read_string(
    reader: &'static CIDRISDBReader,
    index: u32,
    value: *mut *const u8,
    is_ascii: *mut bool,
) -> u32 {
    let str = match reader {
        #[cfg(feature = "native")]
        CIDRISDBReader::Native(reader) => reader.read_string(index),
        #[cfg(feature = "native")]
        CIDRISDBReader::NativeList(reader) => reader.read_string(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLite(reader) => reader.read_string(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteObject(reader) => reader.read_string(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteList(reader) => reader.read_string(index),
    };
    if let Some(str) = str {
        let len = str.len();
        let ptr = str.as_ptr();
        *value = ptr;
        *is_ascii = str.is_ascii();
        len as u32
    } else {
        *value = ptr::null();
        0
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_read_object(
    reader: &'static CIDRISDBReader,
    index: u32,
) -> *mut CIDRISDBReader<'static> {
    let new_reader = match reader {
        #[cfg(feature = "native")]
        CIDRISDBReader::Native(reader) => reader.read_object(index).map(|r| CIDRISDBReader::Native(r)),
        #[cfg(feature = "native")]
        CIDRISDBReader::NativeList(reader) => {
            reader.read_object(index).map(|r| CIDRISDBReader::Native(r))
        }
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLite(reader) => reader
            .read_object(index)
            .map(|r| CIDRISDBReader::SQLiteObject(r)),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteObject(reader) => reader
            .read_object(index)
            .map(|r| CIDRISDBReader::SQLiteObject(r)),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteList(reader) => reader
            .read_object(index)
            .map(|r| CIDRISDBReader::SQLiteObject(r)),
    };
    if let Some(new_reader) = new_reader {
        Box::into_raw(Box::new(new_reader))
    } else {
        ptr::null_mut()
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_read_list(
    reader: &'static CIDRISDBReader,
    index: u32,
    list_reader: *mut *mut CIDRISDBReader<'static>,
) -> u32 {
    let reader_size = match reader {
        #[cfg(feature = "native")]
        CIDRISDBReader::Native(reader) => reader
            .read_list(index)
            .map(|(r, s)| (CIDRISDBReader::NativeList(r), s)),
        #[cfg(feature = "native")]
        CIDRISDBReader::NativeList(reader) => reader
            .read_list(index)
            .map(|(r, s)| (CIDRISDBReader::NativeList(r), s)),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLite(reader) => reader
            .read_list(index)
            .map(|(r, s)| (CIDRISDBReader::SQLiteList(r), s)),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteObject(reader) => reader
            .read_list(index)
            .map(|(r, s)| (CIDRISDBReader::SQLiteList(r), s)),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLiteList(reader) => reader
            .read_list(index)
            .map(|(r, s)| (CIDRISDBReader::SQLiteList(r), s)),
    };
    if let Some((new_reader, size)) = reader_size {
        *list_reader = Box::into_raw(Box::new(new_reader));
        size
    } else {
        *list_reader = ptr::null_mut();
        0
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_read_to_json(
    reader: &'static CIDRISDBReader,
    buffer: *mut *mut u8,
    buffer_size: *mut u32,
) -> u32 {
    let mut new_buffer = if (*buffer).is_null() {
        vec![]
    } else {
        Vec::from_raw_parts(*buffer, 0, *buffer_size as usize)
    };
    let mut serializer = serde_json::Serializer::new(&mut new_buffer);
    let serialized = match reader {
        #[cfg(feature = "native")]
        CIDRISDBReader::Native(reader) => reader.serialize(&mut serializer).is_ok(),
        #[cfg(feature = "sqlite")]
        CIDRISDBReader::SQLite(reader) => reader.serialize(&mut serializer).is_ok(),
        _ => false,
    };

    if serialized {
        let len = new_buffer.len();
        let cap = new_buffer.capacity();
        let ptr = new_buffer.leak().as_mut_ptr();
        *buffer_size = cap as u32;
        *buffer = ptr;
        len as u32
    } else {
        *buffer_size = 0;
        *buffer = ptr::null_mut();
        0
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_read_free(reader: *const CIDRISDBReader) {
    if !reader.is_null() {
        drop(Box::from_raw(reader as *mut CIDRISDBReader));
    }
}
