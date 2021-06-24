//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

extension Bundle {
    private static let TEST_VECTOR_EXTENSION = "jsonl"

    public static func testVectorUrl(_ resource: String) throws -> URL {
        guard let url = Bundle(for: BundleType.self)
                .url(forResource: resource, withExtension: TEST_VECTOR_EXTENSION)
        else {
            throw TestVectorError(
                "Failed to get url for resource: \(resource).\(TEST_VECTOR_EXTENSION)")
        }
        return url
    }

    private final class BundleType {}
}
