// Copyright (c) 2018-2023 The MobileCoin Foundation

use crate::{common::*, LibMcError};
use mc_api::blockchain::ArchiveBlock;
use mc_blockchain_types::BlockData;
use mc_util_ffi::*;
use protobuf::Message;

/* ==== BlockData ==== */

pub type McBlockData = BlockData;
impl_into_ffi!(McBlockData);

#[no_mangle]
pub extern "C" fn mc_block_data_from_archive_block_protobuf(
    archive_block_protobuf: FfiRefPtr<McBuffer>,
    out_error: FfiOptMutPtr<FfiOptOwnedPtr<McError>>,
) -> FfiOptOwnedPtr<McBlockData> {
    ffi_boundary_with_error(out_error, || {
        let archive_block = ArchiveBlock::parse_from_bytes(archive_block_protobuf.as_slice())?;
        let block_data = BlockData::try_from(&archive_block)
            .map_err(|err| LibMcError::InvalidInput(format!("archive_block_proto: {}", err)))?;
        Ok(block_data)
    })
}

#[no_mangle]
pub extern "C" fn mc_block_data_free(block_data: FfiOptOwnedPtr<McBlockData>) {
    ffi_boundary(|| {
        let _ = block_data;
    })
}

/* ==== BlockDataVec ==== */

pub type McBlockDataVec = Vec<BlockData>;
impl_into_ffi!(McBlockDataVec);

#[no_mangle]
pub extern "C" fn mc_block_data_vec_create() -> FfiOptOwnedPtr<McBlockDataVec> {
    ffi_boundary(Vec::new)
}

#[no_mangle]
pub extern "C" fn mc_block_data_vec_free(block_data_vec: FfiOptOwnedPtr<McBlockDataVec>) {
    ffi_boundary(|| {
        let _ = block_data_vec;
    })
}

#[no_mangle]
pub extern "C" fn mc_block_data_vec_add_element(
    block_data_vec: FfiMutPtr<McBlockDataVec>,
    block_data: FfiRefPtr<McBlockData>,
) -> bool {
    ffi_boundary(|| {
        block_data_vec.into_mut().push(block_data.as_ref().clone());
    })
}
