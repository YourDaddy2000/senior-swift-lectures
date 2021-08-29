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
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void)
}
