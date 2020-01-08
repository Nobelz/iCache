//
//  MainViewController.swift
//  iCache
//
//  Created by Nobel Zhou on 1/5/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class MainViewController: UITabBarController {
    
    let locationManager = CLLocationManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
}
