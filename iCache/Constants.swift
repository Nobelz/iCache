//
//  Constants.swift
//  iCache
//
//  Created by Nobel Zhou on 1/2/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import Foundation

struct K {
    static let appName = "🌎iCache🌍"
    static let moreCellNibName = "MoreTableViewCell"
    static let logCellNibName = "ProfileCell"
    static let cellIdentifier = "ReusableCell"
    static let searchControllerId = "LocationSearchTable"
    static let hintMessage = "Get closer to get more clues!"
    
    struct BrandColors {
        static let blue = "BrandBlue"
        static let purple = "BrandPurple"
        static let lightBlue = "BrandLightBlue"
        static let gray = "BrandGray"
        static let green = "BrandGreen"
        static let orange = "BrandOrange"
        static let yellow = "BrandYellow"
        static let red = "BrandRed"
    }
    
    struct Segues {
        static let directLoginSegue = "WelcomeToMain"
        static let loginSegue = "LoginToMain"
        static let directSetupSegue = "WelcomeToSetup"
        static let setupSegue = "LoginToSetup"
        static let finishSetupSegue = "SetupToMain"
        static let geocacheSegue = "MapToGeocache"
        static let navigationSegue = "GeocacheToNavigate"
    }
}
