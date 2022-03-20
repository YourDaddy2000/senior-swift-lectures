//
//  HTTPClientStub.swift
//  EssentialFeediOSTests
//
//  Created by Roman Bozhenko on 20.03.2022.
//

import EssentialFeed

final class HTTPClientStub: HTTPClient {
    private class Task: HTTPClientTask {
        func cancel() { }
    }
    
    private let stub: (URL) -> HTTPClient.Response
    
    internal init(stub: @escaping (URL) -> HTTPClient.Response) {
        self.stub = stub
    }
    
    func get(from url: URL, completion: @escaping (Response) -> Void) -> HTTPClientTask {
        completion(stub(url))
        return Task()
    }
}
 
extension HTTPClientStub {
    static var offline: HTTPClientStub {
        HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
    }
    
    static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
        HTTPClientStub { url in .success(stub(url)) }
    }
}
