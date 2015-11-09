//
//  TimerManager.swift
//  MyTimer
//
//  Created by William Peroche on 9/11/15.
//  Copyright © 2015 William Peroche. All rights reserved.
//

import Foundation

class TimerManager {
    static let sharedInstance = TimerManager()
    var currentTimer : Time?
    
    init () {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("saveTimer") {
            self.currentTimer = NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData) as? Time
        } else {
            self.currentTimer = Time()
        }
    }
    
}