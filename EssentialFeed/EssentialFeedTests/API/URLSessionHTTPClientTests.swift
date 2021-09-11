//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 03.09.2021.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedError: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedError()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "wait for request")
        
        URLProtocolStub.observe { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url, completion: { _ in })
        wait(for: [exp], timeout: 1)
    }

    func test_getFromUrl_failsOnRequestError() {
        let requestError = NSError(domain: "any error", code: 1)
        let responseError = resultErrorFrom(data: nil, response: nil, error: requestError)
        XCTAssertEqual(requestError.domain, (responseError as NSError?)?.domain)
    }
    
    func test_getFromUrl_failsOnAllInvalidCases() {
        let anyData = Data("any data".utf8)
        let anyError = NSError(domain: "any error", code: 0)
        let nonHTTPUrlResponse = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let anyHTTPUrlResponse = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        XCTAssertNotNil(resultErrorFrom(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFrom(data: nil, response: nonHTTPUrlResponse, error: nil))
        XCTAssertNotNil(resultErrorFrom(data: nil, response: anyHTTPUrlResponse, error: nil))
        XCTAssertNotNil(resultErrorFrom(data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFrom(data: anyData, response: nil, error: anyError))
        XCTAssertNotNil(resultErrorFrom(data: nil, response: nonHTTPUrlResponse, error: anyError))
        XCTAssertNotNil(resultErrorFrom(data: nil, response: anyHTTPUrlResponse, error: anyError))
        XCTAssertNotNil(resultErrorFrom(data: anyData, response: nonHTTPUrlResponse, error: anyError))
        XCTAssertNotNil(resultErrorFrom(data: anyData, response: anyHTTPUrlResponse, error: anyError))
        XCTAssertNotNil(resultErrorFrom(data: anyData, response: nonHTTPUrlResponse, error: nil))
    }
    
    //MARK: - Helpers
    private func resultErrorFrom(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "wait for")
        var receivedError: Error?
        
        sut.get(from: anyURL()) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected Failure, got \(result) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        return receivedError
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var observer: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            Self.stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func observe(_ observer: @escaping (URLRequest) -> Void) {
            self.observer = observer
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            observer = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            observer?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = Self.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = Self.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = Self.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
