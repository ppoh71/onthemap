//
//  UdacityLogin.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 28.11.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import Foundation

struct Credetials: Codable{
    let username: String
    let password: String
}

struct LoginRequest: Codable{
    let udacity: Credetials
}


