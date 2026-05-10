#![allow(unreachable_patterns)]

use crate::{IDRISDB_to_i64, CIDRISDBInstance, CIDRISDBTxn, CIDRISDBWriter, IDRISDBI64};
use idris_db_core::core::error::IdrisDbError;
use idris_db_core::core::insert::IDRISDBInsert;
use idris_db_core::core::instance::IDRISDBInstance;

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_insert(
    IdrisDb: &'static CIDRISDBInstance,
    txn: *mut CIDRISDBTxn,
    collection_index: u16,
    count: u32,
    insert: *mut *const CIDRISDBWriter,
) -> u8 {
    IDRISDB_try! {
        let txn = *Box::from_raw(txn);
        let new_insert = match (IdrisDb, txn) {
            #[cfg(feature = "native")]
            (CIDRISDBInstance::Native(IdrisDb), CIDRISDBTxn::Native(txn)) => {
                let insert = IdrisDb.insert(txn, collection_index, count)?;
                CIDRISDBWriter::Native(insert)
            }
            #[cfg(feature = "sqlite")]
            (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBTxn::SQLite(txn)) => {
                let insert = IdrisDb.insert(txn, collection_index, count)?;
                CIDRISDBWriter::SQLite(insert)
            }
            _ => return Err(IdrisDbError::IllegalArgument {}),
        };
        *insert = Box::into_raw(Box::new(new_insert));
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_insert_save(insert: &mut CIDRISDBWriter<'static>, id: IDRISDBI64) -> u8 {
    let id = IDRISDB_to_i64(id);
    IDRISDB_try! {
        match insert {
            #[cfg(feature = "native")]
            CIDRISDBWriter::Native(insert) => insert.save(id)?,
            #[cfg(feature = "sqlite")]
            CIDRISDBWriter::SQLite(insert) => insert.save(id)?,
            _ => return Err(IdrisDbError::IllegalArgument {}),
        };
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_insert_finish(
    insert: *mut CIDRISDBWriter,
    txn: *mut *const CIDRISDBTxn,
) -> u8 {
    IDRISDB_try! {
        let insert = *Box::from_raw(insert);
        let new_txn = match insert {
            #[cfg(feature = "native")]
            CIDRISDBWriter::Native(insert) => CIDRISDBTxn::Native(insert.finish()?),
            #[cfg(feature = "sqlite")]
            CIDRISDBWriter::SQLite(insert) => CIDRISDBTxn::SQLite(insert.finish()?),
            _ => return Err(IdrisDbError::IllegalArgument {}),
        };
        *txn = Box::into_raw(Box::new(new_txn));
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_insert_abort(insert: *mut CIDRISDBWriter) {
    let _ = *Box::from_raw(insert);
}
