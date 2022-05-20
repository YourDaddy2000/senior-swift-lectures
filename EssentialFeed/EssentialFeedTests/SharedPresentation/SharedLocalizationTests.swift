//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 20.05.2022.
//

import XCTest
import EssentialFeed

class SharedLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
    
    //MARK: Helpers
    private class DummyView: ResourceViewProtocol {
        typealias ResourceViewModel = Any
        
        func display(_ viewModel: ResourceViewModel) { }
    }
}
