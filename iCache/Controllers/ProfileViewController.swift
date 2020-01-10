//
//  ProfileViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/8/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import FirebaseUI

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var geocachesFoundLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()

    var user: Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let usersRef = Firestore.firestore().collection("users")
        let storageRef = Storage.storage().reference()
        
        usersRef.whereField("email", isEqualTo: Auth.auth().currentUser!.email!)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        
                        let email = data["email"] as! String
                        let profilePicURL = data["profilePic"] as! String
                        let joinDate = data["joinDate"] as! String
                        let geocachesFound = data["geocachesFound"] as! Int
                        let username = data["username"] as! String
                        
                        self.user = Profile(email: email, profilePicURL: profilePicURL, joinDate: joinDate, geocachesFound: geocachesFound, username: username)
                        
                        let reference = storageRef.child(self.user!.profilePicURL)
                        let placeholderImage = UIImage(named: "placeholder.png")
                        self.profileImageView.sd_setImage(with: reference, placeholderImage: placeholderImage)
                        
                        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
                        self.profileImageView.clipsToBounds = true
                        
                        self.dateCreatedLabel.text = "Joined: " + self.user!.joinDate
                        self.geocachesFoundLabel.text = "\(self.user!.geocachesFound) Found"
                        
                        self.usernameLabel.text = self.user!.username.capitalized
                    }
                }
        }
    }
}
