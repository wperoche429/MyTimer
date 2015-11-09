//
//  InterfaceController.swift
//  MyTimer WatchKit Extension
//
//  Created by William Peroche on 9/11/15.
//  Copyright © 2015 William Peroche. All rights reserved.
//

import WatchKit
import Foundation
import ClockKit


class InterfaceController: WKInterfaceController {
    
    
    @IBOutlet var itemLabel: WKInterfaceLabel!
    @IBOutlet var pauseResumeButton: WKInterfaceButton!
    @IBOutlet var startStopButton: WKInterfaceButton!
    @IBOutlet var hourPicker: WKInterfacePicker!
    @IBOutlet var minPicker: WKInterfacePicker!
    @IBOutlet var secondsPicker: WKInterfacePicker!
    var timer : NSTimer?
    var minute = 0
    var seconds = 0
    var hour = 0
    var remainingTime = 0
    
    enum Status{
        case Launch
        case Idle
        case Started
        case Pause
        
    }
    
    var status = Status.Launch

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if let saveTime = NSUserDefaults.standardUserDefaults().objectForKey("remainingTime") {
            remainingTime = saveTime.integerValue
            hour = remainingTime / 3600
            let minLeft : Int = remainingTime / 60
            minute = minLeft % 60
            seconds = remainingTime % 60
        }
        
        var hourItems: [WKPickerItem] = []
        for hr in 0...23 {
            let pickerItem = WKPickerItem()
            pickerItem.caption = "hour"
            pickerItem.title = String(hr)
            hourItems.append(pickerItem)
        }
        hourPicker.setItems(hourItems)
        hourPicker.setSelectedItemIndex(hour)
        
        var minItems: [WKPickerItem] = []
        for min in 0...59 {
            let pickerItem = WKPickerItem()
            pickerItem.caption = "minute"
            pickerItem.title = String(min)
            minItems.append(pickerItem)
        }
        minPicker.setItems(minItems)
        minPicker.setSelectedItemIndex(minute)
        
        var secItems: [WKPickerItem] = []
        for sec in 0...59 {
            let pickerItem = WKPickerItem()
            pickerItem.caption = "seconds"
            pickerItem.title = String(sec)
            secItems.append(pickerItem)
        }
        secondsPicker.setItems(secItems)
        secondsPicker.setSelectedItemIndex(seconds)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if (status == .Launch) {
            updateLabel()
            secondsPicker.focus()
            pauseResumeButton.setEnabled(false)
            pauseResumeButton.setTitle("Pause")
            startStopButton.setEnabled(true)
            startStopButton.setTitle("Start")
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func hourChanged(value: Int) {
        hour = value
        computeRemainingTime()
        updateLabel()
    }
    
    @IBAction func minChanged(value: Int) {
        minute = value
        computeRemainingTime()
        updateLabel()
    }
    
    @IBAction func secChanged(value: Int) {
        seconds = value
        computeRemainingTime()
        updateLabel()
    }

    @IBAction func pauseResumeAction() {
        if (status == .Started) {
            status = .Pause
            pauseResumeButton.setTitle("Resume")
        } else {
            status = .Started
            pauseResumeButton.setTitle("Pause")
        }
        updateLabel()
        updateTimer()
    }
    
    @IBAction func startStopAction() {
        
        if (status != .Idle && status != .Launch) {
            status = .Idle
            startStopButton.setTitle("Start")
        } else {
            status = .Started
            startStopButton.setTitle("Stop")
        }
        
        computeRemainingTime()
        updateLabel()
        updateTimer()
        
    }
    
    func updateLabel() {
        
        let uHour : Int = remainingTime / 3600
        let minLeft : Int = remainingTime / 60
        let uMin : Int = minLeft % 60
        let uSec : Int = remainingTime % 60
        
        let text = String(format: "%02d", uHour) + ":" + String(format: "%02d", uMin) + ":" + String(format: "%02d", uSec)
        TimeData.sharedInstance.timeRemainingText = text
        itemLabel.setText(text)
        
        reloadComplications()
        if (status == .Started) {
            if (remainingTime == 0) {
                WKInterfaceDevice.currentDevice().playHaptic(.Stop)
                
            }
            
            remainingTime--
            if (remainingTime < 0) {
                computeRemainingTime()
            }
        }
    }
    
    func reloadComplications() {
        if let complications: [CLKComplication] = CLKComplicationServer.sharedInstance().activeComplications {
            if complications.count > 0 {
                for complication in complications {
                    CLKComplicationServer.sharedInstance().reloadTimelineForComplication(complication)
                    NSLog("Reloading complication \(complication.description)...")
                }
                
            }
        }
    }
    
    func computeRemainingTime () {
        remainingTime = 0
        if (seconds > 0) {
            remainingTime += seconds
        }
        
        if (minute > 0) {
            remainingTime += minute * 60
        }
        
        if (hour > 0) {
            remainingTime += hour * 60 * 60
        }
    }
    
    
    func updateTimer() {
        if let _ = timer {
            timer!.invalidate()
            timer = nil
        }
        
        if (status != .Idle) {
            hourPicker.setEnabled(false)
            hourPicker.resignFocus()
            minPicker.setEnabled(false)
            minPicker.resignFocus()
            secondsPicker.setEnabled(false)
            secondsPicker.resignFocus()
            pauseResumeButton.setEnabled(true)
            
            if (status == .Started) {
                computeRemainingTime()
                NSUserDefaults.standardUserDefaults().setInteger(remainingTime, forKey: "remainingTime")
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateLabel"), userInfo: nil, repeats: true)
            }
            
        } else {
            hourPicker.setEnabled(true)
            minPicker.setEnabled(true)
            secondsPicker.setEnabled(true)
            secondsPicker.focus()
            pauseResumeButton.setEnabled(false)
        }
        
        
    }

}
