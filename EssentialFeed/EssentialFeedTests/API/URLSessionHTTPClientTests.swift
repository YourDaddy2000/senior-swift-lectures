//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 03.09.2021.
//

import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    private let session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://any-url.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumesCallCount, 1)
    }
    
    func test_getFromUrl_failsOnRequestError() {
        let url = URL(string: "https://any-url.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        let error = NSError(domain: "err", code: 0)
        session.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
        let exp = expectation(description: "wait for")
        
        sut.get(from: url) { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected Failure with Error: \(error), for \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    //MARK: - Helpers
    
    private class HTTPSessionSpy: HTTPSession {
        private var stubs = [URL : Stub]()
        
        private struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }
        
        func stub(url: URL, task: HTTPSessionTask = FakeHTTPSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else { fatalError("could not find stub") }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private class FakeHTTPSessionDataTask: HTTPSessionTask {
        func resume() { }
    }
    private class URLSessionDataTaskSpy: HTTPSessionTask {
        var resumesCallCount = 0
        
        func resume() {
            resumesCallCount += 1
        }
    }
}
