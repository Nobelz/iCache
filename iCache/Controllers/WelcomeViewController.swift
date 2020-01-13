//
//  WelcomeViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/2/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        titleLabel.text = K.appName
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if Auth.auth().currentUser != nil {
                self.db.collection("users").whereField("email", isEqualTo: Auth.auth().currentUser!.email!)
                    .getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print(error)
                        } else {
                            DispatchQueue.main.async {
                                if querySnapshot!.documents.count == 0 {
                                    self.performSegue(withIdentifier: K.Segues.directSetupSegue, sender: self)
                                } else {
                                    self.performSegue(withIdentifier: K.Segues.directLoginSegue, sender: self)
                                }
                            }
                        }
                }
            } else {
                self.loginButton.isHidden = false
                self.registerButton.isHidden = false
            }
        }
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let navBar = navigationController?.navigationBar {
            navBar.barTintColor = UIColor(named: K.BrandColors.blue)
            navBar.tintColor = UIColor.white
            
            let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
            navigationController?.navigationBar.titleTextAttributes = textAttributes
        }
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let navBar = navigationController?.navigationBar {
            navBar.barTintColor = UIColor(named: K.BrandColors.lightBlue)
            navBar.tintColor = UIColor(named: K.BrandColors.blue)
            
            let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor(named: K.BrandColors.blue)]
            navigationController?.navigationBar.titleTextAttributes = textAttributes as [NSAttributedString.Key : Any]
        }
    }
}

