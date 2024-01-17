// Copyright (c) 2018-2022 The MobileCoin Foundatio, timen

use crate::{common::*, LibMcError};
use aes_gcm::Aes256Gcm;
use core::str::FromStr;
use der::DateTime;
use libc::ssize_t;
use mc_attest_ake::{
    AuthPending, AuthResponseInput, AuthResponseOutput, ClientInitiate, Ready, Start, Transition,
};
use mc_attest_core::{MrEnclave, MrSigner};
use mc_attestation_verifier::{TrustedIdentity, TrustedMrEnclaveIdentity, TrustedMrSignerIdentity};
use mc_common::{ResponderId, time::{SystemTimeProvider, TimeProvider}};
use mc_crypto_keys::X25519;
use mc_crypto_noise::NoiseCipher;
use mc_rand::McRng;
use mc_util_ffi::*;
use sha2::Sha512;

pub type McTrustedMrEnclaveIdentity = TrustedMrEnclaveIdentity;
impl_into_ffi!(TrustedMrEnclaveIdentity);

pub type McTrustedMrSignerIdentity = TrustedMrSignerIdentity;
impl_into_ffi!(TrustedMrSignerIdentity);

#[no_mangle]
pub extern "C" fn mc_trusted_identity_mr_enclave_free(
    mr_enclave_trusted_identity: FfiOptOwnedPtr<McTrustedMrEnclaveIdentity>,
) {
    ffi_boundary(|| {
        let _ = mr_enclave_trusted_identity;
    })
}

/// Create a new mr enclave trusted identity 
///
/// # Preconditions
///
/// * `mr_enclave` - must be 32 bytes in length.
#[no_mangle]
pub extern "C" fn mc_trusted_identity_mr_enclave_create(
    mr_enclave: FfiRefPtr<McBuffer>,
    config_advisories: FfiRefPtr<McAdvisories>,
    hardening_advisories: FfiRefPtr<McAdvisories>,
) -> FfiOptOwnedPtr<McTrustedMrEnclaveIdentity> {
    ffi_boundary(|| {
        let mr_enclave = MrEnclave::try_from_ffi(&mr_enclave).expect("mr_enclave is invalid");

        let trusted_mr_enclave_identity = TrustedMrEnclaveIdentity::new(
            mr_enclave,
            &config_advisories.0,
            &hardening_advisories.0,
        );

        trusted_mr_enclave_identity
    })
}

#[no_mangle]
pub extern "C" fn mc_trusted_identity_mr_signer_free(
    mr_signer_trusted_identity: FfiOptOwnedPtr<McTrustedMrSignerIdentity>,
) {
    ffi_boundary(|| {
        let _ = mr_signer_trusted_identity;
    })
}

/// Create a new mr signer trusted identity 
///
/// # Preconditions
///
/// * `mr_signer` - must be 32 bytes in length.
#[no_mangle]
pub extern "C" fn mc_trusted_identity_mr_signer_create(
    mr_signer: FfiRefPtr<McBuffer>,
    config_advisories: FfiRefPtr<McAdvisories>,
    hardening_advisories: FfiRefPtr<McAdvisories>,
    expected_product_id: u16,
    minimum_security_version: u16,
) -> FfiOptOwnedPtr<McTrustedMrSignerIdentity> {
    ffi_boundary(|| {
        let mr_signer = MrSigner::try_from_ffi(&mr_signer).expect("mr_signer is invalid");

        let trusted_mr_signer_identity = TrustedMrSignerIdentity::new(
            mr_signer,
            expected_product_id.into(),
            minimum_security_version.into(),
            &config_advisories.0,
            &hardening_advisories.0
        );

        trusted_mr_signer_identity
    })
}

/// # Preconditions
///
/// * `mr_enclave_trusted_identity` - valid MrEnclaveTrustedIdentity.
/// * `out_advisories` - length is dynamic
///
#[no_mangle]
pub extern "C" fn mc_trusted_mr_enclave_identity_advisories_to_string(
    trusted_mr_enclave_identity: FfiRefPtr<McTrustedMrEnclaveIdentity>,
    out_advisories: FfiOptMutPtr<McMutableBuffer>,
) -> ssize_t {
    ffi_boundary(|| {
        let trusted_identity = (*trusted_mr_enclave_identity).clone();
        let advisories_description = trusted_identity.advisories().to_string();

        if let Some(out_advisories) = out_advisories.into_option() {
            out_advisories
                .into_mut()
                .as_slice_mut_of_len(advisories_description.len())
                .expect("Advisories description payload length is insufficient")
                .copy_from_slice(advisories_description.as_ref());
        }
        return ssize_t::ffi_try_from(advisories_description.len())
            .expect("advisories_description.len could not be converted to ssize_t");
    })
}

