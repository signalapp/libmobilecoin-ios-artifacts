//
//  HTTPClientImports.swift
//  
//
//  Created by Adam Mork on 4/26/23.
//

import XCTest
import LibMobileCoinHTTP
import LibMobileCoinCommon

///
/// Importing one class from each file to ensure proper SPM packaging.
///
final class HTTPClientImports: XCTestCase {
    func testAttestRestClient() throws {
        let client = Attest_AttestedApiRestClient()
        XCTAssertNotNil(client)
    }
    
    func testConsensusRestClient() throws {
        let client = ConsensusClient_ConsensusClientAPIRestClient()
        XCTAssertNotNil(client)
    }
    
    func testConsensusCommon() throws {
        let client = ConsensusCommon_BlockchainAPIRestClient()
        XCTAssertNotNil(client)
    }
    
    func testLedgerRestClient() throws {
        let client = FogLedger_FogMerkleProofAPIRestClient()
        XCTAssertNotNil(client)
    }
    
    func testReportRestClient() throws {
        let client = Report_ReportAPIRestClient()
        XCTAssertNotNil(client)
    }
    
    func testFogViewRestClient() throws {
        let client = FogView_FogViewAPIRestClient()
        XCTAssertNotNil(client)
    }
}
