//
//  CommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 15.12.2021.
//
import EssentialFeediOS
import EssentialFeed
import Combine
import UIKit

public enum CommentsUIComposer {
    public static func composeListViewController(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> ListViewController {
        typealias PresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
        let presentationAdapter =  PresentationAdapter(loader: {
            feedLoader().dispatchOnMainQueue()
        })
        
        let feedController = makeFeedViewControllerWith(title: FeedPresenter.title)
        
        feedController.onRefresh = presentationAdapter.loadResource
        
        let presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                loader: { imageLoader($0).dispatchOnMainQueue() }),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map)
        
        presentationAdapter.presenter = presenter
        
        return feedController
    }
    
    private static func makeFeedViewControllerWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}
