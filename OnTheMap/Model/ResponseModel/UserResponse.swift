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

/*
 Reponse data
 {"
 _image_url":"https:\/\/robohash.org\/udacity-59983210385",
 "_cohort_keys":[],
 "last_name":"Boehm",
 "key":"59983210385",
 "employer_sharing":false,
 "external_accounts":[],
 "_registered":true,
 "_enrollments":[],
 "_memberships":[],
 "_principals":[],
 "_badges":[],
 "guard":{},
 "tags":[],
 "first_name":"Lonzo",
 "_has_password":true,
 "email_preferences":{},
 "email":{"address":"lonzo.boehm@onthemap.udacity.com",
        "_verified":true,
        "_verification_code_sent":true},
 "social_accounts":[],
 "_affiliate_profiles":[],
 "nickname":"Lonzo Boehm"}
 
 */
