//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Roman Bozhenko on 02.01.2022.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import XCTest

extension FeedViewControllerTests {
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedViewController.self)
        let table = "Feed"
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if key == value {
            XCTFail("Mising localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        
        return value
    }
}
