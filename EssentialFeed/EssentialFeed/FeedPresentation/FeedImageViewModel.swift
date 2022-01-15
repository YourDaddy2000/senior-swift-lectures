//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 15.01.2022.
//

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
