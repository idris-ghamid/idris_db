#![allow(unreachable_patterns)]

use crate::{IDRISDB_to_i64, CIDRISDBInstance, CIDRISDBQuery, CIDRISDBTxn, CIDRISDBUpdate, IDRISDBI64};
use idris_db_core::core::error::IdrisDbError;
use idris_db_core::core::instance::IDRISDBInstance;
use idris_db_core::core::value::IDRISDBValue;

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_update(
    IdrisDb: &'static CIDRISDBInstance,
    txn: &CIDRISDBTxn,
    collection_index: u16,
    id: IDRISDBI64,
    update: *mut CIDRISDBUpdate,
    updated: *mut bool,
) -> u8 {
    let id = IDRISDB_to_i64(id);
    let update = Box::from_raw(update);
    IDRISDB_try! {
        match (IdrisDb, txn) {
            #[cfg(feature = "native")]
            (CIDRISDBInstance::Native(IdrisDb), CIDRISDBTxn::Native(txn)) => {
                *updated = IdrisDb.update(txn, collection_index, id, &update.0)?;
            }
            #[cfg(feature = "sqlite")]
            (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBTxn::SQLite(txn)) => {
                *updated = IdrisDb.update(txn, collection_index, id, &update.0)?;
            }
            _ => return Err(IdrisDbError::IllegalArgument {}),
        };
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_query_update(
    IdrisDb: &'static CIDRISDBInstance,
    txn: &'static CIDRISDBTxn,
    query: &'static CIDRISDBQuery,
    offset: u32,
    limit: u32,
    update: *mut CIDRISDBUpdate,
    updated: *mut u32,
) -> u8 {
    let offset = if offset == 0 { None } else { Some(offset) };
    let limit = if limit == 0 { None } else { Some(limit) };

    let update = Box::from_raw(update);

    IDRISDB_try! {
        match (IdrisDb, txn, query) {
            #[cfg(feature = "native")]
            (CIDRISDBInstance::Native(IdrisDb), CIDRISDBTxn::Native(txn), CIDRISDBQuery::Native(query)) => {
                *updated = IdrisDb.query_update(txn, query, offset, limit, &update.0)?;
            }
            #[cfg(feature = "sqlite")]
            (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBTxn::SQLite(txn), CIDRISDBQuery::SQLite(query)) => {
                *updated = IdrisDb.query_update(txn, query, offset, limit, &update.0)?;
            }
            _ => return Err(IdrisDbError::IllegalArgument {}),
        };
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_update_new() -> *mut CIDRISDBUpdate {
    Box::into_raw(Box::new(CIDRISDBUpdate(Vec::new())))
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_update_add_value(
    update: &'static mut CIDRISDBUpdate,
    property_index: u16,
    value: *mut IDRISDBValue,
) {
    let value = if !value.is_null() {
        Some(*Box::from_raw(value))
    } else {
        None
    };
    update.0.push((property_index, value));
}
