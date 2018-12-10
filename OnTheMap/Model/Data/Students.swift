//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 08.12.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import Foundation

struct StudentInformation: Codable{
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
    
    init(from decoder: Decoder) throws {
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

class Students: Codable{
   static var studentsInformation = [StudentInformation]()
}
