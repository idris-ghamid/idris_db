#![allow(unreachable_patterns, unused_imports)]

use idris_db_core::core::{
    error::IdrisDbError,
    instance::IDRISDBInstance,
    watcher::{ChangeDetail, WatchHandle},
};

use crate::dart::{dart_post_int, dart_post_string, DartPort};
use crate::{IDRISDB_try, CIDRISDBInstance, CIDRISDBQuery};

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_watch_collection(
    IdrisDb: &'static CIDRISDBInstance,
    collection_index: u16,
    port: DartPort,
    handle: *mut *mut WatchHandle,
) -> u8 {
    let callback = Box::new(move || {
        dart_post_int(port, 1);
    });
    IDRISDB_try! {
        let new_handle = match IdrisDb {
            #[cfg(feature = "native")]
            CIDRISDBInstance::Native(IdrisDb) => IdrisDb.watch(collection_index, callback)?,
            #[cfg(feature = "sqlite")]
            CIDRISDBInstance::SQLite(IdrisDb) => IdrisDb.watch(collection_index, callback)?,
        };
        *handle = Box::into_raw(Box::new(new_handle));
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_watch_object(
    IdrisDb: &'static CIDRISDBInstance,
    collection_index: u16,
    id: i64,
    port: DartPort,
    handle: *mut *mut WatchHandle,
) -> u8 {
    let callback = Box::new(move || {
        dart_post_int(port, 1);
    });
    IDRISDB_try! {
        let new_handle = match IdrisDb {
            #[cfg(feature = "native")]
            CIDRISDBInstance::Native(IdrisDb) => IdrisDb.watch_object(collection_index, id, callback)?,
            #[cfg(feature = "sqlite")]
            CIDRISDBInstance::SQLite(IdrisDb) => IdrisDb.watch_object(collection_index, id, callback)?,
        };
        *handle = Box::into_raw(Box::new(new_handle));
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_watch_query(
    IdrisDb: &'static CIDRISDBInstance,
    query: &CIDRISDBQuery,
    port: DartPort,
    handle: *mut *mut WatchHandle,
) -> u8 {
    let callback = Box::new(move || {
        dart_post_int(port, 1);
    });
    IDRISDB_try! {
        let new_handle = match (IdrisDb, query) {
            #[cfg(feature = "native")]
            (CIDRISDBInstance::Native(IdrisDb), CIDRISDBQuery::Native(query)) => {
                IdrisDb.watch_query(query, callback)?
            }
            #[cfg(feature = "sqlite")]
            (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBQuery::SQLite(query)) => {
                IdrisDb.watch_query(query, callback)?
            }
            _ => return Err(IdrisDbError::IllegalArgument {}),
        };
        *handle = Box::into_raw(Box::new(new_handle));
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_watch_collection_detailed(
    IdrisDb: &'static CIDRISDBInstance,
    collection_index: u16,
    port: DartPort,
    handle: *mut *mut WatchHandle,
) -> u8 {
    let callback = Box::new(move |change_detail: ChangeDetail| {
        // Serialize change detail to JSON and send to Dart
        if let Ok(json_string) = serde_json::to_string(&change_detail) {
            dart_post_string(port, json_string);
        }
    });
    IDRISDB_try! {
        let new_handle = match IdrisDb {
            #[cfg(feature = "native")]
            CIDRISDBInstance::Native(IdrisDb) => IdrisDb.watch_detailed(collection_index, callback)?,
            #[cfg(feature = "sqlite")]
            CIDRISDBInstance::SQLite(IdrisDb) => IdrisDb.watch_detailed(collection_index, callback)?,
        };
        *handle = Box::into_raw(Box::new(new_handle));
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_stop_watching(handle: *mut WatchHandle) {
    Box::from_raw(handle).stop();
}
