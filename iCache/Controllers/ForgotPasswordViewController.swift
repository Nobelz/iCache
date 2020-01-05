//
//  ForgotPasswordViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/4/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = "Back"
        emailTextField.delegate = self
        title = "Forgot Password?"
    }
    
    func setError(_ error: NSError) {
        let red = UIColor.red.cgColor
        
        switch error.code {
            case 17008: //Invalid email
                emailTextField.layer.borderWidth = 1
                emailTextField.layer.borderColor = red
            
                errorLabel.text = "Invalid email address. Please enter a valid email address."
            case 17034: //Already used
                emailTextField.layer.borderWidth = 1
                emailTextField.layer.borderColor = red
                
                errorLabel.text = "Please enter an email address."
            case 17011:
                emailTextField.layer.borderWidth = 1
                emailTextField.layer.borderColor = red
                
                errorLabel.text = "Your email does not match any user's email. If you are new, please register for a new account."
            default: //IDK???
                errorLabel.text = "Something went wrong, please try again later."
        }
        
        emailTextField.resignFirstResponder()
    }
    
    @IBAction func resetPressed(_ sender: UIButton) {
        if let email = emailTextField.text {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let e = error {
                    self.setError(e as NSError)
                    return
                } else {
                    let alertController = UIAlertController(title: "Reset Password Link Sent", message: "Reset Password Link has been sent to your email: " + email, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                        DispatchQueue.main.async {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        emailTextField.layer.borderWidth = 0
        errorLabel.text = ""
    }
}
