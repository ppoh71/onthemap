//
//  ViewController.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 28.11.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signUp: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let cornerRadius = CGFloat(2.0)
    let signupURL = URL(string: "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated")!
    let activeLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        print("login tapped")
        isLoggingIn(true)
        //performSegue(withIdentifier: "LoginSuccessSegue", sender: nil) // debug shortcut
        
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            LoginClient.udacityLogin(username: email, password: password, completion: requestHandlerLogin(response:error:))
        }
    }
    
    func requestHandlerLogin(response: LoginResponse?, error: Error?){
        if error != nil{
            showAlert(title: "Login failure", message: error?.localizedDescription ?? "Login Failure")
            isLoggingIn(false)
            return
        }
      
        if let udacityResponse = response{
           print(udacityResponse.account.registered)
           print(udacityResponse.session.id)
           //go on with segue
           isLoggingIn(false)
           performSegue(withIdentifier: "LoginSuccessSegue", sender: nil)
        }
    }
    
    func setup(){
        //signup label add gestures
        let tap = UITapGestureRecognizer(target: self, action: #selector(openSignupLink))
        signUp.isUserInteractionEnabled = true
        signUp.addGestureRecognizer(tap)
        
        //ui
        emailTextfield.layer.cornerRadius = cornerRadius
        passwordTextfield.layer.cornerRadius = cornerRadius
        loginButton.layer.cornerRadius = cornerRadius
    }
    
    @objc func openSignupLink(){
        UIApplication.shared.open(signupURL, options: [:], completionHandler: nil)
    }
    
    func showAlert(title: String, message: String){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        show(alertVC, sender: nil)
    }
    
    func isLoggingIn(_ activeLogin: Bool){
        
        if activeLogin{
             spinner.startAnimating()
        }else{
            spinner.stopAnimating()
        }
       
        emailTextfield.isEnabled = !activeLogin
        passwordTextfield.isEnabled = !activeLogin
        loginButton.isEnabled = !activeLogin
    }
}

