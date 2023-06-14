//
//  TestVectorImports.swift
//  
//
//  Created by Adam Mork on 4/25/23.
//

import XCTest
import Foundation
import LibMobileCoinTestVector

///
/// Importing eact test-vector file to ensure proper SPM packaging.
/// Testing one file would likely give the same signal but doing all
/// for completeness
///
final class TestVectorImports: XCTestCase {
    func testAcctPrivKeysFromBip39() throws {
        let filename = "acct_priv_keys_from_bip39"
        let url = try Bundle.testVectorModuleUrl(filename)
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertNotNil(text)
    }

    func testAcctPrivKeysFromRootEntropy() throws {
        let filename = "acct_priv_keys_from_root_entropy"
        let url = try Bundle.testVectorModuleUrl(filename)
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertNotNil(text)
    }

    func testb58EncodePublicAddressWithFog() throws {
        let filename = "b58_encode_public_address_with_fog"
        let url = try Bundle.testVectorModuleUrl(filename)
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertNotNil(text)
    }

    func testb58EncodePublicAddressWithoutFog() throws {
        let filename = "b58_encode_public_address_without_fog"
        let url = try Bundle.testVectorModuleUrl(filename)
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertNotNil(text)
    }

    func testCorrectEncryptedDestinationMemos() throws {
        let filename = "correct_encrypted_destination_memos"
        let url = try Bundle.testVectorModuleUrl(filename)
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertNotNil(text)
    }

    func testCorrectEncryptedSenderMemos() throws {
        let filename = "correct_encrypted_sender_memos"
        let url = try Bundle.testVectorModuleUrl(filename)
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertNotNil(text)
    }

    func testCorrectEncryptedSenderWithPaymentRequestIdMemos() throws {
        let filename = "correct_encrypted_sender_with_payment_request_id_memos"
        let url = try Bundle.testVectorModuleUrl(filename)
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertNotNil(text)
    }

    func testCorrectTxOutRecords() throws {
        let filename = "correct_tx_out_records"
        let url = try Bundle.testVectorModuleUrl(filename)
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertNotNil(text)
    }

    func testDefaultSubaddrKeysFromAcctPrivKeys() throws {
        let filename = "default_subaddr_keys_from_acct_priv_keys"
        let url = try Bundle.testVectorModuleUrl(filename)
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertNotNil(text)
    }

    func testIncorrectEncryptedSenderMemos() throws {
        let filename = "incorrect_encrypted_sender_memos"
        let url = try Bundle.testVectorModuleUrl(filename)
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertNotNil(text)
    }

    func testIncorrectEncryptedSenderWithPaymentRequestIdMemos() throws {
        let filename = "incorrect_encrypted_sender_with_payment_request_id_memos"
        let url = try Bundle.testVectorModuleUrl(filename)
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertNotNil(text)
    }

    func testIncorrectTxOutRecords() throws {
        let filename = "incorrect_tx_out_records"
        let url = try Bundle.testVectorModuleUrl(filename)
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertNotNil(text)
    }

    func testSubaddrKeysFromAcctPrivKeys() throws {
        let filename = "subaddr_keys_from_acct_priv_keys"
        let url = try Bundle.testVectorModuleUrl(filename)
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertNotNil(text)
    }
}
