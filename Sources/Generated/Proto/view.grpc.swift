//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: view.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import GRPC
import NIO
import SwiftProtobuf


//// A single Duplex streaming API that allows clients to authorize with Fog View and
//// query it for TxOuts.
///
/// Usage: instantiate `FogView_FogViewRouterAPIClient`, then call methods of this protocol to make API calls.
public protocol FogView_FogViewRouterAPIClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: FogView_FogViewRouterAPIClientInterceptorFactoryProtocol? { get }

  func request(
    callOptions: CallOptions?,
    handler: @escaping (FogView_FogViewRouterResponse) -> Void
  ) -> BidirectionalStreamingCall<FogView_FogViewRouterRequest, FogView_FogViewRouterResponse>
}

extension FogView_FogViewRouterAPIClientProtocol {
  public var serviceName: String {
    return "fog_view.FogViewRouterAPI"
  }

  /// Bidirectional streaming call to request
  ///
  /// Callers should use the `send` method on the returned object to send messages
  /// to the server. The caller should send an `.end` after the final message has been sent.
  ///
  /// - Parameters:
  ///   - callOptions: Call options.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ClientStreamingCall` with futures for the metadata and status.
  public func request(
    callOptions: CallOptions? = nil,
    handler: @escaping (FogView_FogViewRouterResponse) -> Void
  ) -> BidirectionalStreamingCall<FogView_FogViewRouterRequest, FogView_FogViewRouterResponse> {
    return self.makeBidirectionalStreamingCall(
      path: "/fog_view.FogViewRouterAPI/request",
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makerequestInterceptors() ?? [],
      handler: handler
    )
  }
}

public protocol FogView_FogViewRouterAPIClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'request'.
  func makerequestInterceptors() -> [ClientInterceptor<FogView_FogViewRouterRequest, FogView_FogViewRouterResponse>]
}

public final class FogView_FogViewRouterAPIClient: FogView_FogViewRouterAPIClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: FogView_FogViewRouterAPIClientInterceptorFactoryProtocol?

  /// Creates a client for the fog_view.FogViewRouterAPI service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: FogView_FogViewRouterAPIClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

/// Usage: instantiate `FogView_FogViewRouterAdminAPIClient`, then call methods of this protocol to make API calls.
public protocol FogView_FogViewRouterAdminAPIClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: FogView_FogViewRouterAdminAPIClientInterceptorFactoryProtocol? { get }

  func addShard(
    _ request: FogCommon_AddShardRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<FogCommon_AddShardRequest, SwiftProtobuf.Google_Protobuf_Empty>
}

extension FogView_FogViewRouterAdminAPIClientProtocol {
  public var serviceName: String {
    return "fog_view.FogViewRouterAdminAPI"
  }

  /// Adds a shard to the Fog View Router's list of shards to query.
  ///
  /// - Parameters:
  ///   - request: Request to send to addShard.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func addShard(
    _ request: FogCommon_AddShardRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<FogCommon_AddShardRequest, SwiftProtobuf.Google_Protobuf_Empty> {
    return self.makeUnaryCall(
      path: "/fog_view.FogViewRouterAdminAPI/addShard",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeaddShardInterceptors() ?? []
    )
  }
}

public protocol FogView_FogViewRouterAdminAPIClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'addShard'.
  func makeaddShardInterceptors() -> [ClientInterceptor<FogCommon_AddShardRequest, SwiftProtobuf.Google_Protobuf_Empty>]
}

public final class FogView_FogViewRouterAdminAPIClient: FogView_FogViewRouterAdminAPIClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: FogView_FogViewRouterAdminAPIClientInterceptorFactoryProtocol?

  /// Creates a client for the fog_view.FogViewRouterAdminAPI service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: FogView_FogViewRouterAdminAPIClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

//// Fulfills requests sent directly by a Fog client, e.g. a mobile phone using the SDK.
///
/// Usage: instantiate `FogView_FogViewAPIClient`, then call methods of this protocol to make API calls.
public protocol FogView_FogViewAPIClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: FogView_FogViewAPIClientInterceptorFactoryProtocol? { get }

  func auth(
    _ request: Attest_AuthMessage,
    callOptions: CallOptions?
  ) -> UnaryCall<Attest_AuthMessage, Attest_AuthMessage>

  func query(
    _ request: Attest_Message,
    callOptions: CallOptions?
  ) -> UnaryCall<Attest_Message, Attest_Message>
}

