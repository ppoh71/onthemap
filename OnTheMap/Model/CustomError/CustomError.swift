//
//  CustomError.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 29.11.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import Foundation

enum CustomError: Error{
    case decodeFailed
    case noResponseData
}

extension CustomError: LocalizedError{
    var errorDescription: String?{
        switch self{
        case .decodeFailed:
            return "Decoding of Response Data Failed"
        case .noResponseData:
            return "No Response Data from Request"
        }
    }
}
