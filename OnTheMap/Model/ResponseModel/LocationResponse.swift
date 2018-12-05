//
//  ResponseLocationResult.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 29.11.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import Foundation

class Location: Codable{
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    let createdAt: String
    let updatedAt: String
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.objectId = try container.decodeIfPresent(String.self, forKey: .objectId) ?? "Default Value"
        self.uniqueKey = try container.decodeIfPresent(String.self, forKey: .uniqueKey) ?? "Default Value"
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? "Default Value"
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? "Default Value"
        self.mapString = try container.decodeIfPresent(String.self, forKey: .mapString) ?? "Default Value"
        self.mediaURL = try container.decodeIfPresent(String.self, forKey: .mediaURL) ?? "Default Value"
        self.latitude = try container.decodeIfPresent(Double.self, forKey: .latitude) ?? 0.0
        self.longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) ?? 0.0
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? "Default Value"
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt) ?? "Default Value"
    }
}

struct LocationResponse: Codable{
    let results: [Location]
}


//{"objectId":"p7rl7PkRtT","createdAt":"2018-12-02T01:15:33.464Z","updatedAt":"2018-12-02T01:15:33.464Z"}
