//
//  HTTPClientProtocol.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 29.08.2021.
//

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Response = Swift.Result<(Data, HTTPURLResponse), Error>
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func get(from url: URL, completion: @escaping (Response) -> Void) -> HTTPClientTask
}
