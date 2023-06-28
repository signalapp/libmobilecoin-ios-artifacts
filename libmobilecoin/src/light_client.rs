// Copyright (c) 2018-2023 The MobileCoin Foundation

use crate::{blockchain_types::McBlockDataVec, common::*, LibMcError};
use mc_light_client_verifier::{LightClientVerifier, LightClientVerifierConfig};
use mc_util_ffi::*;

/* ==== LightClientVerifier ==== */

pub type McLightClientVerifier = LightClientVerifier;
impl_into_ffi!(McLightClientVerifier);

#[no_mangle]
pub extern "C" fn mc_light_client_verifier_create(
    config_json: FfiStr,
    out_error: FfiOptMutPtr<FfiOptOwnedPtr<McError>>,
) -> FfiOptOwnedPtr<McLightClientVerifier> {
    ffi_boundary_with_error(out_error, || {
        let config_json_str = config_json
            .as_str()
            .map_err(|err| LibMcError::InvalidInput(format!("config_json: {}", err)))?;

        let lvc_conf = serde_json::from_str::<LightClientVerifierConfig>(config_json_str)
            .map_err(|err| LibMcError::InvalidInput(format!("config_json_str: {}", err)))?;

        Ok(LightClientVerifier::from(lvc_conf))
    })
}

#[no_mangle]
pub extern "C" fn mc_light_client_verifier_free(lcv: FfiOptOwnedPtr<McLightClientVerifier>) {
    ffi_boundary(|| {
        let _ = lcv;
    })
}

#[no_mangle]
pub extern "C" fn mc_light_client_verifier_verify_block_data_vec(
    lcv: FfiRefPtr<McLightClientVerifier>,
    block_data_vec: FfiRefPtr<McBlockDataVec>,
    out_error: FfiOptMutPtr<FfiOptOwnedPtr<McError>>,
) -> bool {
    ffi_boundary_with_error(out_error, || {
        let block_data_vec = block_data_vec.as_ref();

        lcv.verify_block_data(&block_data_vec[..])
            .map_err(|err| LibMcError::InvalidInput(format!("block_data_vec: {}", err)))?;

        Ok(())
    })
}
