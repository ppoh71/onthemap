//
//  NetworkClient.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 28.11.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import Foundation

class LoginClient{
    
    struct Auth{
        static var registered: Bool = false
        static var key: String = ""
        static var sessionId: String = ""
    }
    
    enum Endpoints{
        case udacityLogin
        
        var url: URL{
            return URL(string: self.stringValue)!
        }
        
        var stringValue: String{
            switch(self){
            case .udacityLogin:
                return "https://onthemap-api.udacity.com/v1/session"
            }
        }
    }
    
    class func udacityLogin(username: String, password: String, completion: @escaping (LoginResponse?, Error?) -> Void){
        var request = URLRequest(url: LoginClient.Endpoints.udacityLogin.url)
        print(LoginClient.Endpoints.udacityLogin.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let httpBody = LoginRequest(udacity: Credetials(username: username, password: password))
        request.httpBody = try! JSONEncoder().encode(httpBody)
//        request.httpBody = """
//                            {
//                             "udacity":
//                                {
//                                "username": "\(username)",
//                                "password": "\(password)"
//                                }
//                            }
//                            """.data(using: .utf8)!

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                return
            }
            
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            print(response)
            
//            let debugData = """
//                    {
//                    "account":{
//                    "registered":true,
//                    "key":"3903878747"
//                    },
//                    "session":{
//                    "id":"1457628510Sc18f2ad4cd3fb317fb8e028488694088",
//                    "expiration":"2015-05-10T16:48:30.760460Z"
//                    }
//                    }
//                    """.data(using: .utf8)!
            
            do{
                let response = try JSONDecoder().decode(LoginResponse.self, from: newData!)
                Auth.sessionId = response.session.id
                Auth.key = response.account.key
                Auth.registered = true
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            }catch{
                print("decode error")
                do{
                    let errorResponse = try JSONDecoder().decode(LoginErrorResponse.self, from: newData!)
                    print(errorResponse)
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
 
    class func udacityLogout(completion: (Bool, Error?) -> Void){
        var request = URLRequest(url: LoginClient.Endpoints.udacityLogin.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                // Handle error…
                print("logout error")
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            
        }
        task.resume()
    }
    
}
