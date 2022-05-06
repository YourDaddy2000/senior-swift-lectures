//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 17.04.2022.
//

import XCTest
import EssentialFeed

class ImageCommentsMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon2XXHTTPResponse() throws {
        let samples = [199, 150, 300, 400, 500]
        let json = makeItemsJSON([])
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(json, response: .init(statusCode: code))
            )
        }
    }

    func test_map_throwsErrorOn2XXHTTPResponseWithInvalidJSON() throws {
        let samples = [200, 201, 250, 280, 299]
        let invalidJSON = Data("invalid json".utf8)
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(invalidJSON, response: .init(statusCode: code))
            )
        }
    }
    
    func test_map_deliversNoItemsOn2XXHTTPResponseWithEmptyJSONList() throws {
        let samples = [201, 201, 250, 280, 299]
        let emptyJSON = makeItemsJSON([])
        
        try samples.enumerated().forEach { index, code in
            let result = try ImageCommentsMapper.map(emptyJSON, response: .init(statusCode: code))
            
            XCTAssertEqual([], result)
        }
    }
    
    func test_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
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
        let json = makeItemsJSON([item1.json, item2.json])
        
        let samples = [200, 201, 250, 280, 299]
        
        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(json, response: .init(statusCode: code))
            
            XCTAssertEqual(result, items)
        }
    }
    
    //MARK: Helpers
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
}
