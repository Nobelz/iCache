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
    static let verifyMessage = "Your email must be verified first. Please check your email at:"
    
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
        static let loginSegue = "LoginToMain"
        static let registerSegue = "RegisterToVerify"
        static let loginVerifySegue = "LoginToVerify"
    }
}
