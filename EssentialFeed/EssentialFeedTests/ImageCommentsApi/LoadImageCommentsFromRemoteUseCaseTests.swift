//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 17.04.2022.
//

import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
    func test_load_deliversErrorOnNon2XXHTTPResponse() {
        let (sut, client) = getSUT()
        let samples = [199, 150, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                client.complete(withStatusCode: code, data: Data(), at: index)
            }
        }
    }

    func test_load_deliversErrorOn2XXHTTPResponseWithInvalidJSON() {
        let (sut, client) = getSUT()
        let samples = [200, 201, 250, 280, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let invalidJSON = Data("invalid json".utf8)
                client.complete(withStatusCode: code, data: invalidJSON, at: index)
            }
        }
    }
    
    func test_load_deliversNoItemsOn2XXHTTPResponseWithEmptyJSONList() {
        let (sut, client) = getSUT()
        let samples = [201, 201, 250, 280, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([])) {
                let emptyJSON = makeItemsJSON([])
                client.complete(withStatusCode: code, data: emptyJSON, at: index)
            }
        }
    }

    func test_load_deliversNoErrorOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = getSUT()

        expect(sut, toCompleteWith: .success([])) {
            let emptyJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyJSON)
        }
    }
    
    func test_load_deliversNoErrorOn200HTTPResponseWithJSONList() {
        let (sut, client) = getSUT()
        let item1 = makeItem(
            id: UUID(),
            message: "message1",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "user1")
        let item2 = makeItem(
            id: UUID(),
            message: "message2",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "user2")
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items)) {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    //MARK: Helpers
    private func getSUT(url: URL = URL(string: "https://google.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String : Any]) {
        let model = ImageComment(
            id: id,
            message: message,
            createdAt: createdAt.date,
            username: username
        )
        
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username
            ]
        ]
        
        return(model, json)
    }
    
    private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait to load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        return .failure(error)
    }
}
