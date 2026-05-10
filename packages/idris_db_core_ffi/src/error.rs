use idris_db_core::core::error::IdrisDbError;
use std::cell::RefCell;

thread_local! {
    pub static ERROR: RefCell<Option<String>> = RefCell::new(None);
}

#[macro_export]
macro_rules! IDRISDB_try {
    { $($token:tt)* } => {{
        #[allow(unused_mut)] {
            let mut l = || -> idris_db_core::core::error::Result<()> {
                {$($token)*}
                #[allow(unreachable_code)]
                Ok(())
            };
            if let Err(err) = l() {
                if let Some(code) = crate::error::error_code(&err) {
                    crate::error::ERROR.replace(None);
                    code
                } else {
                    crate::error::ERROR.replace(Some(err.to_string()));
                    255
                }
            } else {
                0
            }
        }
    }}
}

pub const fn error_code(err: &IdrisDbError) -> Option<u8> {
    let code = match err {
        IdrisDbError::PathError {} => ERROR_PATH,
        IdrisDbError::WriteTxnRequired {} => ERROR_WRITE_TXN_REQUIRED,
        IdrisDbError::VersionError {} => ERROR_VERSION,
        IdrisDbError::ObjectLimitReached {} => ERROR_OBJECT_LIMIT_REACHED,
        IdrisDbError::InstanceMismatch {} => ERROR_INSTANCE_MISMATCH,
        IdrisDbError::EncryptionError {} => ERROR_ENCRYPTION,
        IdrisDbError::DbFull {} => ERROR_DB_FULL,
        _ => return None,
    };
    Some(code)
}

pub const ERROR_PATH: u8 = 1;
pub const ERROR_WRITE_TXN_REQUIRED: u8 = 2;
pub const ERROR_VERSION: u8 = 3;
pub const ERROR_OBJECT_LIMIT_REACHED: u8 = 4;
pub const ERROR_INSTANCE_MISMATCH: u8 = 5;
pub const ERROR_ENCRYPTION: u8 = 6;
pub const ERROR_DB_FULL: u8 = 7;

#[no_mangle]
pub unsafe extern "C" fn IDRISDB_get_error(value: *mut *const u8) -> u32 {
    ERROR.with_borrow(|e| {
        if let Some(msg) = e.as_ref() {
            *value = msg.as_ptr();
            msg.len() as u32
        } else {
            0
        }
    })
}

#[macro_export]
macro_rules! IDRISDB_pause_isolate {
    { $($token:tt)* } => {{
        if cfg!(target_arch = "wasm32") {
            {$($token)*}
        } else {
            crate::dart::dart_pause_isolate(|| {$($token)*})
        }
    }}
}
