//
//  RegisterViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/3/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = K.appName + " Register"
        
        passwordTextField.delegate = self
        emailTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        passwordTextField.endEditing(true)
        confirmPasswordTextField.endEditing(true)
        emailTextField.endEditing(true)
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text, let email = emailTextField.text {
            if password != confirmPassword {
                DispatchQueue.main.async {
                    self.setError(nil)
                }
                return
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                    if let e = error {
                        DispatchQueue.main.async {
                            self.setError(e as NSError)
                        }
                        return
                    } else {
                        self.performSegue(withIdentifier: K.Segues.registerSegue, sender: self)
                    }
                }
            }
        }
    }
    
    func setError(_ error: NSError?) {
        let red = UIColor.red.cgColor
        
        if let e = error {
            switch e.code {
                case 17026: //Invalid password
                    passwordTextField.layer.borderWidth = 1
                    passwordTextField.layer.borderColor = red
                
                    errorLabel.text = "Invalid password. Passwords must be at least 6 characters."
                case 17034: //Missing email
                    emailTextField.layer.borderWidth = 1
                    emailTextField.layer.borderColor = red
                
                    errorLabel.text = "Missing email. Please enter an email address."
                case 17008: //Invalid email
                    emailTextField.layer.borderWidth = 1
                    emailTextField.layer.borderColor = red
                
                    errorLabel.text = "Invalid email address. Please enter a valid email address."
                case 17007: //Already used
                    emailTextField.layer.borderWidth = 1
                    emailTextField.layer.borderColor = red
                
                    errorLabel.text = "Email already in use. Please try entering a different email address or login with your existing account."
                default: //IDK???
                    errorLabel.text = "Something went wrong, please try again later."
            }
        } else {
            passwordTextField.layer.borderWidth = 1
            passwordTextField.layer.borderColor = red
            
            confirmPasswordTextField.layer.borderWidth = 1
            confirmPasswordTextField.layer.borderColor = red
            
            errorLabel.text = "Passwords must match."
        }

        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
    }
}

//MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        passwordTextField.layer.borderWidth = 0
        emailTextField.layer.borderWidth = 0
        confirmPasswordTextField.layer.borderWidth = 0
        
        errorLabel.text = ""
    }
}