/// # Preconditions
///
/// * `mr_enclave_trusted_identity` - valid MrEnclaveTrustedIdentity.
/// * `out_enclave_measurement` - length is unknown
///
#[no_mangle]
pub extern "C" fn mc_trusted_mr_enclave_identity_to_string(
    trusted_mr_enclave_identity: FfiRefPtr<McTrustedMrEnclaveIdentity>,
    out_enclave_measurement: FfiOptMutPtr<McMutableBuffer>,
) -> ssize_t {
    ffi_boundary(|| {
        let trusted_identity = (*trusted_mr_enclave_identity).clone();
        let enclave_description = trusted_identity.mr_enclave().to_string();

        if let Some(out_enclave_measurement) = out_enclave_measurement.into_option() {
            out_enclave_measurement
                .into_mut()
                .as_slice_mut_of_len(enclave_description.len())
                .expect("Advisories description payload length is insufficient")
                .copy_from_slice(enclave_description.as_ref());
        }
        return ssize_t::ffi_try_from(enclave_description.len())
            .expect("enclave_description.len could not be converted to ssize_t");
    })
}

/// # Preconditions
///
/// * `mr_signer_trusted_identity` - valid MrSignerTrustedIdentity.
/// * `out_advisories` - length is dynamic
///
#[no_mangle]
pub extern "C" fn mc_trusted_mr_signer_identity_advisories_to_string(
    trusted_mr_signer_identity: FfiRefPtr<McTrustedMrSignerIdentity>,
    out_advisories: FfiOptMutPtr<McMutableBuffer>,
) -> ssize_t {
    ffi_boundary(|| {
        let trusted_identity = (*trusted_mr_signer_identity).clone();
        let advisories_description = trusted_identity.advisories().to_string();

        if let Some(out_advisories) = out_advisories.into_option() {
            out_advisories
                .into_mut()
                .as_slice_mut_of_len(advisories_description.len())
                .expect("Advisories description payload length is insufficient")
                .copy_from_slice(advisories_description.as_ref());
        }
        return ssize_t::ffi_try_from(advisories_description.len())
            .expect("advisories_description.len could not be converted to ssize_t");
    })
}

/// # Preconditions
///
/// * `mr_signer_trusted_identity` - valid MrSignerTrustedIdentity.
/// * `out_signer_measurement` - length is unknown
///
#[no_mangle]
pub extern "C" fn mc_trusted_mr_signer_identity_to_string(
    trusted_mr_signer_identity: FfiRefPtr<McTrustedMrSignerIdentity>,
    out_signer_measurement: FfiOptMutPtr<McMutableBuffer>,
) -> ssize_t {
    ffi_boundary(|| {
        let trusted_identity = (*trusted_mr_signer_identity).clone();
        let signer_description = trusted_identity.mr_signer().to_string();

        if let Some(out_signer_measurement) = out_signer_measurement.into_option() {
            out_signer_measurement
                .into_mut()
                .as_slice_mut_of_len(signer_description.len())
                .expect("Advisories description payload length is insufficient")
                .copy_from_slice(signer_description.as_ref());
        }
        return ssize_t::ffi_try_from(signer_description.len())
            .expect("signer_description.len could not be converted to ssize_t");
    })
}

/// Construct a new McAdvisories vector for holding config & hardening advisories
///
/// Advisories are used when an enclave with the specified measurement does not need
/// BIOS configuration changes to address the provided advisory ID.
///
#[no_mangle]
pub extern "C" fn mc_advisories_create() -> FfiOptOwnedPtr<McAdvisories> {
    ffi_boundary(|| {
        let advisories = McAdvisories(Vec::new());
        advisories
    })
}

#[no_mangle]
pub extern "C" fn mc_advisories_free(advisories: FfiOptOwnedPtr<McAdvisories>) {
    ffi_boundary(|| {
        let _ = advisories;
    })
}