extension FogView_FogViewAPIClientProtocol {
  public var serviceName: String {
    return "fog_view.FogViewAPI"
  }

  //// This is called to perform IX key exchange with the enclave before calling GetOutputs.
  ///
  /// - Parameters:
  ///   - request: Request to send to Auth.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func auth(
    _ request: Attest_AuthMessage,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Attest_AuthMessage, Attest_AuthMessage> {
    return self.makeUnaryCall(
      path: "/fog_view.FogViewAPI/Auth",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeAuthInterceptors() ?? []
    )
  }

  //// Input should be an encrypted QueryRequest, result is an encrypted QueryResponse
  ///
  /// - Parameters:
  ///   - request: Request to send to Query.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func query(
    _ request: Attest_Message,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Attest_Message, Attest_Message> {
    return self.makeUnaryCall(
      path: "/fog_view.FogViewAPI/Query",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeQueryInterceptors() ?? []
    )
  }
}

public protocol FogView_FogViewAPIClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'auth'.
  func makeAuthInterceptors() -> [ClientInterceptor<Attest_AuthMessage, Attest_AuthMessage>]

  /// - Returns: Interceptors to use when invoking 'query'.
  func makeQueryInterceptors() -> [ClientInterceptor<Attest_Message, Attest_Message>]
}

public final class FogView_FogViewAPIClient: FogView_FogViewAPIClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: FogView_FogViewAPIClientInterceptorFactoryProtocol?

  /// Creates a client for the fog_view.FogViewAPI service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: FogView_FogViewAPIClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

//// Fulfills requests sent by the Fog View Router. This is not meant to fulfill requests sent directly by the client.
///
/// Usage: instantiate `FogView_FogViewStoreAPIClient`, then call methods of this protocol to make API calls.
public protocol FogView_FogViewStoreAPIClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: FogView_FogViewStoreAPIClientInterceptorFactoryProtocol? { get }

  func auth(
    _ request: Attest_AuthMessage,
    callOptions: CallOptions?
  ) -> UnaryCall<Attest_AuthMessage, Attest_AuthMessage>

  func multiViewStoreQuery(
    _ request: FogView_MultiViewStoreQueryRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<FogView_MultiViewStoreQueryRequest, FogView_MultiViewStoreQueryResponse>
}

extension FogView_FogViewStoreAPIClientProtocol {
  public var serviceName: String {
    return "fog_view.FogViewStoreAPI"
  }

  //// This is called to perform IX key exchange with the enclave before calling GetOutputs.
  ///
  /// - Parameters:
  ///   - request: Request to send to Auth.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func auth(
    _ request: Attest_AuthMessage,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Attest_AuthMessage, Attest_AuthMessage> {
    return self.makeUnaryCall(
      path: "/fog_view.FogViewStoreAPI/Auth",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeAuthInterceptors() ?? []
    )
  }

  //// Input should be an encrypted MultiViewStoreQueryRequest, result is an encrypted QueryResponse.
  ///
  /// - Parameters:
  ///   - request: Request to send to MultiViewStoreQuery.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func multiViewStoreQuery(
    _ request: FogView_MultiViewStoreQueryRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<FogView_MultiViewStoreQueryRequest, FogView_MultiViewStoreQueryResponse> {
    return self.makeUnaryCall(
      path: "/fog_view.FogViewStoreAPI/MultiViewStoreQuery",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeMultiViewStoreQueryInterceptors() ?? []
    )
  }
}

public protocol FogView_FogViewStoreAPIClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'auth'.
  func makeAuthInterceptors() -> [ClientInterceptor<Attest_AuthMessage, Attest_AuthMessage>]

  /// - Returns: Interceptors to use when invoking 'multiViewStoreQuery'.
  func makeMultiViewStoreQueryInterceptors() -> [ClientInterceptor<FogView_MultiViewStoreQueryRequest, FogView_MultiViewStoreQueryResponse>]
}

public final class FogView_FogViewStoreAPIClient: FogView_FogViewStoreAPIClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: FogView_FogViewStoreAPIClientInterceptorFactoryProtocol?

  /// Creates a client for the fog_view.FogViewStoreAPI service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: FogView_FogViewStoreAPIClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

