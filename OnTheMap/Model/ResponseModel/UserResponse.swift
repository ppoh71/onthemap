//
//  USerResponse.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 04.12.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import Foundation

class UserData: Codable{
    let key: String
    let firstName: String
    let lastName: String
    let image: String
    
    enum CodingKeys: String, CodingKey{
        case key
        case firstName = "first_name"
        case lastName = "last_name"
        case image = "_image_url"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try container.decodeIfPresent(String.self, forKey: .key) ?? "default"
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? "default"
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? "default"
        self.image = try container.decodeIfPresent(String.self, forKey: .image) ?? "default"
    }
}
