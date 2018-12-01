//
//  File.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 28.11.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import Foundation

struct LoginErrorResponse: Codable{
    let status: Int
    let error: String
}

extension LoginErrorResponse: LocalizedError{
    var errorDescription: String? {
        return error
    }
}
