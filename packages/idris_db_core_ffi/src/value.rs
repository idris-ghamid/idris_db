use crate::{i64_to_IDRISDB, IDRISDB_to_i64, IDRISDBI64};
use idris_db_core::core::value::IDRISDBValue;
use std::ptr;

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_value_bool(value: bool) -> *const IDRISDBValue {
    Box::into_raw(Box::new(IDRISDBValue::Bool(value)))
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_value_integer(value: IDRISDBI64) -> *const IDRISDBValue {
    let value = IDRISDB_to_i64(value);
    Box::into_raw(Box::new(IDRISDBValue::Integer(value)))
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_value_real(value: f64) -> *const IDRISDBValue {
    Box::into_raw(Box::new(IDRISDBValue::Real(value)))
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_value_string(value: *mut String) -> *const IDRISDBValue {
    Box::into_raw(Box::new(IDRISDBValue::String(*Box::from_raw(value))))
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_value_get_bool(value: *const IDRISDBValue) -> u8 {
    let value = value.as_ref().map(|v| v.bool()).flatten().unwrap_or(false);
    if value {
        1
    } else {
        0
    }
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_value_get_integer(value: *const IDRISDBValue) -> IDRISDBI64 {
    let value = value
        .as_ref()
        .map(|v| v.i64())
        .flatten()
        .unwrap_or(i64::MIN);
    i64_to_IDRISDB(value)
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_value_get_real(value: *const IDRISDBValue) -> f64 {
    value
        .as_ref()
        .map(|v| v.real())
        .flatten()
        .unwrap_or(f64::NAN)
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_value_get_string(
    value: *const IDRISDBValue,
    str: *mut *const u8,
) -> u32 {
    *str = ptr::null();
    if let Some(value) = value.as_ref().map(|v| v.string()).flatten() {
        *str = value.as_bytes().as_ptr();
        return value.len() as u32;
    }
    0
}

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_value_free(value: *mut IDRISDBValue) {
    if !value.is_null() {
        drop(Box::from_raw(value));
    }
}
