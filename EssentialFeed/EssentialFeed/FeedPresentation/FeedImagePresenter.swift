//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 15.01.2022.
//

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location
        )
    }
}
