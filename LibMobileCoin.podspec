Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "LibMobileCoin"
  s.version      = "1.2.0-pre7"
  s.summary      = "A library for communicating with MobileCoin network"

  s.author       = "MobileCoin"
  s.homepage     = "https://www.mobilecoin.com/"

  s.license      = { :type => "GPLv3" }

  s.source       = { 
    :git => "https://github.com/mobilecoinofficial/libmobilecoin-ios-artifacts.git",
    :tag => "v#{s.version}",
    :submodules => true
  }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.platform     = :ios, "10.0"

  # ――― Subspecs ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.default_subspecs = :none
  # s.default_subspecs = "Core"

   s.subspec "TestVectors" do |subspec|
     subspec.source_files = "Sources/TestVector/**/*.swift"
     subspec.preserve_paths = [
       'Artifacts/**/libmobilecoin.a',
     ]
     subspec.resources = [
       "Vendor/mobilecoin/test-vectors/vectors/**/*.*",
     ]
   end

   s.subspec "Core" do |subspec|
     subspec.preserve_paths = [
       'Artifacts/**/libmobilecoin.a',
     ]
 
     subspec.source_files = [
       "Artifacts/include/*.h",
       "Sources/Generated/Proto/*.{grpc,pb}.swift",
     ]
 
     subspec.dependency "gRPC-Swift"
     subspec.dependency "SwiftProtobuf", "~> 1.5"
   end

   s.subspec "CoreHTTP" do |subspec|
     subspec.preserve_paths = [
       'Artifacts/**/libmobilecoin.a',
     ]
 
     subspec.source_files = [
       "Artifacts/include/*.h",
       "Sources/Generated/Proto/*.pb.swift",
     ]
 
     subspec.dependency "SwiftProtobuf", "~> 1.5"
   end

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.swift_version = "5.2"

  s.pod_target_xcconfig = {
    "GCC_OPTIMIZATION_LEVEL" => "z",
    "LLVM_LTO" => "YES",
    # Rust bitcode is not verified to be compatible with Apple Xcode's LLVM bitcode,
    # so this is disabled to be on the safe side.
    "ENABLE_BITCODE" => "YES",
    # Mac Catalyst is not supported since tjis library includes a vendored binary
    # that only includes support for iOS archictures.
    "SUPPORTS_MACCATALYST" => "YES",
    # The vendored binary doesn't include support for 32-bit architectures or arm64
    # for iphonesimulator. This must be manually configured to avoid Xcode's default
    # setting of building 32-bit and Xcode 12's default setting of including the
    # arm64 simulator. Note: 32-bit is officially dropped in iOS 11

    "HEADER_SEARCH_PATHS": "$(PODS_TARGET_SRCROOT)/Artifacts/include",
    "SWIFT_INCLUDE_PATHS": "$(HEADER_SEARCH_PATHS)",

    "LIBMOBILECOIN_LIB_IF_NEEDED": "$(PODS_TARGET_SRCROOT)/Artifacts/target/$(CARGO_BUILD_TARGET)/release/libmobilecoin.a",
    "OTHER_LDFLAGS": "-u _mc_string_free $(LIBMOBILECOIN_LIB_IF_NEEDED)",

    "CARGO_BUILD_TARGET[sdk=iphonesimulator*][arch=arm64]": "aarch64-apple-ios-sim",
    "CARGO_BUILD_TARGET[sdk=iphonesimulator*][arch=*]": "x86_64-apple-ios",
    "CARGO_BUILD_TARGET[sdk=iphoneos*]": "aarch64-apple-ios",

    "CARGO_BUILD_TARGET_MAC_CATALYST_ARM_": "aarch64-apple-darwin",
    "CARGO_BUILD_TARGET_MAC_CATALYST_ARM_YES": "aarch64-apple-ios-macabi",
    "CARGO_BUILD_TARGET[sdk=macosx*][arch=arm64]": "$(CARGO_BUILD_TARGET_MAC_CATALYST_ARM_$(IS_MACCATALYST))",
    "CARGO_BUILD_TARGET_MAC_CATALYST_X86_": "x86_64-apple-darwin",
    "CARGO_BUILD_TARGET_MAC_CATALYST_X86_YES": "x86_64-apple-ios-macabi",
    "CARGO_BUILD_TARGET[sdk=macosx*][arch=*]": "$(CARGO_BUILD_TARGET_MAC_CATALYST_X86_$(IS_MACCATALYST))",

    "VALID_ARCHS[sdk=iphoneos*]" => "arm64",
    "VALID_ARCHS[sdk=iphonesimulator*]" => "x86_64 arm64",
    "ARCHS[sdk=iphonesimulator*]": "x86_64 arm64",
    "ARCHS[sdk=iphoneos*]": "arm64",
    "EXCLUDED_ARCHS[sdk=iphoneos*]" => "armv7",
    "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "i386",
  }

  # `user_target_xcconfig` should only be set when the setting needs to propogate to
  # all targets that depend on this library.
  s.user_target_xcconfig = {
    "SUPPORTS_MACCATALYST" => "YES",
    "EXCLUDED_ARCHS[sdk=iphoneos*]" => "armv7",
    "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "i386",
    "VALID_ARCHS[sdk=iphoneos*]" => "arm64",
    "VALID_ARCHS[sdk=iphonesimulator*]" => "x86_64 arm64",
  }

end
