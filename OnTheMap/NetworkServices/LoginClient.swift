//
//  NetworkClient.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 28.11.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import Foundation

class LoginClient{
    
    static let signupURL = URL(string: "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated")!
    
    struct Auth{
        static var registered: Bool = false
        static var key: String = ""
        static var sessionId: String = ""
        static var firstName: String = ""
        static var lastName: String = ""
        static var image: String = ""
    }
    
    enum Endpoints{
        case udacityLogin
        case udacityLogout
        case getUserData(value: String)
        
        var url: URL{
            return URL(string: self.stringValue)!
        }
        
        var stringValue: String{
            switch(self){
            case .udacityLogin:
                return "https://onthemap-api.udacity.com/v1/session"
            case .udacityLogout:
                return "https://onthemap-api.udacity.com/v1/session"
            case .getUserData(let userData):
                return "https://onthemap-api.udacity.com/v1/users/\(userData)"
            }
        }
    }
    
    class func login(username: String, password: String, completion: @escaping (LoginResponse?, Error?) -> Void){
        var request = URLRequest(url: LoginClient.Endpoints.udacityLogin.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let httpBody = LoginRequest(udacity: Credetials(username: username, password: password))
        request.httpBody = try! JSONEncoder().encode(httpBody)

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            
            do{
                let response = try JSONDecoder().decode(LoginResponse.self, from: newData!)
                Auth.sessionId = response.session.id
                Auth.key = response.account.key
                Auth.registered = true
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            }catch{

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
    
    class func getUserData(key: String, completion: @escaping (Bool, Error?) -> Void){
        let request = URLRequest(url: Endpoints.getUserData(value: key).url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            
            do{
                let userData = try JSONDecoder().decode(UserData.self, from: newData!)
                Auth.firstName = userData.firstName
                Auth.lastName = userData.lastName
                Auth.image = userData.image
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            }catch{
                DispatchQueue.main.async {
                   completion(false, error)
                }
            }
        }
        task.resume()
    }
 
    class func logout(completion: @escaping (Bool, Error?) -> Void){
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
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            
            do{
                _ = try JSONDecoder().decode(LogoutResponse.self, from: newData!)
                Auth.sessionId = ""
                Auth.key = ""
                Auth.registered = false
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            }catch{
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
}
