// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: attest.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

// Copyright (c) 2018-2021 The MobileCoin Foundation

//// This file defines the API to allow for a client to conduct an authenticated
//// key exchange using a derivative of the noise protocol

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

//// The first message of an exchange, sent by a client.
////
//// This contains the client's one-time ephemeral public key, and the
//// cryptographic parameters which will be used in future messages.
public struct Attest_AuthMessage {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  //// A potentially encrypted bytestream containing opaque data intended
  //// for use in the enclave.
  public var data: Data = Data()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

//// AEAD messages sent to and from authenticated clients.
public struct Attest_Message {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  //// A byte array containing plaintext authenticated data.
  public var aad: Data = Data()

  //// An byte array containing the channel ID this message is
  //// associated with. A zero-length channel ID is not valid.
  public var channelID: Data = Data()

  //// A potentially encrypted bytestream containing opaque data intended
  //// for use in the enclave.
  public var data: Data = Data()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "attest"

extension Attest_AuthMessage: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".AuthMessage"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "data"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.data) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.data.isEmpty {
      try visitor.visitSingularBytesField(value: self.data, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Attest_AuthMessage, rhs: Attest_AuthMessage) -> Bool {
    if lhs.data != rhs.data {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Attest_Message: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Message"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "aad"),
    2: .standard(proto: "channel_id"),
    3: .same(proto: "data"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.aad) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.channelID) }()
      case 3: try { try decoder.decodeSingularBytesField(value: &self.data) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.aad.isEmpty {
      try visitor.visitSingularBytesField(value: self.aad, fieldNumber: 1)
    }
    if !self.channelID.isEmpty {
      try visitor.visitSingularBytesField(value: self.channelID, fieldNumber: 2)
    }
    if !self.data.isEmpty {
      try visitor.visitSingularBytesField(value: self.data, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Attest_Message, rhs: Attest_Message) -> Bool {
    if lhs.aad != rhs.aad {return false}
    if lhs.channelID != rhs.channelID {return false}
    if lhs.data != rhs.data {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
