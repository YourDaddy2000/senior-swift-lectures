//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 03.09.2021.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.removeStub()
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
        let requestError = anyError()
        let responseError = resultErrorFor((data: nil, response: nil, error: requestError))
        XCTAssertEqual(requestError.domain, (responseError as NSError?)?.domain)
    }
    
    func test_getFromUrl_failsOnAllInvalidCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPUrlResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPUrlResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPUrlResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPUrlResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPUrlResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPUrlResponse(), error: nil)))
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPUrlResponse()
        let receivedResponse = resultValuesFrom((data: data, response: response, error: nil))
        
        XCTAssertEqual(receivedResponse?.data, data)
        XCTAssertEqual(receivedResponse?.response.url, response.url)
        XCTAssertEqual(receivedResponse?.response.statusCode, response.statusCode)
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithNilData() {
        let response = anyHTTPUrlResponse()
        let receivedResponse = resultValuesFrom((data: nil, response: response, error: nil))
        let emptyData = Data()
        XCTAssertEqual(receivedResponse?.data, emptyData)
        XCTAssertEqual(receivedResponse?.response.url, response.url)
        XCTAssertEqual(receivedResponse?.response.statusCode, response.statusCode)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let url = anyURL()
        let exp = expectation(description: "wait for request")
        
        let task = makeSUT().get(from: url) { result in
            switch result {
            case .failure(let error as NSError) where error.code == URLError.cancelled.rawValue:
                break
            case _:
                XCTFail("Expected cancelled result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        task.cancel()
        wait(for: [exp], timeout: 1)
    }
    
    //MARK: - Helpers
    private func resultValuesFrom(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taksHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFrom(values, taskHandler: taksHandler)
        
        switch result {
        case let .success((data, response)):
            return (data, response)
        default:
            XCTFail("Expected Success, got \(result) instead", file: file, line: line)
        }
        
        return nil
    }
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taksHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFrom(values, taskHandler: taksHandler)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected Failure, got \(result) instead", file: file, line: line)
        }
        
        return nil
    }
    
    private func resultFrom(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Response {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "wait for")
        var receivedResult: HTTPClient.Response!
        
        taskHandler(sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1)
        return receivedResult
    }
    
    private func nonHTTPUrlResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPUrlResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class URLProtocolStub: URLProtocol {
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
            let requestObserver: ((URLRequest) -> Void)?
        }
        
        private static var _stub: Stub?
        private static var stub: Stub? {
            get { queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }
        
        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            Self.stub = Stub(data: data, response: response, error: error, requestObserver: nil)
        }
        
        static func observe(_ observer: @escaping (URLRequest) -> Void) {
            stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
        }
        
        static func removeStub() {
            stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let stub = Self.stub else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
            
            stub.requestObserver?(request)
        }
        
        override func stopLoading() {}
    }
}
