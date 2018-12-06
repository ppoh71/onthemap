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
    
    let signupURL = URL(string: "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated")!
    let activeLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isLoggingIn(false)
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let username =  emailTextfield.text, !username.isEmpty else {
            showAlert(title: "Login Faliure", message: "Please Provide Your Login Credentials! (Username is empty?)")
            return
        }
        
        guard let password =  passwordTextfield.text, !password.isEmpty else {
            showAlert(title: "Login Faliure", message: "Please Provide Your Login Credentials! (Password is empty?)")
            return
        }
        
        isLoggingIn(true)
        LoginClient.login(username: username, password: password, completion: requestHandlerLogin(response:error:))
    }
    
    func requestHandlerLogin(response: LoginResponse?, error: Error?){
        if error != nil{
            showAlert(title: "Login failure", message: error?.localizedDescription ?? "Login Failure")
            isLoggingIn(false)
            return
        }
        LoginClient.getUserData(key: LoginClient.Auth.key, completion: requestHandlerUserData(success:error:))
    }
    
    func requestHandlerUserData(success: Bool, error: Error?){
        if error != nil{
            showAlert(title: "Login failure", message: "Getting User Data Failed (\(String(describing: error)))"  )
            return
        }
        isLoggingIn(false)
        performSegue(withIdentifier: "LoginSuccessSegue", sender: nil)
    }
    
    func setup(){
        //signup label add gestures
        let tap = UITapGestureRecognizer(target: self, action: #selector(openSignupLink))
        signUp.isUserInteractionEnabled = true
        signUp.addGestureRecognizer(tap)
        print(Utilities.cornerRadius)
        print("setupt")
        //ui
        emailTextfield.layer.cornerRadius = Utilities.cornerRadius
        passwordTextfield.layer.cornerRadius = Utilities.cornerRadius
        loginButton.layer.cornerRadius = Utilities.cornerRadius
        
        isLoggingIn(false)
    }
    
    @objc func openSignupLink(){
        UIApplication.shared.open(signupURL, options: [:], completionHandler: nil)
    }
    
    func showAlert(title: String, message: String){
        let alert = Alerts.defineAlert(title: title, message: message)
        show(alert, sender: nil)
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

