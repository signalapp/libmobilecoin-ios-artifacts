//
//  StaticLibraryAPI.swift
//  
//
//  Created by Adam Mork on 4/26/23.
//

import XCTest
import LibMobileCoin

///
/// Testing one function from each rust file to make sure they're all available in the
/// static library. Some data is invalid and will throw errors, thats ok.
///
final class StaticLibraryAPI: XCTestCase {
    func testAttestHeader() throws {
        let data = Data()
        let _ = data.asMcBuffer({ ptr in
            mc_mr_enclave_verifier_create(ptr)
        })
        XCTAssertTrue(true)
    }
    
    func testBip39Header() throws {
        let data = Data()
        let _ = data.asMcBuffer({ ptr in
            mc_bip39_mnemonic_from_entropy(ptr)
        })
        XCTAssertTrue(true)
    }
    
    func testChaCha20Header() throws {
        let value = UInt64(0)
        var error: UnsafeMutablePointer<McError>?
        mc_chacha20_rng_create_with_long(value, &error)
        XCTAssertTrue(true)
    }
    
    func testCryptoHeader() throws {
        let data = Data()
        var bool = true
        let _ = data.asMcBuffer({ ptr in
            mc_ristretto_private_validate(ptr, &bool)
        })
        XCTAssertTrue(true)
    }
    
    func testEncodingsHeader() throws {
        let data = Data()
        let _ = data.asMcBuffer({ ptr in
            mc_printable_wrapper_b58_encode(ptr)
        })
        XCTAssertTrue(true)
    }
    
    func testFogHeader() throws {
        let ptr = OpaquePointer(bitPattern: 1)!
        let data = Data()
        var error: UnsafeMutablePointer<McError>?
        let _ = data.asMcBuffer({ reportResponsePtr in
            mc_fog_resolver_add_report_response(
                ptr,
                "reportUrl.url.absoluteString",
                reportResponsePtr,
                &error)
        })
        XCTAssertTrue(true)
    }
    
    func testKeysHeader() throws {
        let viewPrivateKey = Data()
        let spendPrivateKey = Data()
        let subaddressIndex = UInt64(0)
        var subaddressViewPrivateKeyOut = Data()
        var subaddressSpendPrivateKeyOut = Data()
        let _ = viewPrivateKey.asMcBuffer { viewKeyBufferPtr in
            spendPrivateKey.asMcBuffer { spendKeyBufferPtr in
                subaddressViewPrivateKeyOut.asMcMutableBuffer { viewPrivateKeyOutPtr in
                    subaddressSpendPrivateKeyOut.asMcMutableBuffer { spendPrivateKeyOutPtr in
                        mc_account_key_get_subaddress_private_keys(
                            viewKeyBufferPtr,
                            spendKeyBufferPtr,
                            subaddressIndex,
                            viewPrivateKeyOutPtr,
                            spendPrivateKeyOutPtr)
                    }
                }
            }
        }
        XCTAssertTrue(true)
    }
    
    func testSCIHeader() throws {
        let sci = Data()
        var errorPtr: UnsafeMutablePointer<McError>?
        
        let _ = sci.asMcBuffer { sciPtr in
            mc_signed_contingent_input_data_is_valid(
                sciPtr,
                &errorPtr
            )
        }
        XCTAssertTrue(true)
    }
    
    func testSlip10Header() throws {
        let accountIndex = UInt32(0)
        var viewPrivateKeyOut = Data()
        var spendPrivateKeyOut = Data()
        var errorPtr: UnsafeMutablePointer<McError>?
        let _ = viewPrivateKeyOut.asMcMutableBuffer { viewPrivateKeyOutPtr in
            spendPrivateKeyOut.asMcMutableBuffer { spendPrivateKeyOutPtr in
                mc_slip10_account_private_keys_from_mnemonic(
                    "mnemonic.phrase",
                    accountIndex,
                    viewPrivateKeyOutPtr,
                    spendPrivateKeyOutPtr,
                    &errorPtr)
            }
        }
        XCTAssertTrue(true)
    }
    
    func testTransactionHeader() throws {
        let publicKey = Data()
        let viewPrivateKey = Data()
        var buffer = Data()
        var errorPtr: UnsafeMutablePointer<McError>?
        let _ = publicKey.asMcBuffer { publicKeyBufferPtr in
            viewPrivateKey.asMcBuffer { viewPrivateKeyPtr in
                buffer.asMcMutableBuffer { bufferPtr in
                    mc_tx_out_get_shared_secret(
                        viewPrivateKeyPtr,
                        publicKeyBufferPtr,
                        bufferPtr,
                        &errorPtr)
                }
            }
        }
        XCTAssertTrue(true)
    }
}

extension Data {
    func asMcBuffer<T>(_ body: (UnsafePointer<McBuffer>) throws -> T) rethrows -> T {
        try self.withUnsafeBytes {
            let ptr : UnsafeBufferPointer<UInt8> = $0.bindMemory(to: UInt8.self)
            guard let bufferPtr = ptr.baseAddress else {
                // This indicates a programming error. Pointer returned from withUnsafeBytes
                // shouldn't have a nil baseAddress.
                throw TestingError.unknown
            }
            var buffer = McBuffer(buffer: bufferPtr, len: ptr.count)
            return try body(&buffer)
        }
    }
    
    mutating func asMcMutableBuffer<T>(
        _ body: (UnsafeMutablePointer<McMutableBuffer>) throws -> T
    ) rethrows -> T {
        try withUnsafeMutableBytes {
            let ptr : UnsafeMutableBufferPointer<UInt8> = $0.bindMemory(to: UInt8.self)
            guard let bufferPtr = ptr.baseAddress else {
                // This indicates a programming error. Pointer returned from withUnsafeMutableBytes
                // shouldn't have a nil baseAddress.
                throw TestingError.unknown
            }
            var buffer = McMutableBuffer(buffer: bufferPtr, len: ptr.count)
            return try body(&buffer)
        }
    }
}

enum TestingError: Error {
    case unknown
}
