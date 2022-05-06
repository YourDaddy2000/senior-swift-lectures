//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 11.09.2021.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    private struct UnexpectedError: Error {}
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    @discardableResult
    public func get(from url: URL, completion: @escaping (HTTPClient.Response) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedError()
                }
            })
            
        }
        task.resume()
        
        return URLSessionTaskWrapper(wrapped: task)
    }
}
