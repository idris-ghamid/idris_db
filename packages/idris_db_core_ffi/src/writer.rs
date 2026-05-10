use crate::{IDRISDB_to_i64, CIDRISDBWriter, IDRISDBI64};
use idris_db_core::core::writer::IDRISDBWriter;
use std::slice;

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_write_null(writer: &'static mut CIDRISDBWriter, index: u32) {
    match writer {
        #[cfg(feature = "native")]
        CIDRISDBWriter::Native(writer) => writer.write_null(index),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeObject(writer) => writer.write_null(index),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeList(writer) => writer.write_null(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLite(writer) => writer.write_null(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteObject(writer) => writer.write_null(index),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteList(writer) => writer.write_null(index),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_write_bool(
    writer: &'static mut CIDRISDBWriter,
    index: u32,
    value: bool,
) {
    match writer {
        #[cfg(feature = "native")]
        CIDRISDBWriter::Native(writer) => writer.write_bool(index, value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeObject(writer) => writer.write_bool(index, value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeList(writer) => writer.write_bool(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLite(writer) => writer.write_bool(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteObject(writer) => writer.write_bool(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteList(writer) => writer.write_bool(index, value),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_write_byte(writer: &'static mut CIDRISDBWriter, index: u32, value: u8) {
    match writer {
        #[cfg(feature = "native")]
        CIDRISDBWriter::Native(writer) => writer.write_byte(index, value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeObject(writer) => writer.write_byte(index, value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeList(writer) => writer.write_byte(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLite(writer) => writer.write_byte(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteObject(writer) => writer.write_byte(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteList(writer) => writer.write_byte(index, value),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_write_int(writer: &'static mut CIDRISDBWriter, index: u32, value: i32) {
    match writer {
        #[cfg(feature = "native")]
        CIDRISDBWriter::Native(writer) => writer.write_int(index, value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeObject(writer) => writer.write_int(index, value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeList(writer) => writer.write_int(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLite(writer) => writer.write_int(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteObject(writer) => writer.write_int(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteList(writer) => writer.write_int(index, value),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_write_float(
    writer: &'static mut CIDRISDBWriter,
    index: u32,
    value: f32,
) {
    match writer {
        #[cfg(feature = "native")]
        CIDRISDBWriter::Native(writer) => writer.write_float(index, value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeObject(writer) => writer.write_float(index, value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeList(writer) => writer.write_float(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLite(writer) => writer.write_float(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteObject(writer) => writer.write_float(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteList(writer) => writer.write_float(index, value),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_write_long(
    writer: &'static mut CIDRISDBWriter,
    index: u32,
    value: IDRISDBI64,
) {
    let value = IDRISDB_to_i64(value);
    match writer {
        #[cfg(feature = "native")]
        CIDRISDBWriter::Native(writer) => writer.write_long(index, value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeObject(writer) => writer.write_long(index, value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeList(writer) => writer.write_long(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLite(writer) => writer.write_long(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteObject(writer) => writer.write_long(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteList(writer) => writer.write_long(index, value),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_write_double(
    writer: &'static mut CIDRISDBWriter,
    index: u32,
    value: f64,
) {
    match writer {
        #[cfg(feature = "native")]
        CIDRISDBWriter::Native(writer) => writer.write_double(index, value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeObject(writer) => writer.write_double(index, value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeList(writer) => writer.write_double(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLite(writer) => writer.write_double(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteObject(writer) => writer.write_double(index, value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteList(writer) => writer.write_double(index, value),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_write_string(
    writer: &'static mut CIDRISDBWriter,
    index: u32,
    value: *mut String,
) {
    let value = *Box::from_raw(value);
    match writer {
        #[cfg(feature = "native")]
        CIDRISDBWriter::Native(writer) => writer.write_string(index, &value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeObject(writer) => writer.write_string(index, &value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeList(writer) => writer.write_string(index, &value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLite(writer) => writer.write_string(index, &value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteObject(writer) => writer.write_string(index, &value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteList(writer) => writer.write_string(index, &value),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_write_json(
    writer: &'static mut CIDRISDBWriter,
    index: u32,
    value: *mut String,
) {
    let value = *Box::from_raw(value);
    match writer {
        #[cfg(feature = "native")]
        CIDRISDBWriter::Native(writer) => writer.write_string(index, &value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeObject(writer) => writer.write_string(index, &value),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeList(writer) => writer.write_string(index, &value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLite(writer) => writer.write_string(index, &value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteObject(writer) => writer.write_string(index, &value),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteList(writer) => writer.write_string(index, &value),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_write_byte_list(
    writer: &'static mut CIDRISDBWriter,
    index: u32,
    value: *const u8,
    length: u32,
) {
    let bytes = slice::from_raw_parts(value, length as usize);
    match writer {
        #[cfg(feature = "native")]
        CIDRISDBWriter::Native(writer) => writer.write_byte_list(index, bytes),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeObject(writer) => writer.write_byte_list(index, bytes),
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeList(writer) => writer.write_byte_list(index, bytes),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLite(writer) => writer.write_byte_list(index, bytes),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteObject(writer) => writer.write_byte_list(index, bytes),
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteList(writer) => writer.write_byte_list(index, bytes),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_write_object(
    writer: &'static mut CIDRISDBWriter,
    index: u32,
) -> *mut CIDRISDBWriter<'static> {
    let writer = match writer {
        #[cfg(feature = "native")]
        CIDRISDBWriter::Native(writer) => {
            CIDRISDBWriter::NativeObject(writer.begin_object(index).unwrap())
        }
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeObject(writer) => {
            CIDRISDBWriter::NativeObject(writer.begin_object(index).unwrap())
        }
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeList(writer) => {
            CIDRISDBWriter::NativeObject(writer.begin_object(index).unwrap())
        }
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLite(writer) => {
            CIDRISDBWriter::SQLiteObject(writer.begin_object(index).unwrap())
        }
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteObject(writer) => {
            CIDRISDBWriter::SQLiteObject(writer.begin_object(index).unwrap())
        }
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteList(writer) => {
            CIDRISDBWriter::SQLiteObject(writer.begin_object(index).unwrap())
        }
    };
    Box::into_raw(Box::new(writer))
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_write_object_end(
    writer: &'static mut CIDRISDBWriter,
    embedded_writer: *mut CIDRISDBWriter<'static>,
) {
    let embedded_writer = *Box::from_raw(embedded_writer);
    match (writer, embedded_writer) {
        #[cfg(feature = "native")]
        (CIDRISDBWriter::Native(writer), CIDRISDBWriter::NativeObject(embedded_writer)) => {
            writer.end_object(embedded_writer)
        }
        #[cfg(feature = "native")]
        (CIDRISDBWriter::NativeObject(writer), CIDRISDBWriter::NativeObject(embedded_writer)) => {
            writer.end_object(embedded_writer)
        }
        #[cfg(feature = "native")]
        (CIDRISDBWriter::NativeList(writer), CIDRISDBWriter::NativeObject(embedded_writer)) => {
            writer.end_object(embedded_writer)
        }
        #[cfg(feature = "sqlite")]
        (CIDRISDBWriter::SQLite(writer), CIDRISDBWriter::SQLiteObject(embedded_writer)) => {
            writer.end_object(embedded_writer)
        }
        #[cfg(feature = "sqlite")]
        (CIDRISDBWriter::SQLiteObject(writer), CIDRISDBWriter::SQLiteObject(embedded_writer)) => {
            writer.end_object(embedded_writer)
        }
        #[cfg(feature = "sqlite")]
        (CIDRISDBWriter::SQLiteList(writer), CIDRISDBWriter::SQLiteObject(embedded_writer)) => {
            writer.end_object(embedded_writer)
        }
        _ => {}
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_write_list(
    writer: &'static mut CIDRISDBWriter,
    index: u32,
    length: u32,
) -> *mut CIDRISDBWriter<'static> {
    let writer = match writer {
        #[cfg(feature = "native")]
        CIDRISDBWriter::Native(writer) => {
            CIDRISDBWriter::NativeList(writer.begin_list(index, length).unwrap())
        }
        #[cfg(feature = "native")]
        CIDRISDBWriter::NativeObject(writer) => {
            CIDRISDBWriter::NativeList(writer.begin_list(index, length).unwrap())
        }
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLite(writer) => {
            CIDRISDBWriter::SQLiteList(writer.begin_list(index, length).unwrap())
        }
        #[cfg(feature = "sqlite")]
        CIDRISDBWriter::SQLiteObject(writer) => {
            CIDRISDBWriter::SQLiteList(writer.begin_list(index, length).unwrap())
        }
        _ => panic!("Cannot write nested list"),
    };
    Box::into_raw(Box::new(writer))
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_write_list_end(
    writer: &'static mut CIDRISDBWriter,
    list_writer: *mut CIDRISDBWriter<'static>,
) {
    let list_writer = *Box::from_raw(list_writer);
    match (writer, list_writer) {
        #[cfg(feature = "native")]
        (CIDRISDBWriter::Native(writer), CIDRISDBWriter::NativeList(list_writer)) => {
            writer.end_list(list_writer)
        }
        #[cfg(feature = "native")]
        (CIDRISDBWriter::NativeObject(writer), CIDRISDBWriter::NativeList(list_writer)) => {
            writer.end_list(list_writer)
        }
        #[cfg(feature = "native")]
        (CIDRISDBWriter::NativeList(writer), CIDRISDBWriter::NativeList(list_writer)) => {
            writer.end_list(list_writer)
        }
        #[cfg(feature = "sqlite")]
        (CIDRISDBWriter::SQLite(writer), CIDRISDBWriter::SQLiteList(list_writer)) => {
            writer.end_list(list_writer)
        }
        #[cfg(feature = "sqlite")]
        (CIDRISDBWriter::SQLiteObject(writer), CIDRISDBWriter::SQLiteList(list_writer)) => {
            writer.end_list(list_writer)
        }
        #[cfg(feature = "sqlite")]
        (CIDRISDBWriter::SQLiteList(writer), CIDRISDBWriter::SQLiteList(list_writer)) => {
            writer.end_list(list_writer)
        }
        _ => {}
    }
}
