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
    let picker = UIImagePickerController()
    let storage = Storage.storage()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        usernameTextField.delegate = self
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        profileImageView.isUserInteractionEnabled = true
        
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
                                let storageRef = self.storage.reference().child("images/profile/" + Auth.auth().currentUser!.uid + "/profile.png")
                                let imgData = self.profileImageView.image?.pngData()
                                let metaData = StorageMetadata()
                                
                                metaData.contentType = "image/png"
                                storageRef.putData(imgData!, metadata: metaData)
                                
                                let date = Date()
                                let calendar = Calendar.current
                                var components = calendar.dateComponents([.day], from: date)
                                let day = components.day
                                components = calendar.dateComponents([.month], from: date)
                                let month = components.month
                                components = calendar.dateComponents([.year], from: date)
                                let year = components.year
                                
                                let dateString = "\(month!)/\(day!)/\(year!)"
                                
                                if let username = self.usernameTextField.text {
                                    self.db.collection("users").addDocument(data: [
                                        "email": Auth.auth().currentUser!.email!,
                                        "profilePic": "images/profile/" + Auth.auth().currentUser!.uid + "/profile.png",
                                        "joinDate": dateString,
                                        "geocachesFound": 0,
                                        "username": username
                                    ])
                                }
                                
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

extension SetupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func handleSelectProfileImageView() {
        picker.delegate = self
        picker.allowsEditing = true
        
        let alertController = UIAlertController(title: "Choose Image Source", message: "Please choose from existing photos or take a new one.", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Choose from Photos", style: .default, handler: { (_) in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Take New Photo", style: .default, handler: { (_) in
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
