//
//  FeedImageDataMapper.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 06.05.2022.
//

import Foundation

public enum FeedImageDataMapper {
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, response: HTTPURLResponse) throws -> Data {
        guard response.isOK, !data.isEmpty else {
            throw Error.invalidData
        }
        
        return data
    }
}
