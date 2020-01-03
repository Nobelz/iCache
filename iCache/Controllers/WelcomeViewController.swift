//
//  WelcomeViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/2/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
        
    @IBOutlet var titleLabel: UILabel!
    
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
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let navBar = navigationController?.navigationBar {
            navBar.barTintColor = UIColor(named: K.BrandColors.blue)
            navBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let navBar = navigationController?.navigationBar {
            navBar.barTintColor = UIColor(named: K.BrandColors.lightBlue)
            navBar.tintColor = UIColor(named: K.BrandColors.blue)
        }
    }
}

