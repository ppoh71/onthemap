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
        case postLocation
        
        var url: URL{
            return URL(string: stringValue)!
        }
        
        var stringValue: String {
            switch self{
            case .getLocation(let limit):
                return "https://parse.udacity.com/parse/classes/StudentLocation?limit=\(limit)&order=-updatedAt&skip=0"
            case .postLocation:
                return "https://parse.udacity.com/parse/classes/StudentLocation"
            }
        }
    }
    
    class func getLocation(limit: Int, completion: @escaping (LocationResponse?, Error?) -> Void){
        var request = URLRequest(url: Endpoints.getLocation(value: limit).url)
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
                DispatchQueue.main.async {
                    completion(locationResult, nil)
                }
            }catch{
                do{
                    let errorResponse = try JSONDecoder().decode(ParseErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                }catch{
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func postLocation(postLocation: PostLocationRequest, completion: @escaping (PostLocationResponse?, Error?) -> Void){
        var request = URLRequest(url: Endpoints.postLocation.url)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(postLocation)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            do{
                let postLocationResponse = try JSONDecoder().decode(PostLocationResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(postLocationResponse, nil)
                }
                print(postLocationResponse)
            }catch{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            //print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
    }
}
