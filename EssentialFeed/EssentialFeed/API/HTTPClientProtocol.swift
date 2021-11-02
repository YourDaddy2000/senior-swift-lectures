//
//  HTTPClientProtocol.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 29.08.2021.
//

public enum HTTPClientResponse {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void)
}
