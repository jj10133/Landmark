//
//  Scheme.swift
//  App
//
//  Created by joker on 2025-07-20.
//

import WebKit

struct HyperResourceSchemeHandler: URLSchemeHandler {
    
    var ipc: IPC?
    
    init(ipc: IPC?) {
        self.ipc = ipc
    }
    
    func reply(for request: URLRequest) -> some AsyncSequence<URLSchemeTaskResult, any Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard let ipc = self.ipc else {
                        print("Error: IPC object is nil, cannot read.")
                        return
                    }
                    
                    guard let url = request.url else {
                        continuation.finish(throwing: URLError(.badURL))
                        return
                    }
                    
                    let requestURLString = url.absoluteString
                    
                    try await ipc.write(data: requestURLString.data(using: .utf8)!)
                    
                    let mimeType = "text/html"
                    let statusCode = 200
                    
                    if let httpResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: ["Content-Type": mimeType]) {
                        continuation.yield(URLSchemeTaskResult.response(httpResponse))
                    } else {
                        continuation.finish(throwing: URLError(.unsupportedURL))
                        return
                    }
                    
                    for try await dataChunck in ipc {
                        if let dataString = String(data: dataChunck, encoding: .utf8),
                               let range = dataString.range(of: "END_OF_RESOURCE") {
                                
                                // 2. Yield the data *before* the marker
                                let actualData = dataString[..<range.lowerBound].data(using: .utf8)!
                                if !actualData.isEmpty {
                                    continuation.yield(.data(actualData))
                                }
                                
                                // 3. Finish the stream when the marker is found
                                continuation.finish()
                                print("HyperResourceSchemeHandler: Detected EOF, Finished streaming.")
                                return // Exit the Task
                            } else {
                                // 4. Yield the chunk if the marker isn't found
                                continuation.yield(.data(dataChunck))
                            }
                    }
                    
                    continuation.finish()
                } catch {
                    print("HyperResourceSchemeHandler: Error during scheme handler for \(request.url?.absoluteString ?? "unknown URL"): \(error.localizedDescription)")
                    continuation.finish(throwing: error)
                    ipc?.close()
                }
                
            }
        }
    }
}
