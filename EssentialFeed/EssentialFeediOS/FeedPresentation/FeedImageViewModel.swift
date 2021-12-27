//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 17.12.2021.
//

import Foundation
import EssentialFeed

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
