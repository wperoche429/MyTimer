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
    var timeResume : NSDate?
    var name : String = ""
    var id : String?
    
    override init() {
        id = NSUUID().UUIDString
        timeStarted = nil
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeInteger(hour, forKey: "hour")
        aCoder.encodeInteger(minute, forKey: "minute")
        aCoder.encodeInteger(second, forKey: "second")
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(timeStarted, forKey: "timeStarted")
        aCoder.encodeObject(timePause, forKey: "timePause")
        aCoder.encodeObject(timeResume, forKey: "timeResume")
    }
    
    init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        id = aDecoder.decodeObjectForKey("id") as? String
        hour = aDecoder.decodeIntegerForKey("hour")
        minute = aDecoder.decodeIntegerForKey("minute")
        second = aDecoder.decodeIntegerForKey("second")
        timeStarted = aDecoder.decodeObjectForKey("timeStarted") as? NSDate
        timePause = aDecoder.decodeObjectForKey("timePause") as? NSDate
        timeResume = aDecoder.decodeObjectForKey("timeResume") as? NSDate
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
            let timeLapse : Int = (Int)(NSDate().timeIntervalSinceDate(timeStarted!))
            remainingTotalTime = timerValue - (timeLapse % (timerValue + 1))

            if (timeResume != nil && timePause != nil) {
                let pauseTime = (Int)((timeResume?.timeIntervalSinceDate(timePause!))!)
                remainingTotalTime += pauseTime
            }
            
            
        } else  {
            remainingTotalTime = timerValue
        }
        
        let uHour : Int = remainingTotalTime / 3600
        let minLeft : Int = remainingTotalTime / 60
        let uMin : Int = minLeft % 60
        let uSec : Int = remainingTotalTime % 60
        
        let text = String(format: "%02d", uHour) + ":" + String(format: "%02d", uMin) + ":" + String(format: "%02d", uSec)
        
        return text
    }
    
    func start() {
        timeStarted = NSDate()
        timePause = nil
        timeResume = nil
        save()
    }
    
    func stop() {
        timeStarted = nil
        timePause = nil
        timeResume = nil
        save()
    }
    
    func pause() {
        timePause = NSDate()
        timeResume = nil
        save()
    }
    
    func resume() {
        timeResume = NSDate()
        save()
    }
    
    
}
