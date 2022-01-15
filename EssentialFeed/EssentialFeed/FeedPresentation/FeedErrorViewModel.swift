//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 15.01.2022.
//

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
