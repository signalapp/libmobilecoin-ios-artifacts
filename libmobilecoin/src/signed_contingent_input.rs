// Copyright (c) 2018-2022 The MobileCoin Foundation
//

use crate::{
    common::*,
    fog::McFogResolver,
    keys::{McAccountKey, McPublicAddress},
    LibMcError,
};
use core::convert::TryFrom;
use mc_account_keys::{AccountKey, PublicAddress};
use mc_crypto_keys::{ReprBytes, RistrettoPrivate, RistrettoPublic};
use mc_crypto_ring_signature_signer::NoKeysRingSigner;
use mc_fog_report_resolver::FogResolver;
use mc_transaction_builder::{
    InputCredentials, ReservedSubaddresses, SignedContingentInputBuilder,
};
use mc_transaction_core::{
    onetime_keys::recover_onetime_private_key,
    tx::TxOut,
    Amount, BlockVersion, TokenId,
};

use mc_transaction_extra::{
    SignedContingentInput, TxOutConfirmationNumber,
};

use crate::transaction::{
    McTransactionBuilderRing, McTxOutMemoBuilder,
};

use mc_util_ffi::*;


/* ==== McSignedContingentInputBuilder ==== */

pub type McSignedContingentInputBuilder = Option<SignedContingentInputBuilder<FogResolver>>;
impl_into_ffi!(Option<SignedContingentInputBuilder<FogResolver>>);

///
/// # Errors
///
/// * `LibMcError::InvalidInput`
#[no_mangle]
pub extern "C" fn mc_signed_contingent_input_builder_create(
    block_version: u32,
    tombstone_block: u64,
    fog_resolver: FfiOptRefPtr<McFogResolver>,
    memo_builder: FfiMutPtr<McTxOutMemoBuilder>,
    view_private_key: FfiRefPtr<McBuffer>,
    subaddress_spend_private_key: FfiRefPtr<McBuffer>,
    real_index: usize,
    ring: FfiRefPtr<McTransactionBuilderRing>,
    out_error: FfiOptMutPtr<FfiOptOwnedPtr<McError>>,
) -> FfiOptOwnedPtr<McSignedContingentInputBuilder> {
    ffi_boundary_with_error(out_error, || {
        let fog_resolver =
            fog_resolver
                .as_ref()
                .map_or_else(FogResolver::default, |fog_resolver| {
                    // It is safe to add an expect here (which should never occur) because
                    // fogReportUrl is already checked in mc_fog_resolver_add_report_response
                    // to be convertible to FogUri
                    FogResolver::new(fog_resolver.0.clone(), &fog_resolver.1)
                        .expect("FogResolver could not be constructed from the provided materials")
                });
        let block_version = BlockVersion::try_from(block_version)?;

        let memo_builder_box = memo_builder
            .into_mut()
            .take()
            .expect("McTxOutMemoBuilder has already been used to build a Tx");

        // All this to create the InputCredentials
        let view_private_key = RistrettoPrivate::try_from_ffi(&view_private_key)
            .expect("view_private_key is not a valid RistrettoPrivate");
        let subaddress_spend_private_key =
            RistrettoPrivate::try_from_ffi(&subaddress_spend_private_key)
                .expect("subaddress_spend_private_key is not a valid RistrettoPrivate");
        let membership_proofs = ring.iter().map(|element| element.1.clone()).collect();
        let ring: Vec<TxOut> = ring.iter().map(|element| element.0.clone()).collect();
        let input_tx_out = ring
            .get(real_index)
            .expect("real_index not in bounds of ring")
            .clone();
        let target_key = RistrettoPublic::try_from(&input_tx_out.target_key)
            .expect("input_tx_out.target_key is not a valid RistrettoPublic");
        let public_key = RistrettoPublic::try_from(&input_tx_out.public_key)
            .expect("input_tx_out.public_key is not a valid RistrettoPublic");

        let onetime_private_key = recover_onetime_private_key(
            &public_key,
            &view_private_key,
            &subaddress_spend_private_key,
        );
        if RistrettoPublic::from(&onetime_private_key) != target_key {
            panic!("TxOut at real_index isn't owned by account key");
        }
        let input_credentials = InputCredentials::new(
            ring,
            membership_proofs,
            real_index,
            onetime_private_key,
            view_private_key, // `a`
        )
        .map_err(|err| LibMcError::InvalidInput(format!("{:?}", err)))?;

        let mut signed_contingent_input_builder = SignedContingentInputBuilder::new_with_box(
            block_version,
            input_credentials,
            fog_resolver,
            memo_builder_box,
        )
        .expect("failure not expected");

        signed_contingent_input_builder.set_tombstone_block(tombstone_block);
        Ok(Some(signed_contingent_input_builder))
    })
}

#[no_mangle]
pub extern "C" fn mc_signed_contingent_input_builder_free(
    signed_contingent_input_builder: FfiOptOwnedPtr<McSignedContingentInputBuilder>,
) {
    ffi_boundary(|| {
        let _ = signed_contingent_input_builder;
    })
}

