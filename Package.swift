// swift-tools-version:5.7
import PackageDescription
import Foundation
let package = Package(
    name: "libmobilecoin",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "LibMobileCoinCore",
            targets: ["LibMobileCoinTestVector", "LibMobileCoinHTTP", "LibMobileCoinGRPC", "LibMobileCoinCommon", "LibMobileCoinLibrary"]),
        .library(
            name: "LibMobileCoinCoreCommon",
            targets: ["LibMobileCoinTestVector", "LibMobileCoinCommon", "LibMobileCoinLibrary"]),
        .library(
            name: "LibMobileCoinCoreGRPC",
            targets: ["LibMobileCoinTestVector", "LibMobileCoinGRPC", "LibMobileCoinCommon", "LibMobileCoinLibrary"]),
        .library(
            name: "LibMobileCoinCoreHTTP",
            targets: ["LibMobileCoinTestVector", "LibMobileCoinHTTP", "LibMobileCoinCommon", "LibMobileCoinLibrary"])
    ],
    dependencies: [
        // Here we define our package's external dependencies
        // and from where they can be fetched:
        .package(
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.5.0"
        ),
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.15.0")
    ],
    targets: [
        .target(
            name: "LibMobileCoinTestVector",
            dependencies: [],
            path: "Sources/TestVector",
            resources: [
                .copy("vectors")
            ]
         ),
        .target(
            name: "LibMobileCoinCommon",
            dependencies: [.product(name: "SwiftProtobuf", package: "swift-protobuf")],
            path: "Sources/Common"
         ),
        .target(
            name: "LibMobileCoinHTTP",
            dependencies: [.target(name: "LibMobileCoinCommon")],
            path: "Sources/HTTP"
        ),
        .target(
            name: "LibMobileCoinGRPC",
            dependencies: [.target(name: "LibMobileCoinCommon"), .product(name: "GRPC", package: "grpc-swift")],
            path: "Sources/GRPC"
        ),
        .binaryTarget(
            name: "LibMobileCoinLibrary",
            path: "Artifacts/LibMobileCoinLibrary.xcframework"
        )
    ]
)

