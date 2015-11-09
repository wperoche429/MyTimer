//
//  Time.swift
//  MyTimer
//
//  Created by William Peroche on 9/11/15.
//  Copyright © 2015 William Peroche. All rights reserved.
//

import UIKit
import Foundation

class Time: NSObject {

    var hour : Int = 0 {
        didSet {
            save()
        }
    }
    
    var minute : Int = 0 {
        didSet {
            save()
        }
    }
    
    var second : Int = 0 {
        didSet {
            save()
        }
    }
    
    var remainingTotalTime : Int = 0
    var timeStarted : NSDate?
    var timePause : NSDate?
    var name : String = ""
    var id : String?
    var totalPauseTime : Int = 0
    
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
    }

    func save() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "saveTimer")
    }
    
    func remainingTimeString() -> String {
        var timerValue = 0
        timerValue += second
        timerValue += minute * 60
        timerValue += hour * 60 * 60
        
        remainingTotalTime = -1
        if (timerValue == 0) {
            return "00:00:00"
        }
        
        if let _ = timeStarted {
            let currentDate = NSDate()
            var timeLapse : Int = (Int)(currentDate.timeIntervalSinceDate(timeStarted!))
            

            if (timePause != nil) {
                timeLapse = (Int)((timePause!.timeIntervalSinceDate(timeStarted!)))
            }
            
            remainingTotalTime = timerValue - ((timeLapse - totalPauseTime) % (timerValue + 1))
            
            
        } else  {
            remainingTotalTime = timerValue
        }
        
        let uHour : Int = remainingTotalTime / 3600
        let minLeft : Int = remainingTotalTime / 60
        let uMin : Int = minLeft % 60
        let uSec : Int = remainingTotalTime % 60
        
        let text = String(format: "%02d", uHour) + ":" + String(format: "%02d", uMin) + ":" + String(format: "%02d", uSec)
        print(text)
        return text
    }
    
    func start() {
        timeStarted = NSDate()
        timePause = nil
        totalPauseTime = 0
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
    
    
}
