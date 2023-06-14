//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

extension Bundle {
    private static let TEST_VECTOR_EXTENSION = "jsonl"

    public static let libmobilecoin_TestVectorBundleIdentifier = Bundle.module.bundleIdentifier!
    
    public static func testVectorModuleUrl(_ resource: String) throws -> URL {
        guard
            let url = Bundle.module.url(forResource: resource, withExtension: TEST_VECTOR_EXTENSION, subdirectory: "vectors")
        else {
            throw TestVectorError(
                "Failed to get url for resource: \(resource).\(TEST_VECTOR_EXTENSION)")
        }
        return url
    }
}
