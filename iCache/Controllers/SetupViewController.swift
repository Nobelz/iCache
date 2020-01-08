//
//  SetupViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/7/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit
import Firebase

class SetupViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        usernameTextField.delegate = self
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        usernameTextField.endEditing(true)
    }
    
    @IBAction func setupPressed(_ sender: UIButton) {
        let red = UIColor.red.cgColor
        
        if let preUsername = usernameTextField.text {
            let username = preUsername.lowercased()
            
            if username == "" {
                usernameTextField.layer.borderWidth = 1
                usernameTextField.layer.borderColor = red
                
                errorLabel.text = "Please enter a username."
            } else {
                db.collection("users").whereField("username", isEqualTo: username)
                    .getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print(error)
                        } else {
                            if querySnapshot!.documents.count == 0 {
                                
                                //Write to database
                                
                                self.performSegue(withIdentifier: K.Segues.finishSetupSegue, sender: self)
                            } else {
                                self.usernameTextField.layer.borderWidth = 1
                                self.usernameTextField.layer.borderColor = red
                                
                                self.errorLabel.text = "That username is taken. Please try another."
                            }
                        }
                    }
            }
        }
    }
}

//MARK: - UITextFieldDelegate

extension SetupViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        usernameTextField.layer.borderWidth = 0
        errorLabel.text = ""
    }
}

extension SetupViewController: UIImagePickerControllerDelegate {
    func handleSelectProfileImageView() {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
}
