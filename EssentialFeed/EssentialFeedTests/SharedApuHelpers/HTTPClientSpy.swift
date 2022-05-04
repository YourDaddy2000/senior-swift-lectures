//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 23.01.2022.
//

import EssentialFeed

final class HTTPClientSpy: HTTPClient {
    private struct Task: HTTPClientTask {
        let callback: () -> Void
        func cancel() { callback() }
    }
    private var messages = [(url: URL, completion: (Response) -> Void)]()
    var requestedURLs: [URL] { messages.map { $0.url }}
    var cancelledURLs = [URL]()
    
    func get(from url: URL, completion: @escaping (Response) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(withError error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        
        messages[index].completion(.success((data, response)))
    }
}
