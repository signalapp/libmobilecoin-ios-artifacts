//
//  ProtobufImports.swift
//  
//
//  Created by Adam Mork on 4/24/23.
//

import XCTest
import LibMobileCoinCommon

///
/// Importing one class from each file to ensure proper SPM packaging.
/// Testing one file would likely give the same signal but doing one 
/// from each for completeness
///
final class ProtobufImports: XCTestCase {
    func testAttest() throws {
        let proto = Attest_AuthMessage()
        XCTAssertNotNil(proto)
    }
    
    func testBlockchain() throws {
        let proto = Blockchain_BlockID()
        XCTAssertNotNil(proto)
    }
    
    func testConsensusClient() throws {
        let proto = ConsensusClient_MintValidationResult()
        XCTAssertNotNil(proto)
    }
    
    func testConsensusCommon() throws {
        let proto = ConsensusCommon_LastBlockInfoResponse()
        XCTAssertNotNil(proto)
    }
    
    func testConsensusConfig() throws {
        let proto = ConsensusConfig_ActiveMintConfig()
        XCTAssertNotNil(proto)
    }
    
    func testExternal() throws {
        let proto = External_RistrettoPrivate()
        XCTAssertNotNil(proto)
    }
    
    func testFogCommon() throws {
        let proto = FogCommon_BlockRange()
        XCTAssertNotNil(proto)
    }
    
    func testKexRNG() throws {
        let proto = KexRng_KexRngPubkey()
        XCTAssertNotNil(proto)
    }
    
    func testLedger() throws {
        let proto = FogLedger_GetOutputsRequest()
        XCTAssertNotNil(proto)
    }
    
    func testLegacyView() throws {
        let proto = FogView_TxOutRecordLegacy()
        XCTAssertNotNil(proto)
    }
    
    func testPrintable() throws {
        let proto = Printable_PaymentRequest()
        XCTAssertNotNil(proto)
    }
    
    func testQuorumSet() throws {
        let proto = QuorumSet_Node()
        XCTAssertNotNil(proto)
    }
    
    func testReport() throws {
        let proto = Report_ReportRequest()
        XCTAssertNotNil(proto)
    }
    
    func testView() throws {
        let proto = FogView_QueryRequestAAD()
        XCTAssertNotNil(proto)
    }
    
    func testWatcher() throws {
        let proto = Watcher_TimestampResultCode.blockIndexOutOfBounds
        XCTAssertNotNil(proto)
    }
}
