//
//  IPC.swift
//  App
//
//  Created by joker on 2025-05-15.
//

import Foundation

public struct IPC: AsyncSequence {
  let ipc: BareIPC

  public init(worklet: Worklet) {
    self.ipc = BareIPC(worklet: worklet.worklet)!
  }

  public func read() async throws -> Data? {
    return try await ipc.read()
  }

  public func write(data: Data) async throws {
    return try await ipc.write(data)
  }

  public func close() {
    ipc.close()
  }

  public typealias Element = Data

  public struct AsyncIterator: AsyncIteratorProtocol {
    let ipc: IPC

    public func next() async throws -> Data? {
      return try await ipc.read()
    }
  }

  public func makeAsyncIterator() -> AsyncIterator {
    return AsyncIterator(ipc: self)
  }
}
