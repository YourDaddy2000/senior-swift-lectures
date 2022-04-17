//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 15.12.2021.
//
import EssentialFeediOS
import EssentialFeed
import Combine
import UIKit

public enum FeedUIComposer {
    public static func composeFeedViewController(feedLoader: @escaping () -> FeedLoader.Publisher, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter {
            feedLoader().dispatchOnMainQueue()
        }
        
        let feedController = makeWith(delegate: presentationAdapter, title: FeedPresenter.title)
        
        let presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedController, loader: MainQueueDispatchDecorator(decoratee: imageLoader)),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController))
        presentationAdapter.presenter = presenter
        
        return feedController
    }
    
    private static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
