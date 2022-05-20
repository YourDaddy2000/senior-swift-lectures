//
//  FeedUIIntegrationTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Roman Bozhenko on 02.01.2022.
//

import Foundation
import EssentialFeed
import XCTest

extension FeedUIIntegrationTests {
    private class DummyView: ResourceViewProtocol {
        func display(_ viewModel: Any) { }
    }
    
    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }
}
