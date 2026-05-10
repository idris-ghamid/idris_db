#![allow(unreachable_patterns)]

use crate::{
    dart_fast_hash, i64_to_IDRISDB, IDRISDB_to_i64, CIDRISDBCursor, CIDRISDBInstance, CIDRISDBTxn, IDRISDBI64,
};
use idris_db_core::core::error::IdrisDbError;
use idris_db_core::core::instance::{CompactCondition, IDRISDBInstance};
use idris_db_core::core::schema::IdrisDbSchema;
use std::os::raw::c_char;
use std::ptr;

#[cfg(feature = "native")]
use idris_db_core::native::native_instance::NativeInstance;

#[cfg(feature = "sqlite")]
use idris_db_core::sqlite::sqlite_instance::SQLiteInstance;

include!(concat!(env!("OUT_DIR"), "/version.rs"));

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_version() -> *const c_char {
    IDRISDB_VERSION.as_ptr() as *const c_char
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_get_instance(instance_id: u32, sqlite: bool) -> *const CIDRISDBInstance {
    if sqlite {
        #[cfg(feature = "sqlite")]
        if let Some(instance) = SQLiteInstance::get_instance(instance_id) {
            return Box::into_raw(Box::new(CIDRISDBInstance::SQLite(instance)));
        }
    } else {
        #[cfg(feature = "native")]
        if let Some(instance) = NativeInstance::get_instance(instance_id) {
            return Box::into_raw(Box::new(CIDRISDBInstance::Native(instance)));
        }
    }
    ptr::null()
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_open_instance(
    IdrisDb: *mut *const CIDRISDBInstance,
    instance_id: u32,
    name: *mut String,
    path: *mut String,
    sqlite: bool,
    schema_json: *mut String,
    max_size_mib: u32,
    encryption_key: *mut String,
    compact_min_file_size: u32,
    compact_min_bytes: u32,
    compact_min_ratio: f32,
) -> u8 {
    IDRISDB_try! {
        let name = *Box::from_raw(name);
        let path = *Box::from_raw(path);
        let schema_json = *Box::from_raw(schema_json);
        let schemas = IdrisDbSchema::from_json(schema_json.as_bytes())?;

        let encryption_key = if encryption_key.is_null() {
            None
        } else {
            Some(*Box::from_raw(encryption_key))
        };

        let compact_condition = if compact_min_ratio.is_nan() {
            None
        } else {
            Some(CompactCondition {
                min_file_size: compact_min_file_size,
                min_bytes: compact_min_bytes,
                min_ratio: compact_min_ratio,
            })
        };

        let new_IDRISDB = if sqlite {
            #[cfg(feature = "sqlite")]
            {
                let instance = SQLiteInstance::open_instance(
                    instance_id,
                    &name,
                    &path,
                    schemas,
                    max_size_mib,
                    encryption_key.as_deref(),
                    compact_condition,
                )?;
                CIDRISDBInstance::SQLite(instance)
            }
            #[cfg(not(feature = "sqlite"))]
            {
                return Err(IdrisDbError::UnsupportedOperation {});
            }
        } else {
            #[cfg(feature = "native")]
            {
                let instance = NativeInstance::open_instance(
                    instance_id,
                    &name,
                    &path,
                    schemas,
                    max_size_mib,
                    encryption_key.as_deref(),
                    compact_condition,
                )?;
                CIDRISDBInstance::Native(instance)
            }
            #[cfg(not(feature = "native"))]
            {
                return Err(IdrisDbError::UnsupportedOperation {});
            }
        };
        *IdrisDb = Box::into_raw(Box::new(new_IDRISDB));
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_get_name(IdrisDb: &'static CIDRISDBInstance, name: *mut *const u8) -> u32 {
    let value = match IdrisDb {
        #[cfg(feature = "native")]
        CIDRISDBInstance::Native(IdrisDb) => IdrisDb.get_name(),
        #[cfg(feature = "sqlite")]
        CIDRISDBInstance::SQLite(IdrisDb) => IdrisDb.get_name(),
    };
    *name = value.as_ptr();
    value.len() as u32
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_get_dir(IdrisDb: &'static CIDRISDBInstance, dir: *mut *const u8) -> u32 {
    let value = match IdrisDb {
        #[cfg(feature = "native")]
        CIDRISDBInstance::Native(IdrisDb) => IdrisDb.get_dir(),
        #[cfg(feature = "sqlite")]
        CIDRISDBInstance::SQLite(IdrisDb) => IdrisDb.get_dir(),
    };
    *dir = value.as_ptr();
    value.len() as u32
}

unsafe fn _IDRISDB_txn_begin(
    IdrisDb: &'static CIDRISDBInstance,
    txn: *mut *const CIDRISDBTxn,
    write: bool,
) -> u8 {
    IDRISDB_try! {
        let new_txn = match IdrisDb {
            #[cfg(feature = "native")]
            CIDRISDBInstance::Native(IdrisDb) => CIDRISDBTxn::Native(IdrisDb.begin_txn(write)?),
            #[cfg(feature = "sqlite")]
            CIDRISDBInstance::SQLite(IdrisDb) => CIDRISDBTxn::SQLite(IdrisDb.begin_txn(write)?),
        };
        *txn = Box::into_raw(Box::new(new_txn));
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_txn_begin(
    IdrisDb: &'static CIDRISDBInstance,
    txn: *mut *const CIDRISDBTxn,
    write: bool,
) -> u8 {
    IDRISDB_pause_isolate! {
        IDRISDB_try! {
            let new_txn = match IdrisDb {
                #[cfg(feature = "native")]
                CIDRISDBInstance::Native(IdrisDb) => CIDRISDBTxn::Native(IdrisDb.begin_txn(write)?),
                #[cfg(feature = "sqlite")]
                CIDRISDBInstance::SQLite(IdrisDb) => CIDRISDBTxn::SQLite(IdrisDb.begin_txn(write)?),
            };
            *txn = Box::into_raw(Box::new(new_txn));
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_txn_commit(IdrisDb: &'static CIDRISDBInstance, txn: *mut CIDRISDBTxn) -> u8 {
    IDRISDB_pause_isolate! {
        IDRISDB_try! {
            let txn = *Box::from_raw(txn);
            match (IdrisDb, txn) {
                #[cfg(feature = "native")]
                (CIDRISDBInstance::Native(IdrisDb), CIDRISDBTxn::Native(txn)) => IdrisDb.commit_txn(txn)?,
                #[cfg(feature = "sqlite")]
                (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBTxn::SQLite(txn)) => IdrisDb.commit_txn(txn)?,
                _ => return Err(IdrisDbError::IllegalArgument {}),
            }
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_txn_abort(IdrisDb: &'static CIDRISDBInstance, txn: *mut CIDRISDBTxn) {
    let txn = *Box::from_raw(txn);
    match (IdrisDb, txn) {
        #[cfg(feature = "native")]
        (CIDRISDBInstance::Native(IdrisDb), CIDRISDBTxn::Native(txn)) => {
            IdrisDb.abort_txn(txn);
        }
        #[cfg(feature = "sqlite")]
        (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBTxn::SQLite(txn)) => {
            IdrisDb.abort_txn(txn);
        }
        _ => {}
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_auto_increment(
    IdrisDb: &'static CIDRISDBInstance,
    collection_index: u16,
) -> IDRISDBI64 {
    let id = match IdrisDb {
        #[cfg(feature = "native")]
        CIDRISDBInstance::Native(IdrisDb) => IdrisDb.auto_increment(collection_index),
        #[cfg(feature = "sqlite")]
        CIDRISDBInstance::SQLite(IdrisDb) => IdrisDb.auto_increment(collection_index),
    };
    i64_to_IDRISDB(id)
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_cursor(
    IdrisDb: &'static CIDRISDBInstance,
    txn: &'static CIDRISDBTxn,
    collection_index: u16,
    cursor: *mut *const CIDRISDBCursor,
) -> u8 {
    IDRISDB_try! {
        let new_cursor = match (IdrisDb, txn) {
            #[cfg(feature = "native")]
            (CIDRISDBInstance::Native(IdrisDb), CIDRISDBTxn::Native(txn)) => {
                let cursor = IdrisDb.cursor(txn, collection_index)?;
                CIDRISDBCursor::Native(cursor)
            }
            #[cfg(feature = "sqlite")]
            (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBTxn::SQLite(txn)) => {
                let cursor = IdrisDb.cursor(txn, collection_index)?;
                CIDRISDBCursor::SQLite(cursor)
            }
            _ => return Err(IdrisDbError::IllegalArgument {}),
        };
        *cursor = Box::into_raw(Box::new(new_cursor));
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_delete(
    IdrisDb: &'static CIDRISDBInstance,
    txn: &'static CIDRISDBTxn,
    collection_index: u16,
    id: IDRISDBI64,
    deleted: *mut bool,
) -> u8 {
    let id = IDRISDB_to_i64(id);
    IDRISDB_try! {
        *deleted = match (IdrisDb, txn) {
            #[cfg(feature = "native")]
            (CIDRISDBInstance::Native(IdrisDb), CIDRISDBTxn::Native(txn)) => {
                IdrisDb.delete(txn, collection_index, id)?
            }
            #[cfg(feature = "sqlite")]
            (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBTxn::SQLite(txn)) => {
                IdrisDb.delete(txn, collection_index, id)?
            }
            _ => return Err(IdrisDbError::IllegalArgument {}),
        };
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_count(
    IdrisDb: &'static CIDRISDBInstance,
    txn: &'static CIDRISDBTxn,
    collection_index: u16,
    count: *mut u32,
) -> u8 {
    IDRISDB_try! {
        let new_count = match (IdrisDb, txn) {
            #[cfg(feature = "native")]
            (CIDRISDBInstance::Native(IdrisDb), CIDRISDBTxn::Native(txn)) => {
                IdrisDb.count(txn, collection_index)?
            }
            #[cfg(feature = "sqlite")]
            (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBTxn::SQLite(txn)) => {
                IdrisDb.count(txn, collection_index)?
            }
            _ => return Err(IdrisDbError::IllegalArgument {}),
        };
        *count = new_count;
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_clear(
    IdrisDb: &'static CIDRISDBInstance,
    txn: &'static CIDRISDBTxn,
    collection_index: u16,
) -> u8 {
    IDRISDB_try! {
        match (IdrisDb, txn) {
            #[cfg(feature = "native")]
            (CIDRISDBInstance::Native(IdrisDb), CIDRISDBTxn::Native(txn)) => {
                IdrisDb.clear(txn, collection_index)?
            }
            #[cfg(feature = "sqlite")]
            (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBTxn::SQLite(txn)) => {
                IdrisDb.clear(txn, collection_index)?
            }
            _ => return Err(IdrisDbError::IllegalArgument {}),
        };
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_get_size(
    IdrisDb: &'static CIDRISDBInstance,
    txn: &'static CIDRISDBTxn,
    collection_index: u16,
    include_indexes: bool,
) -> u32 {
    match (IdrisDb, txn) {
        #[cfg(feature = "native")]
        (CIDRISDBInstance::Native(IdrisDb), CIDRISDBTxn::Native(txn)) => IdrisDb
            .get_size(txn, collection_index, include_indexes)
            .unwrap_or(0) as u32,
        #[cfg(feature = "sqlite")]
        (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBTxn::SQLite(txn)) => IdrisDb
            .get_size(txn, collection_index, include_indexes)
            .unwrap_or(0) as u32,
        _ => 0,
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_import_json(
    IdrisDb: &'static CIDRISDBInstance,
    txn: *mut *mut CIDRISDBTxn,
    collection_index: u16,
    json: *mut String,
    count: *mut u32,
) -> u8 {
    let json = *Box::from_raw(json);
    let mut deserializer = serde_json::Deserializer::from_str(&json);
    IDRISDB_try! {
        let (new_txn, new_count) = match (IdrisDb, *Box::from_raw(*txn)) {
            #[cfg(feature = "native")]
            (CIDRISDBInstance::Native(IdrisDb), CIDRISDBTxn::Native(txn)) => {
                let (txn, count) = IdrisDb.import_json(txn, collection_index, &mut deserializer, dart_fast_hash)?;
                (CIDRISDBTxn::Native(txn), count)
            }
            #[cfg(feature = "sqlite")]
            (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBTxn::SQLite(txn)) => {
                let (txn, count) = IdrisDb.import_json(txn, collection_index, &mut deserializer, dart_fast_hash)?;
                (CIDRISDBTxn::SQLite(txn), count)
            }
            _ => return Err(IdrisDbError::IllegalArgument {}),
        };
        *txn = Box::into_raw(Box::new(new_txn));
        *count = new_count;
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_copy(IdrisDb: &'static CIDRISDBInstance, path: *mut String) -> u8 {
    IDRISDB_pause_isolate! {
        IDRISDB_try! {
            let path = *Box::from_raw(path);
            match IdrisDb {
                #[cfg(feature = "native")]
                CIDRISDBInstance::Native(IdrisDb) => IdrisDb.copy(&path)?,
                #[cfg(feature = "sqlite")]
                CIDRISDBInstance::SQLite(IdrisDb) => IdrisDb.copy(&path)?,
            }
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_verify(IdrisDb: &'static CIDRISDBInstance, txn: &'static CIDRISDBTxn) -> u8 {
    IDRISDB_try! {
        return match (IdrisDb, txn) {
            #[cfg(feature = "native")]
            (CIDRISDBInstance::Native(IdrisDb), CIDRISDBTxn::Native(txn)) => IdrisDb.verify(txn),
            #[cfg(feature = "sqlite")]
            (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBTxn::SQLite(txn)) => IdrisDb.verify(txn),
            _ => Err(IdrisDbError::IllegalArgument {}),
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_delete_database(
    name: *mut String,
    path: *mut String,
    sqlite: bool,
) -> u8 {
    IDRISDB_try! {
        let name = *Box::from_raw(name);
        let path = *Box::from_raw(path);

        if sqlite {
            #[cfg(feature = "sqlite")]
            {
                use idris_db_core::sqlite::sqlite_delete::delete_database_files;
                delete_database_files(&name, &path)?;
            }
            #[cfg(not(feature = "sqlite"))]
            {
                return Err(IdrisDbError::UnsupportedOperation {});
            }
        } else {
            #[cfg(feature = "native")]
            {
                use idris_db_core::native::native_delete::delete_database_files;
                delete_database_files(&name, &path)?;
            }
            #[cfg(not(feature = "native"))]
            {
                return Err(IdrisDbError::UnsupportedOperation {});
            }
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_close(IdrisDb: *mut CIDRISDBInstance, delete: bool) -> u8 {
    IDRISDB_pause_isolate! {
        let IdrisDb = *Box::from_raw(IdrisDb);
        let closed = match IdrisDb {
            #[cfg(feature = "native")]
            CIDRISDBInstance::Native(IdrisDb) => NativeInstance::close(IdrisDb, delete),
            #[cfg(feature = "sqlite")]
            CIDRISDBInstance::SQLite(IdrisDb) => SQLiteInstance::close(IdrisDb, delete),
        };
        if closed {
            1
        } else {
            0
        }
    }
}
