//
//  ParseErrorResponse.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 02.12.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import Foundation

struct ParseErrorResponse: Codable{
    let code: Int
    let error: String
}

extension ParseErrorResponse: LocalizedError{
    var errorDescription: String? {
        return error
    }
}
