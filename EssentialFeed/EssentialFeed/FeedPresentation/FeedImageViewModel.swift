//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 15.01.2022.
//

public struct FeedImageViewModel{
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        return location != nil
    }
}