/// # Preconditions
///
/// * `signed_contingent_input_builder` - must not have been previously consumed by a call
///   to `build`.
/// * `recipient_address` - must be a valid `PublicAddress`.
/// * `out_subaddress_spend_public_key` - length must be >= 32.
///
/// # Errors
///
/// * `LibMcError::InvalidInput`
#[no_mangle]
pub extern "C" fn mc_signed_contingent_input_builder_add_required_output(
    signed_contingent_input_builder: FfiMutPtr<McSignedContingentInputBuilder>,
    amount: u64,
    token_id: u64,
    recipient_address: FfiRefPtr<McPublicAddress>,
    rng_callback: FfiOptMutPtr<McRngCallback>,
    out_tx_out_confirmation_number: FfiMutPtr<McMutableBuffer>,
    out_error: FfiOptMutPtr<FfiOptOwnedPtr<McError>>,
) -> FfiOptOwnedPtr<McData> {
    ffi_boundary_with_error(out_error, || {
        let signed_contingent_input_builder = signed_contingent_input_builder
            .into_mut()
            .as_mut()
            .expect("McSignedContingentInputBuilder instance has already been used to build");

        let recipient_address =
            PublicAddress::try_from_ffi(&recipient_address).expect("recipient_address is invalid");
        let mut rng = SdkRng::from_ffi(rng_callback);

        let out_tx_out_confirmation_number = out_tx_out_confirmation_number
            .into_mut()
            .as_slice_mut_of_len(TxOutConfirmationNumber::size())
            .expect("out_tx_out_confirmation_number length is insufficient");

        let amount = Amount {
            value: amount,
            token_id: TokenId::from(token_id),
        };

        let (tx_out, tx_out_confirmation_number) =
            signed_contingent_input_builder.add_required_output(amount, &recipient_address, &mut rng)?;

        out_tx_out_confirmation_number.copy_from_slice(tx_out_confirmation_number.as_ref());

        Ok(mc_util_serial::encode(&tx_out))
    })
}


/// # Preconditions
///
/// * `account_key` - must be a valid account key, default change address
///   computed from account key
/// * `transaction_builder` - must not have been previously consumed by a call
///   to `build`.
/// * `out_tx_out_confirmation_number` - length must be >= 32.
///
/// # Errors
///
/// * `LibMcError::InvalidInput`
#[no_mangle]
pub extern "C" fn mc_signed_contingent_input_builder_add_required_change_output(
    account_key: FfiRefPtr<McAccountKey>,
    signed_contingent_input_builder: FfiMutPtr<McSignedContingentInputBuilder>,
    amount: u64,
    token_id: u64,
    rng_callback: FfiOptMutPtr<McRngCallback>,
    out_tx_out_confirmation_number: FfiMutPtr<McMutableBuffer>,
    out_error: FfiOptMutPtr<FfiOptOwnedPtr<McError>>,
) -> FfiOptOwnedPtr<McData> {
    ffi_boundary_with_error(out_error, || {
        let account_key_obj =
            AccountKey::try_from_ffi(&account_key).expect("account_key is invalid");
        let signed_contingent_input_builder = signed_contingent_input_builder
            .into_mut()
            .as_mut()
            .expect("McSignedContingentInputBuilder instance has already been used to build");
        let change_destination = ReservedSubaddresses::from(&account_key_obj);
        let mut rng = SdkRng::from_ffi(rng_callback);

        let out_tx_out_confirmation_number = out_tx_out_confirmation_number
            .into_mut()
            .as_slice_mut_of_len(TxOutConfirmationNumber::size())
            .expect("out_tx_out_confirmation_number length is insufficient");

        let amount = Amount {
            value: amount,
            token_id: TokenId::from(token_id),
        };

        let (tx_out, tx_out_confirmation_number) =
            signed_contingent_input_builder.add_required_change_output(amount, &change_destination, &mut rng)?;

        out_tx_out_confirmation_number.copy_from_slice(tx_out_confirmation_number.as_ref());

        Ok(mc_util_serial::encode(&tx_out))
    })
}

/// # Preconditions
///
/// * `signed_contingent_input_builder` - must not have been previously consumed by a call
///   to `build`.
///
/// # Errors
///
/// * `LibMcError::InvalidInput`
#[no_mangle]
pub extern "C" fn mc_signed_contingent_input_builder_build(
    signed_contingent_input_builder: FfiMutPtr<McSignedContingentInputBuilder>,
    rng_callback: FfiOptMutPtr<McRngCallback>,
    ring: FfiRefPtr<McTransactionBuilderRing>,
    out_error: FfiOptMutPtr<FfiOptOwnedPtr<McError>>,
) -> FfiOptOwnedPtr<McData> {
    ffi_boundary_with_error(out_error, || {
        let signed_contingent_input_builder = signed_contingent_input_builder
            .into_mut()
            .take()
            .expect("SignedContingentInputBuilder instance has already been used to build an SCI");
        let mut rng = SdkRng::from_ffi(rng_callback);

        let mut sci = signed_contingent_input_builder
            .build(&NoKeysRingSigner {}, &mut rng)
            .map_err(|err| LibMcError::InvalidInput(format!("{:?}", err)))?;

        let membership_proofs = ring.iter().map(|element| element.1.clone()).collect();
        sci.tx_in.proofs = membership_proofs;

        Ok(mc_util_serial::encode(&sci))
    })
}


/// # Preconditions
///
/// * `sci_data` - valid sci data
///
/// # Errors
///
/// * `LibMcError::InvalidInput`
#[no_mangle]
pub extern "C" fn mc_signed_contingent_input_data_is_valid(
    sci_data: FfiRefPtr<McBuffer>,
    out_valid: FfiMutPtr<bool>,
    out_error: FfiOptMutPtr<FfiOptOwnedPtr<McError>>,
) -> bool {
    ffi_boundary_with_error(out_error, || {

        let sci : SignedContingentInput = mc_util_serial::decode(&sci_data)
            .expect("SignedContingentInput decoding from protobuf data failed");

        *out_valid.into_mut() = sci.validate().is_ok();

        Ok(())
    })
}
