//
//  ShowAlert.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 01.12.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit

class Alerts{
    class func defineAlert(title: String, message: String) -> UIAlertController{
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alertVC
    }
}


