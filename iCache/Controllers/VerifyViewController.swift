//
//  VerifyViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/4/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit
import Firebase

class VerifyViewController: UIViewController {
    
    var email: String?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = K.verifyMessage + " " + (email ?? "")
        title = K.appName + " Verify Email"
    }
    
    @IBAction func resendEmailPressed(_ sender: UIButton) {
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            if let e = error {
                DispatchQueue.main.async {
                    print(e as NSError)
                }
                return
            }
        }
    }
    
    @IBAction func okPressed(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
        navigationController?.popToRootViewController(animated: true)
    }
}
