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

