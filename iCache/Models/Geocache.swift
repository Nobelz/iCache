//
//  Geocache.swift
//  iCache
//
//  Created by Nobel Zhou on 1/7/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import UIKit
import CoreLocation

struct Geocache {
    var name: String
    var placedBy: String
    var datePlaced: Date
    var month: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: datePlaced)
        return "\(components.month!)"
    }
    var year: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: datePlaced)
        return "\(components.year!)"
    }
    var day: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: datePlaced)
        return "\(components.day!)"
    }
    var difficulty: Double
    var location: CLLocation
    var numberOfFinds: Int
    var hints: [String]
    var id: String
    
    func getDateString() -> String {
        return month + "/" + day + "/" + year
    }
}
