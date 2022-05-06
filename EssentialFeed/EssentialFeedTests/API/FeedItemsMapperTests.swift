//
//  FeedItemsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 13.08.2021.
//

import XCTest
import EssentialFeed

class FeedItemsMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let json = makeItemsJSON([])
        let samples = [199, 201, 300, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedItemMapper.map(json, response: .init(statusCode: code))
            )
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid json".utf8)

        XCTAssertThrowsError(
            try FeedItemMapper.map(invalidJSON, response: .init(statusCode: 200))
        )
    }

    func test_load_deliversNoErrorOn200HTTPResponseWithEmptyJSONList() throws {
        let emptyJSON = makeItemsJSON([])
        let result = try FeedItemMapper.map(emptyJSON, response: .init(statusCode: 200))
        
        XCTAssertEqual([], result)
    }
    
    func test_load_deliversNoErrorOn200HTTPResponseWithJSONList() throws {
        let item1 = makeItem(
            id: UUID(),
            imageURL: "https://a-url.com")
        let item2 = makeItem(
            id: UUID(),
            description: "description",
            location: "location",
            imageURL: "https://another-url.com")
        let items = [item1.model, item2.model]
        
        let json = makeItemsJSON([item1.json, item2.json])
        let result = try FeedItemMapper.map(json, response: .init(statusCode: 200))
        
        XCTAssertEqual(items, result)
    }
    
    //MARK: Helpers
    
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
}
