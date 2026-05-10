#![allow(unreachable_patterns)]

use crate::{CIDRISDBInstance, CIDRISDBQuery, CIDRISDBQueryBuilder, CIDRISDBQueryCursor, CIDRISDBTxn};
use idris_db_core::core::error::IdrisDbError;
use idris_db_core::core::filter::Filter;
use idris_db_core::core::instance::{Aggregation, IDRISDBInstance};
use idris_db_core::core::query_builder::{IDRISDBQueryBuilder, Sort};
use idris_db_core::core::value::IDRISDBValue;
use std::ptr;

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_query_new(
    IdrisDb: &'static CIDRISDBInstance,
    collection_index: u16,
    query_builder: *mut *const CIDRISDBQueryBuilder,
) -> u8 {
    IDRISDB_try! {
        let new_builder = match IdrisDb {
            #[cfg(feature = "native")]
            CIDRISDBInstance::Native(IdrisDb) => CIDRISDBQueryBuilder::Native(IdrisDb.query(collection_index)?),
            #[cfg(feature = "sqlite")]
            CIDRISDBInstance::SQLite(IdrisDb) => CIDRISDBQueryBuilder::SQLite(IdrisDb.query(collection_index)?),
        };
        *query_builder = Box::into_raw(Box::new(new_builder));
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_query_set_filter(
    builder: &'static mut CIDRISDBQueryBuilder,
    filter: *mut Filter,
) {
    let filter = *Box::from_raw(filter);
    match builder {
        #[cfg(feature = "native")]
        CIDRISDBQueryBuilder::Native(builder) => builder.set_filter(filter),
        #[cfg(feature = "sqlite")]
        CIDRISDBQueryBuilder::SQLite(builder) => builder.set_filter(filter),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_query_add_sort(
    builder: &'static mut CIDRISDBQueryBuilder,
    property_index: u16,
    ascending: bool,
    case_sensitive: bool,
) {
    let sort = if ascending { Sort::Asc } else { Sort::Desc };
    match builder {
        #[cfg(feature = "native")]
        CIDRISDBQueryBuilder::Native(builder) => {
            builder.add_sort(property_index, sort, case_sensitive)
        }
        #[cfg(feature = "sqlite")]
        CIDRISDBQueryBuilder::SQLite(builder) => {
            builder.add_sort(property_index, sort, case_sensitive)
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_query_add_distinct(
    builder: &'static mut CIDRISDBQueryBuilder,
    property_index: u16,
    case_sensitive: bool,
) {
    match builder {
        #[cfg(feature = "native")]
        CIDRISDBQueryBuilder::Native(builder) => builder.add_distinct(property_index, case_sensitive),
        #[cfg(feature = "sqlite")]
        CIDRISDBQueryBuilder::SQLite(builder) => builder.add_distinct(property_index, case_sensitive),
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_query_build(builder: *mut CIDRISDBQueryBuilder) -> *mut CIDRISDBQuery {
    let builder = *Box::from_raw(builder);
    match builder {
        #[cfg(feature = "native")]
        CIDRISDBQueryBuilder::Native(builder) => {
            let query = builder.build();
            Box::into_raw(Box::new(CIDRISDBQuery::Native(query)))
        }
        #[cfg(feature = "sqlite")]
        CIDRISDBQueryBuilder::SQLite(builder) => {
            let query = builder.build();
            Box::into_raw(Box::new(CIDRISDBQuery::SQLite(query)))
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_query_cursor(
    IdrisDb: &'static CIDRISDBInstance,
    txn: &'static CIDRISDBTxn,
    query: &'static CIDRISDBQuery,
    cursor: *mut *const CIDRISDBQueryCursor,
    offset: u32,
    limit: u32,
) -> u8 {
    let offset = if offset == 0 { None } else { Some(offset) };
    let limit = if limit == 0 { None } else { Some(limit) };

    IDRISDB_try! {
        let new_cursor = match (IdrisDb, txn, query) {
            #[cfg(feature = "native")]
            (CIDRISDBInstance::Native(IdrisDb), CIDRISDBTxn::Native(txn), CIDRISDBQuery::Native(query)) => {
                let cursor = IdrisDb.query_cursor(txn, query, offset, limit)?;
                CIDRISDBQueryCursor::Native(cursor)
            }
            #[cfg(feature = "sqlite")]
            (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBTxn::SQLite(txn), CIDRISDBQuery::SQLite(query)) => {
                let cursor = IdrisDb.query_cursor(txn, query, offset, limit)?;
                CIDRISDBQueryCursor::SQLite(cursor)
            }
            _ => return Err(IdrisDbError::IllegalArgument {}),
        };
        *cursor = Box::into_raw(Box::new(new_cursor));
    }
}

pub const AGGREGATION_COUNT: u8 = 0;
pub const AGGREGATION_IS_EMPTY: u8 = 1;
pub const AGGREGATION_MIN: u8 = 2;
pub const AGGREGATION_MAX: u8 = 3;
pub const AGGREGATION_SUM: u8 = 4;
pub const AGGREGATION_AVERAGE: u8 = 5;

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_query_aggregate(
    IdrisDb: &'static CIDRISDBInstance,
    txn: &'static CIDRISDBTxn,
    query: &'static CIDRISDBQuery,
    aggregation: u8,
    property_index: u16,
    value: *mut *const IDRISDBValue,
) -> u8 {
    let aggregation = match aggregation {
        AGGREGATION_COUNT => Aggregation::Count,
        AGGREGATION_IS_EMPTY => Aggregation::IsEmpty,
        AGGREGATION_MIN => Aggregation::Min,
        AGGREGATION_MAX => Aggregation::Max,
        AGGREGATION_SUM => Aggregation::Sum,
        AGGREGATION_AVERAGE => Aggregation::Average,
        _ => {
            *value = ptr::null();
            return 0;
        }
    };
    IDRISDB_try! {
        let new_value = match (IdrisDb, txn, query) {
            #[cfg(feature = "native")]
            (CIDRISDBInstance::Native(IdrisDb), CIDRISDBTxn::Native(txn), CIDRISDBQuery::Native(query)) => {
                IdrisDb.query_aggregate(txn, query, aggregation, Some(property_index))?
            }
            #[cfg(feature = "sqlite")]
            (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBTxn::SQLite(txn), CIDRISDBQuery::SQLite(query)) => {
                IdrisDb.query_aggregate(txn, query, aggregation, Some(property_index))?
            }
            _ => return Err(IdrisDbError::IllegalArgument {}),
        };
        if let Some(new_value) = new_value {
            *value = Box::into_raw(Box::new(new_value));
        } else {
            *value = ptr::null();
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_query_delete(
    IdrisDb: &'static CIDRISDBInstance,
    txn: &'static CIDRISDBTxn,
    query: &'static CIDRISDBQuery,
    offset: u32,
    limit: u32,
    count: *mut u32,
) -> u8 {
    let offset = if offset == 0 { None } else { Some(offset) };
    let limit = if limit == 0 { None } else { Some(limit) };
    IDRISDB_try! {
        let new_count = match (IdrisDb, txn, query) {
            #[cfg(feature = "native")]
            (CIDRISDBInstance::Native(IdrisDb), CIDRISDBTxn::Native(txn), CIDRISDBQuery::Native(query)) => {
                IdrisDb.query_delete(txn, query, offset, limit)?
            }
            #[cfg(feature = "sqlite")]
            (CIDRISDBInstance::SQLite(IdrisDb), CIDRISDBTxn::SQLite(txn), CIDRISDBQuery::SQLite(query)) => {
                IdrisDb.query_delete(txn, query, offset, limit)?
            }
            _ => return Err(IdrisDbError::IllegalArgument {}),
        };
        *count = new_count;
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_query_free(query: *mut CIDRISDBQuery) {
    if !query.is_null() {
        drop(Box::from_raw(query));
    }
}
