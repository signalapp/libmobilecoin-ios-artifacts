//
//  GRPCClientImports.swift
//  
//
//  Created by Adam Mork on 4/26/23.
//

import XCTest
import LibMobileCoinGRPC
import LibMobileCoinCommon
import GRPC

///
/// Importing one class from each file to ensure proper SPM packaging.
/// Testing one file would likely give the same signal but doing one 
/// from each for completeness
///
final class GRPCClientImports: XCTestCase {
    func testAttestClient() throws {
        let client = Attest_AttestedApiClient(channel: .testChannel)
        XCTAssertNotNil(client)
    }
    
    func testConsensusClient() throws {
        let client = ConsensusClient_ConsensusClientAPIClient(channel: .testChannel)
        XCTAssertNotNil(client)
    }
    
    func testConsensusCommon() throws {
        let client = ConsensusCommon_BlockchainAPIClient(channel: .testChannel)
        XCTAssertNotNil(client)
    }
    
    func testLedgerClient() throws {
        let client = FogLedger_FogMerkleProofAPIClient(channel: .testChannel)
        XCTAssertNotNil(client)
    }
    
    func testReportClient() throws {
        let client = Report_ReportAPIClient(channel: .testChannel)
        XCTAssertNotNil(client)
    }
    
    func testFogViewClient() throws {
        let client = FogView_FogViewAPIClient(channel: .testChannel)
        XCTAssertNotNil(client)
    }
}

struct GrpcChannelConfig {
    let host: String
    let port: Int
    
    static var testConfig: GrpcChannelConfig {
        GrpcChannelConfig(host: "localhost", port: 4000)
    }
}

extension GRPCChannel where Self == ClientConnection {
    static var testChannel: ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        let builder = ClientConnection.insecure(group: group)
        let config = GrpcChannelConfig.testConfig
        return builder.connect(host: config.host, port: config.port)
    }
}
