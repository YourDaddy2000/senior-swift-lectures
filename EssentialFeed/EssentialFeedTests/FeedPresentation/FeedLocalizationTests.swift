//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Roman Bozhenko on 02.01.2022.
//

import XCTest
@testable import EssentialFeed

class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
