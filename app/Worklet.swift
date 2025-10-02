//
//  Worklet.swift
//  App
//
//  Created by joker on 2025-05-15.
//

import Foundation

public struct Worklet {
  public struct Configuration {
    var memoryLimit: UInt
    var assets: String?

    public init(memoryLimit: UInt = 0, assets: String? = nil) {
      self.memoryLimit = memoryLimit
      self.assets = assets
    }
  }

  let worklet: BareWorklet

  public init(configuration: Configuration = Configuration()) {
    let copy = BareWorkletConfiguration()

    copy.memoryLimit = configuration.memoryLimit
    copy.assets = configuration.assets

    self.worklet = BareWorklet(configuration: copy)!
  }

  public func start(
    filename: String, source: Data, arguments: [String] = []
  ) {
    worklet.start(
      filename, source: source, arguments: arguments
    )
  }

  public func start(
    filename: String, source: String, encoding: String.Encoding, arguments: [String] = []
  ) {
    worklet.start(
      filename, source: source, encoding: encoding.rawValue, arguments: arguments
    )
  }

  public func start(
    name: String, ofType type: String, arguments: [String] = []
  ) {
    worklet.start(
      name, ofType: type, arguments: arguments
    )
  }

  public func start(
    name: String, ofType type: String, inBundle bundle: Bundle, arguments: [String] = []
  ) {
    worklet.start(
      name, ofType: type, in: bundle, arguments: arguments
    )
  }

  public func start(
    name: String, ofType type: String, inDirectory subpath: String, arguments: [String] = []
  ) {
    worklet.start(
      name, ofType: type, inDirectory: subpath, arguments: arguments
    )
  }

  public func start(
    name: String, ofType type: String, inDirectory subpath: String, inBundle bundle: Bundle,
    arguments: [String] = []
  ) {
    worklet.start(
      name, ofType: type, inDirectory: subpath, in: bundle, arguments: arguments
    )
  }

  public func suspend(linger: Int32 = 0) {
    worklet.suspend(withLinger: linger)
  }

  public func resume() {
    worklet.resume()
  }

  public func terminate() {
    worklet.terminate()
  }

  public func push(
    data: Data, queue: OperationQueue
  ) async throws -> Data? {
    return try await worklet.push(data, queue: queue)
  }

  public func push(
    data: Data
  ) async throws -> Data? {
    return try await worklet.push(data)
  }

  public func push(
    data: String, encoding: String.Encoding, queue: OperationQueue
  ) async throws -> String? {
    return try await worklet.push(data, encoding: encoding.rawValue, queue: queue)
  }

  public func push(
    data: String, encoding: String.Encoding
  ) async throws -> String? {
    return try await worklet.push(data, encoding: encoding.rawValue)
  }
}
