//
//  TimerManager.swift
//  MyTimer
//
//  Created by William Peroche on 9/11/15.
//  Copyright © 2015 William Peroche. All rights reserved.
//

import Foundation
import ClockKit

class TimerManager {
    static let sharedInstance = TimerManager()
    var currentTimer : Time?
    
    init () {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("saveTimers") {
            self.currentTimer = NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData) as? Time
        } else {
            self.currentTimer = Time()
            self.currentTimer?.repeating = true
            addTimer(self.currentTimer!)
        }
    }
    
    func addTimer(time : Time) {
        NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(time), forKey: "saveTimers")
    }

    class func reloadComplications() {
        if let complications: [CLKComplication] = CLKComplicationServer.sharedInstance().activeComplications {
            if complications.count > 0 {
                for complication in complications {
                    CLKComplicationServer.sharedInstance().reloadTimelineForComplication(complication)
                    NSLog("Reloading complication \(complication.description)...")
                }
                
            }
        }
    }
    
}