//
//  ViewController.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 28.11.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    // MARK: - Outlets, Vars, Enum
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signUp: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let activeLogin = false
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
        isLoggingIn(false)
    }

    // MARK: - IBActions
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
    
    // MARK: - Request Handler
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
    
    // MARK: - Basic Functions
    func setup(){
        //signup label add gestures
        let tap = UITapGestureRecognizer(target: self, action: #selector(openSignupLink))
        signUp.isUserInteractionEnabled = true
        signUp.addGestureRecognizer(tap)

        //ui
        emailTextfield.layer.cornerRadius = Utilities.cornerRadius
        passwordTextfield.layer.cornerRadius = Utilities.cornerRadius
        loginButton.layer.cornerRadius = Utilities.cornerRadius
        
        isLoggingIn(false)
    }
    
    @objc func openSignupLink(){
        UIApplication.shared.open(LoginClient.signupURL, options: [:], completionHandler: nil)
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

extension LoginVC:  UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
}