/// Assume an enclave with the specified measurement does not need
/// BIOS configuration changes to address the provided advisory ID.
///
/// This method should only be used when advised by an enclave author.
///
/// # Preconditions
///
/// * `advisories` - a valid McAdvisories vector
/// * `advisory_id` - must be a nul-terminated C string containing valid UTF-8.
///
/// TODO: update comments above
#[no_mangle]
pub extern "C" fn mc_add_advisory(
    advisories: FfiMutPtr<McAdvisories>,
    advisory_id: FfiStr,
) -> bool {
    ffi_boundary(|| {
        let advisory_id = <&str>::try_from_ffi(advisory_id).expect("advisory_id is invalid");
        advisories.into_mut().0.push(String::from(advisory_id));
    })
}

pub type McTrustedIdentity = TrustedIdentity;
impl_into_ffi!(TrustedIdentity);

pub struct McTrustedIdentities (pub Vec<McTrustedIdentity>);
impl_into_ffi!(McTrustedIdentities);

pub struct McAdvisories (Vec<String>);
impl_into_ffi!(McAdvisories);

/// Construct a new TrustedIdentities vector that holds TrustedIdentity's (enclave or signer)
///
#[no_mangle]
pub extern "C" fn mc_trusted_identities_create() -> FfiOptOwnedPtr<McTrustedIdentities> {
    ffi_boundary(|| {
        let trusted_identities = McTrustedIdentities(Vec::new());
        trusted_identities
    })
}

#[no_mangle]
pub extern "C" fn mc_trusted_identities_free(trusted_identities: FfiOptOwnedPtr<McTrustedIdentities>) {
    ffi_boundary(|| {
        let _ = trusted_identities;
    })
}

/// 
#[no_mangle]
pub extern "C" fn mc_trusted_identities_add_mr_enclave(
    trusted_identities: FfiMutPtr<McTrustedIdentities>,
    trusted_mr_enclave_identity: FfiRefPtr<McTrustedMrEnclaveIdentity>,
) -> bool {
    ffi_boundary(|| {
        let trusted_identity = TrustedIdentity::MrEnclave((*trusted_mr_enclave_identity).clone());
        trusted_identities.into_mut().0.push(trusted_identity);
    })
}
/// 
#[no_mangle]
pub extern "C" fn mc_trusted_identities_add_mr_signer(
    trusted_identities: FfiMutPtr<McTrustedIdentities>,
    trusted_mr_signer_identity: FfiRefPtr<McTrustedMrSignerIdentity>,
) -> bool {
    ffi_boundary(|| {
        let trusted_identity = TrustedIdentity::MrSigner((*trusted_mr_signer_identity).clone());
        trusted_identities.into_mut().0.push(trusted_identity);
    })
}

pub enum AttestAke {
    NotAttested,
    AuthPending(AuthPending<X25519, Aes256Gcm, Sha512>),
    Attested(Ready<Aes256Gcm>),
}

impl AttestAke {
    pub fn new() -> Self {
        Self::NotAttested
    }

    pub fn is_attested(&self) -> bool {
        matches!(self, Self::Attested(_))
    }

    pub fn take_auth_pending(&mut self) -> Option<AuthPending<X25519, Aes256Gcm, Sha512>> {
        if let Self::AuthPending(_) = self {
            let state = std::mem::replace(self, Self::NotAttested);
            if let Self::AuthPending(auth_pending) = state {
                return Some(auth_pending);
            }
        }
        None
    }

    pub fn attest_cipher(&self) -> Option<&Ready<Aes256Gcm>> {
        match self {
            Self::Attested(attest_cipher) => Some(attest_cipher),
            _ => None,
        }
    }

    pub fn attest_cipher_mut(&mut self) -> Option<&mut Ready<Aes256Gcm>> {
        match self {
            Self::Attested(attest_cipher) => Some(attest_cipher),
            _ => None,
        }
    }
}

impl Default for AttestAke {
    fn default() -> Self {
        Self::new()
    }
}

pub type McAttestAke = AttestAke;
impl_into_ffi!(AttestAke);

#[no_mangle]
pub extern "C" fn mc_attest_ake_create() -> FfiOptOwnedPtr<McAttestAke> {
    ffi_boundary(AttestAke::new)
}

