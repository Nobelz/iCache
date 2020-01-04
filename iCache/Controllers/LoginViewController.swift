//
//  LoginViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/3/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var passwordButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = K.appName + " Login"
        
        passwordTextField.delegate = self
        emailTextField.delegate = self
        passwordButton.titleLabel?.textAlignment = .center
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        passwordTextField.endEditing(true)
        emailTextField.endEditing(true)
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                if let e = error {
                    DispatchQueue.main.async {
                        self.setError(e as NSError)
                    }
                    return
                } else {
                    self.performSegue(withIdentifier: K.Segues.loginSegue, sender: self)
                }
            }
        }
    }
    
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: K.Segues.forgotPasswordSegue, sender: self)
    }
    
    func setError(_ error: NSError) {
        let red = UIColor.red.cgColor
        
        switch error.code {
            case 17008: //Invalid email
                emailTextField.layer.borderWidth = 1
                emailTextField.layer.borderColor = red
            
                errorLabel.text = "Invalid email address. Please enter a valid email address."
            case 17009: //Already used
                passwordTextField.layer.borderWidth = 1
                passwordTextField.layer.borderColor = red
            
                errorLabel.text = "Password is invalid."
            case 17011:
                emailTextField.layer.borderWidth = 1
                emailTextField.layer.borderColor = red
                
                errorLabel.text = "Your email does not match any user's email. If you are new, please register for a new account."
            default: //IDK???
                errorLabel.text = "Something went wrong, please try again later."
        }
        
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
}

//MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        passwordTextField.layer.borderWidth = 0
        emailTextField.layer.borderWidth = 0
        errorLabel.text = ""
    }
}
