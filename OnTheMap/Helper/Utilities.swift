//
//  Utilities.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 02.12.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Utilities{
    static let cornerRadius = CGFloat(2.0)
    
    class func centerMapOnLocation(distance: Double, latitude: Double, longitude: Double) -> MKCoordinateRegion {
        let regionRadius: CLLocationDistance = distance
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        return coordinateRegion
    }
    
    class func verifyUrl(urlString: String?) -> Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        guard let urlString = urlString else{
            print("verfy website, no url")
            return false
        }

        if let match = detector.firstMatch(in: urlString, options: [], range: NSRange(location: 0, length: urlString.endIndex.encodedOffset)) {
            // it is a link, if the match covers the whole string
            return match.range.length == urlString.endIndex.encodedOffset
        } else {
            return false
        }
    }
    
    class func addHttp(urlString: String) -> URL?{
        guard URL(string: urlString) != nil else{
            print("guard url addHttp")
            return nil
        }
        
        if urlString.hasPrefix("https://") || urlString.hasPrefix("http://"){
            let url = URL(string: urlString)
            return url
        }else {
            let correctedURL = "http://\(urlString)"
            let url = URL(string: correctedURL)
            return url
        }
    }
    
    class func openUrl(urlString: String, completion: @escaping (Bool) -> Void){
        
        if !Utilities.verifyUrl(urlString: urlString){
            completion(false)
            print("not verified")
            return
        }
        
        if let urlHttp = Utilities.addHttp(urlString: urlString){
            UIApplication.shared.open(urlHttp, options: [:], completionHandler: {(success) in
                if success{
                    print("website opend")
                    completion(true)
                }else{
                    completion(false)
                }
            })
        } else{
            completion(false)
            print("not open")
        }
    }
}
