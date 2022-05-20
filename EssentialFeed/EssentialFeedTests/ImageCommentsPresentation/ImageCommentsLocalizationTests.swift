//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 20.05.2022.
//

import XCTest
import EssentialFeed

class ImageCommentsLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }

}