#[no_mangle]
pub extern "C" fn mc_attest_ake_free(attest_ake: FfiOptOwnedPtr<McAttestAke>) {
    ffi_boundary(|| {
        let _ = attest_ake;
    })
}

#[no_mangle]
pub extern "C" fn mc_attest_ake_is_attested(
    attest_ake: FfiRefPtr<McAttestAke>,
    out_attested: FfiMutPtr<bool>,
) -> bool {
    ffi_boundary(|| *out_attested.into_mut() = attest_ake.is_attested())
}

/// # Preconditions
///
/// * `attest_ake` - must be in the attested state.
/// * `out_binding` - must be null or else length must be >= `binding.len`.
#[no_mangle]
pub extern "C" fn mc_attest_ake_get_binding(
    attest_ake: FfiRefPtr<McAttestAke>,
    out_binding: FfiOptMutPtr<McMutableBuffer>,
) -> ssize_t {
    ffi_boundary(|| {
        let attest_cipher = attest_ake
            .attest_cipher()
            .expect("attest_ake is not in the attested state");

        let binding = attest_cipher.binding();

        if let Some(out_binding) = out_binding.into_option() {
            out_binding
                .into_mut()
                .as_slice_mut_of_len(binding.len())
                .expect("out_binding length is insufficient")
                .copy_from_slice(binding);
        }
        ssize_t::ffi_try_from(binding.len()).expect("binding.len could not be converted to ssize_t")
    })
}

/// # Preconditions
///
/// * `responder_id` - must be a nul-terminated C string containing a valid
///   responder ID.
/// * `out_auth_request` - must be null or else length must be >=
///   auth_request_output.len.
#[no_mangle]
pub extern "C" fn mc_attest_ake_get_auth_request(
    attest_ake: FfiMutPtr<McAttestAke>,
    responder_id: FfiStr,
    rng_callback: FfiOptMutPtr<McRngCallback>,
    out_auth_request: FfiOptMutPtr<McMutableBuffer>,
) -> ssize_t {
    ffi_boundary(|| {
        let responder_id =
            ResponderId::try_from_ffi(responder_id).expect("responder_id is invalid");
        let mut rng = SdkRng::from_ffi(rng_callback);

        let start = Start::new(responder_id.to_string());
        let init_input = ClientInitiate::<X25519, Aes256Gcm, Sha512>::default();
        let (auth_pending, auth_request_output) = start
            .try_next(&mut rng, init_input)
            .expect("Ake start transition is no fail");
        *attest_ake.into_mut() = AttestAke::AuthPending(auth_pending);

        let auth_request_output = auth_request_output.as_ref();
        if let Some(out_auth_request) = out_auth_request.into_option() {
            out_auth_request
                .into_mut()
                .as_slice_mut_of_len(auth_request_output.len())
                .expect("out_auth_request length is insufficient")
                .copy_from_slice(auth_request_output);
        }
        ssize_t::ffi_try_from(auth_request_output.len())
            .expect("auth_request_output.len could not be converted to ssize_t")
    })
}

/// # Preconditions
///
/// * `attest_ake` - must be in the auth pending state.
///
/// # Errors
///
/// * `LibMcError::AttestationVerificationFailed`
/// * `LibMcError::InvalidInput`
#[no_mangle]
pub extern "C" fn mc_attest_ake_process_auth_response(
    attest_ake: FfiMutPtr<McAttestAke>,
    auth_response_data: FfiRefPtr<McBuffer>,
    trusted_identities: FfiRefPtr<McTrustedIdentities>,
    out_error: FfiOptMutPtr<FfiOptOwnedPtr<McError>>,
) -> bool {
    ffi_boundary_with_error(out_error, || {
        let attest_ake = attest_ake.into_mut();
        let auth_pending = attest_ake
            .take_auth_pending()
            .expect("attest_ake is not in the auth pending state");

        let epoch_time = SystemTimeProvider::default()
            .since_epoch()
            .map_err(|_| LibMcError::AttestationVerificationFailed("Time went backwards".to_owned()))?;
        let time = DateTime::from_unix_duration(epoch_time)
            .map_err(|_| LibMcError::AttestationVerificationFailed("Time out of range".to_owned()))?;

        let auth_response_output = AuthResponseOutput::from(auth_response_data.to_vec());
        let auth_response_input = AuthResponseInput::new(auth_response_output, trusted_identities.0.clone(), time);
        let mut rng = McRng::default(); // This is actually unused.
        let (ready, _) = auth_pending.try_next(&mut rng, auth_response_input)?;
        *attest_ake = AttestAke::Attested(ready);

        Ok(())
    })
}

