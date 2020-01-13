//
//  Log.swift
//  iCache
//
//  Created by Nobel Zhou on 1/12/20.
//  Copyright © 2020 Nobel Zhou. All rights reserved.
//

import Foundation
import Firebase

struct Log {
    let date: Double
    let isSuccess: Bool
    let id: String
    
    static func addGeocacheToLog(log: String?, geocache: Geocache, isSuccess: Bool) -> String{
        let date = Date().timeIntervalSince1970
        
        if isSuccess {
            if log != nil {
                return log! + ";" + geocache.id + ",success,\(date)"
            } else {
                return geocache.id + ",success,\(date)"
            }
        } else {
            if log != nil {
                return log! + ";" + geocache.id + ",fail,\(date)"
            } else {
                return geocache.id + ",fail,\(date)"
            }
        }
    }
    
    static func parseLog(log: String) -> [Log] {
        let parsedArray = log.components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        
        var logs: [Log] = []
        
        for array in parsedArray {
            var isSuccess: Bool
            if array[1] == "success" {
                isSuccess = true
            } else {
                isSuccess = false
            }
            
            let dateInterval = Double(array[2])
            
            logs.append(Log(date: dateInterval!, isSuccess: isSuccess, id: array[0]))
        }
        
        return logs
    }
    
    static func checkGeocache(geocache: Geocache, logs: [Log]) -> Bool {
        for log in logs {
            if log.id == geocache.id && Date().timeIntervalSince1970 < log.date + 86400 {
                return false
            }
        }
        
        return true
    }
}
