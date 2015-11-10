//
//  Time.swift
//  MyTimer
//
//  Created by William Peroche on 9/11/15.
//  Copyright © 2015 William Peroche. All rights reserved.
//

import UIKit
import Foundation
import WatchKit

class Time: NSObject {
    
    var hour : Int = 0
    var minute : Int = 0
    var second : Int = 0
    var remainingTotalTime : Int = 0
    var timeStarted : NSDate?
    var timePause : NSDate?
    var name : String = ""
    var id : String?
    var totalPauseTime : Int = 0
    var repeating = false
    
    override init() {
        id = NSUUID().UUIDString
        timeStarted = nil
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeInteger(hour, forKey: "hour")
        aCoder.encodeInteger(minute, forKey: "minute")
        aCoder.encodeInteger(second, forKey: "second")
        aCoder.encodeInteger(totalPauseTime, forKey: "totalPauseTime")
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(timeStarted, forKey: "timeStarted")
        aCoder.encodeObject(timePause, forKey: "timePause")
        aCoder.encodeBool(repeating, forKey: "repeating")

    }
    
    init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        id = aDecoder.decodeObjectForKey("id") as? String
        hour = aDecoder.decodeIntegerForKey("hour")
        minute = aDecoder.decodeIntegerForKey("minute")
        second = aDecoder.decodeIntegerForKey("second")
        totalPauseTime = aDecoder.decodeIntegerForKey("totalPauseTime")
        timeStarted = aDecoder.decodeObjectForKey("timeStarted") as? NSDate
        timePause = aDecoder.decodeObjectForKey("timePause") as? NSDate
        repeating = aDecoder.decodeBoolForKey("repeating")

    }
    
    func save() {
        TimerManager.sharedInstance.addTimer(self)
    }
    
    func remainingTimeString() -> String {
        
        let timerValue = getTimerValue()
        
        if (timerValue == 0) {
            return timerInString(0)
        }
        
        if let _ = timeStarted {
            let currentDate = NSDate()
            var timeLapse : Int = (Int)(currentDate.timeIntervalSinceDate(timeStarted!))
            
            
            if (timePause != nil) {
                timeLapse = (Int)((timePause!.timeIntervalSinceDate(timeStarted!)))
            }
            
            remainingTotalTime = timerValue - ((timeLapse - totalPauseTime) % (timerValue + 1))
            if !repeating {
                if ((timeLapse - totalPauseTime) / (timerValue + 1) > 1) {
                    remainingTotalTime = 0
                }
            }
            
            
        } else  {
            remainingTotalTime = timerValue
        }
        
        if (remainingTotalTime == 0 && timeStarted != nil) {
            if !repeating {
                stop()
            }
            WKInterfaceDevice.currentDevice().playHaptic(.Notification)
            
        }
        
        return timerInString(remainingTotalTime)
    }
    
    func start() {
        timeStarted = NSDate()
        timePause = nil
        totalPauseTime = 0
        remainingTotalTime = getTimerValue()
        save()
    }
    
    func stop() {
        timeStarted = nil
        timePause = nil
        totalPauseTime = 0
        save()
    }
    
    func pause() {
        timePause = NSDate()
        save()
    }
    
    func resume() {
        let pauseTime = (Int)(NSDate().timeIntervalSinceDate(timePause!))
        totalPauseTime += pauseTime
        timePause = nil
        save()
    }
    
    func getTimerValue() -> Int {
        var timerValue = 0
        timerValue += second
        timerValue += minute * 60
        timerValue += hour * 60 * 60
        
        return timerValue
    }
    
    func timerInString(value : Int) -> String {
        let uHour : Int = value / 3600
        let minLeft : Int = value / 60
        let uMin : Int = minLeft % 60
        let uSec : Int = value % 60
        
        let text = String(format: "%02d", uHour) + ":" + String(format: "%02d", uMin) + ":" + String(format: "%02d", uSec)
        
        return text
    }
    
}