/// # Preconditions
///
/// * `attest_ake` - must be in the attested state.
/// * `out_ciphertext` - must be null or else length must be >=
///   `ciphertext.len`.
///
/// # Errors
///
/// * `LibMcError::Aead`
/// * `LibMcError::Cipher`
#[no_mangle]
pub extern "C" fn mc_attest_ake_encrypt(
    attest_ake: FfiMutPtr<McAttestAke>,
    aad: FfiRefPtr<McBuffer>,
    plaintext: FfiRefPtr<McBuffer>,
    out_ciphertext: FfiOptMutPtr<McMutableBuffer>,
    out_error: FfiOptMutPtr<FfiOptOwnedPtr<McError>>,
) -> ssize_t {
    ffi_boundary_with_error(out_error, || {
        let ciphertext_len = Aes256Gcm::ciphertext_len(plaintext.len());

        if let Some(out_ciphertext) = out_ciphertext.into_option() {
            let attest_cipher = attest_ake
                .into_mut()
                .attest_cipher_mut()
                .expect("attest_ake is not in the attested state");

            let ciphertext = attest_cipher.encrypt(aad.as_slice(), plaintext.as_slice())?;

            out_ciphertext
                .into_mut()
                .as_slice_mut_of_len(ciphertext_len)
                .expect("out_auth_request length is insufficient")
                .copy_from_slice(&ciphertext);
        }
        Ok(ssize_t::ffi_try_from(ciphertext_len)
            .expect("ciphertext.len could not be converted to ssize_t"))
    })
}

/// # Preconditions
///
/// * `attest_ake` - must be in the attested state.
/// * `out_plaintext` - length must be >= `ciphertext.len`.
///
/// # Errors
///
/// * `LibMcError::Aead`
/// * `LibMcError::Cipher`
#[no_mangle]
pub extern "C" fn mc_attest_ake_decrypt(
    attest_ake: FfiMutPtr<McAttestAke>,
    aad: FfiRefPtr<McBuffer>,
    ciphertext: FfiRefPtr<McBuffer>,
    out_plaintext: FfiMutPtr<McMutableBuffer>,
    out_error: FfiOptMutPtr<FfiOptOwnedPtr<McError>>,
) -> ssize_t {
    ffi_boundary_with_error(out_error, || {
        let attest_cipher = attest_ake
            .into_mut()
            .attest_cipher_mut()
            .expect("attest_ake is not in the attested state");

        let plaintext = attest_cipher.decrypt(aad.as_slice(), ciphertext.as_slice())?;

        out_plaintext
            .into_mut()
            .as_slice_mut_of_len(plaintext.len())
            .expect("out_plaintext length is insufficient")
            .copy_from_slice(&plaintext);
        Ok(ssize_t::ffi_try_from(plaintext.len())
            .expect("plaintext.len could not be converted to ssize_t"))
    })
}

impl<'a> TryFromFfi<&McBuffer<'a>> for MrEnclave {
    type Error = LibMcError;

    fn try_from_ffi(src: &McBuffer<'a>) -> Result<Self, LibMcError> {
        let src = <[u8; 32]>::try_from_ffi(src)?;
        Ok(MrEnclave::from(src))
    }
}

impl<'a> TryFromFfi<&McBuffer<'a>> for MrSigner {
    type Error = LibMcError;

    fn try_from_ffi(src: &McBuffer<'a>) -> Result<Self, LibMcError> {
        let src = <[u8; 32]>::try_from_ffi(src)?;
        Ok(MrSigner::from(src))
    }
}

impl<'a> TryFromFfi<FfiStr<'a>> for ResponderId {
    type Error = LibMcError;

    fn try_from_ffi(src: FfiStr<'a>) -> Result<Self, LibMcError> {
        let str = <&str>::try_from_ffi(src)?;
        ResponderId::from_str(str)
            .map_err(|err| LibMcError::InvalidInput(format!("Invalid responder id: {:?}", err)))
    }
}
