//
//  RemoteLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 04.05.2022.
//

import XCTest
import EssentialFeed

class RemoteLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://someurl.com")!
        let (sut, client) = getSUT(url: url)

        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_load_requestsDataTwiceFromURL() {
        let url = URL(string: "https://someurl.com")!
        let (sut, client) = getSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = getSUT()
        let clientError = NSError(domain: "Test", code: 0)

        expect(sut, toCompleteWith: failure(.connectivityError)) {
            client.complete(withError: clientError)
        }
    }

    func test_load_deliversErrorOnMapperError() {
        let (sut, client) = getSUT(mapper: { _, _ in
            throw RemoteLoader<String>.Error.invalidData
        })

        expect(sut, toCompleteWith: failure(.invalidData)) {
            client.complete(withStatusCode: 200, data: anyData())
        }
    }

    func test_load_deliversMappedResource() {
        let resource = "a resource"
        let (sut, client) = getSUT(mapper: { data, _ in
            String(data: data, encoding: .utf8)!
        })

        expect(sut, toCompleteWith: .success(resource)) {
            client.complete(withStatusCode: 200, data: Data(resource.utf8))
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader(url: url, client: client, mapper: { _, _ in "any"})
        
        var capturedResults = [RemoteLoader<String>.Result]()
        sut?.load { capturedResults.append($0) }
        sut = nil
        
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    //MARK: Helpers
    private func getSUT(
        url: URL = URL(string: "https://google.com")!,
        mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader<String>(url: url, client: client, mapper: mapper)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private func makeItemsJSON(_ items: [[String:Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: String) -> (model: FeedImage, json: [String:Any]) {
        let model = FeedImage(
            id: id,
            description: description,
            location: location,
            url: URL(string: imageURL)!)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL
        ].compactMapValues{ $0 }
        
        return(model, json)
    }
    
    private func expect(_ sut: RemoteLoader<String>, toCompleteWith expectedResult: RemoteLoader<String>.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait to load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteLoader<String>.Error), .failure(expectedError as RemoteLoader<String>.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        return .failure(error)
    }
}
