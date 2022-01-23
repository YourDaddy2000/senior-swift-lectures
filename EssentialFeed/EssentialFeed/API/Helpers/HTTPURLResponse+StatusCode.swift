//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 23.01.2022.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { 200 }
    
    var isOK: Bool {
        statusCode == Self.OK_200
    }
}statusCode == 200
