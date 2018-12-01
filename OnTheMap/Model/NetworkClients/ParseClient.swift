//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 29.11.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import Foundation

class ParseClient{
    
    static let AppKey = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let RestApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    enum Endpoints{
        case getLocation(value: Int)
        
        var url: URL{
            return URL(string: stringValue)!
        }
        
        var stringValue: String {
            switch self{
            case .getLocation(let limit):
                return "https://parse.udacity.com/parse/classes/StudentLocation?limit=\(limit)&order=updatedAt"
            }
        }
    }
    
    class func getLocation(amount: Int, completion: @escaping (LocationResponse?, Error?)->Void){
        var request = URLRequest(url: Endpoints.getLocation(value: amount).url)
        request.addValue(AppKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(RestApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            do{
                let locationResult = try JSONDecoder().decode(LocationResponse.self, from: data)
                print(locationResult)
                DispatchQueue.main.async {
                    completion(locationResult, nil)
                }
            }catch{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
    }
    
}
