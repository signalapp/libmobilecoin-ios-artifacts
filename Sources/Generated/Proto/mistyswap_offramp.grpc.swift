//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: mistyswap_offramp.proto
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


/// Usage: instantiate `Mistyswap_MistyswapOfframpApiClient`, then call methods of this protocol to make API calls.
public protocol Mistyswap_MistyswapOfframpApiClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Mistyswap_MistyswapOfframpApiClientInterceptorFactoryProtocol? { get }

  func initiateOfframp(
    _ request: Attest_Message,
    callOptions: CallOptions?
  ) -> UnaryCall<Attest_Message, Attest_Message>

  func forgetOfframp(
    _ request: Attest_Message,
    callOptions: CallOptions?
  ) -> UnaryCall<Attest_Message, Attest_Message>

  func getOfframpStatus(
    _ request: Attest_Message,
    callOptions: CallOptions?
  ) -> UnaryCall<Attest_Message, Attest_Message>
}

extension Mistyswap_MistyswapOfframpApiClientProtocol {
  public var serviceName: String {
    return "mistyswap.MistyswapOfframpApi"
  }

  //// Initiate (or pick up a previously initiated) offramp.
  //// Input should be an encrypted InitiateOfframpRequest, output is an encrypted InitiateOfframpResponse.
  ///
  /// - Parameters:
  ///   - request: Request to send to InitiateOfframp.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func initiateOfframp(
    _ request: Attest_Message,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Attest_Message, Attest_Message> {
    return self.makeUnaryCall(
      path: "/mistyswap.MistyswapOfframpApi/InitiateOfframp",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeInitiateOfframpInterceptors() ?? []
    )
  }

  //// Forget an offramp.
  //// Input should be an encrypted ForgetOfframpRequest, output is an encrypted ForgetOfframpResponse.
  ///
  /// - Parameters:
  ///   - request: Request to send to ForgetOfframp.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func forgetOfframp(
    _ request: Attest_Message,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Attest_Message, Attest_Message> {
    return self.makeUnaryCall(
      path: "/mistyswap.MistyswapOfframpApi/ForgetOfframp",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeForgetOfframpInterceptors() ?? []
    )
  }

  //// Get the status of an offramp.
  //// Input should be an encrypted GetOfframpStatusRequest, output is an encrypted GetOfframpStatusResponse.
  ///
  /// - Parameters:
  ///   - request: Request to send to GetOfframpStatus.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getOfframpStatus(
    _ request: Attest_Message,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Attest_Message, Attest_Message> {
    return self.makeUnaryCall(
      path: "/mistyswap.MistyswapOfframpApi/GetOfframpStatus",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeGetOfframpStatusInterceptors() ?? []
    )
  }
}

public protocol Mistyswap_MistyswapOfframpApiClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'initiateOfframp'.
  func makeInitiateOfframpInterceptors() -> [ClientInterceptor<Attest_Message, Attest_Message>]

  /// - Returns: Interceptors to use when invoking 'forgetOfframp'.
  func makeForgetOfframpInterceptors() -> [ClientInterceptor<Attest_Message, Attest_Message>]

  /// - Returns: Interceptors to use when invoking 'getOfframpStatus'.
  func makeGetOfframpStatusInterceptors() -> [ClientInterceptor<Attest_Message, Attest_Message>]
}

public final class Mistyswap_MistyswapOfframpApiClient: Mistyswap_MistyswapOfframpApiClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Mistyswap_MistyswapOfframpApiClientInterceptorFactoryProtocol?

  /// Creates a client for the mistyswap.MistyswapOfframpApi service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Mistyswap_MistyswapOfframpApiClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

