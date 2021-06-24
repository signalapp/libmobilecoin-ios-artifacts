//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

struct TestVectorError: Error {
    let reason: String

    init(_ reason: String) {
        self.reason = reason
    }
}

extension TestVectorError: CustomStringConvertible {
    var description: String {
        "Test vector error: \(reason)"
    }
}
