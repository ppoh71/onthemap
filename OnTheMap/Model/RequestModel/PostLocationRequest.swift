//
//  PostLocationRequest.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 04.12.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import Foundation

struct PostLocationRequest: Codable{
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
}
