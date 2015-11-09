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
    
    enum Status{
        case Idle
        case Started
        case Pause
        
    }
    
    var status = Status.Idle

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        let currentTimer = TimerManager.sharedInstance.currentTimer
        var hourItems: [WKPickerItem] = []
        for hr in 0...23 {
            let pickerItem = WKPickerItem()
            pickerItem.caption = "hour"
            pickerItem.title = String(hr)
            hourItems.append(pickerItem)
        }
        hourPicker.setItems(hourItems)
        hourPicker.setSelectedItemIndex((currentTimer?.hour)!)
        
        var minItems: [WKPickerItem] = []
        for min in 0...59 {
            let pickerItem = WKPickerItem()
            pickerItem.caption = "minute"
            pickerItem.title = String(min)
            minItems.append(pickerItem)
        }
        minPicker.setItems(minItems)
        minPicker.setSelectedItemIndex((currentTimer?.minute)!)
        
        var secItems: [WKPickerItem] = []
        for sec in 0...59 {
            let pickerItem = WKPickerItem()
            pickerItem.caption = "seconds"
            pickerItem.title = String(sec)
            secItems.append(pickerItem)
        }
        secondsPicker.setItems(secItems)
        secondsPicker.setSelectedItemIndex((currentTimer?.second)!)
        updateLabel()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        status = .Idle
        resetTimer()
        updateLabel()
        if (TimerManager.sharedInstance.currentTimer?.timeStarted != nil) {
            status = .Started
            if (TimerManager.sharedInstance.currentTimer?.timePause != nil) {
                    status = .Pause
            }
            updateTimer()
        } else {
            secondsPicker.focus()
        }
        updateButtonText()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        resetTimer()
    }
    
    @IBAction func hourChanged(value: Int) {
        TimerManager.sharedInstance.currentTimer?.hour = value
        updateLabel()
    }
    
    @IBAction func minChanged(value: Int) {
        TimerManager.sharedInstance.currentTimer?.minute = value
        updateLabel()
    }
    
    @IBAction func secChanged(value: Int) {
        TimerManager.sharedInstance.currentTimer?.second = value
        updateLabel()
    }

    @IBAction func pauseResumeAction() {
        if (status == .Started) {
            status = .Pause
            TimerManager.sharedInstance.currentTimer?.pause()
        } else {
            status = .Started
            TimerManager.sharedInstance.currentTimer?.resume()
        }
        updateButtonText()
        updateLabel()
        updateTimer()
    }
    
    @IBAction func startStopAction() {
        
        if (status != .Idle) {
            status = .Idle
            TimerManager.sharedInstance.currentTimer?.stop()
        } else {
            status = .Started
            TimerManager.sharedInstance.currentTimer?.start()
        }
        
        updateButtonText()
        updateLabel()
        updateTimer()
    }
    
    func updateLabel() {
        
        itemLabel.setText(TimerManager.sharedInstance.currentTimer?.remainingTimeString())
        if (status == .Started) {
            if (TimerManager.sharedInstance.currentTimer?.remainingTotalTime == 0) {
                WKInterfaceDevice.currentDevice().playHaptic(.Stop)
                
            }
        }
    }
    
    
    func updateTimer() {
        resetTimer()
        if (status != .Idle) {
            hourPicker.setEnabled(false)
            hourPicker.resignFocus()
            minPicker.setEnabled(false)
            minPicker.resignFocus()
            secondsPicker.setEnabled(false)
            secondsPicker.resignFocus()
            pauseResumeButton.setEnabled(true)
            
            if (status == .Started) {
                
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
    
    func resetTimer() {
        if let _ = timer {
            timer!.invalidate()
            timer = nil
        }
    }
    
    func updateButtonText() {
        if (status == .Idle) {
            pauseResumeButton.setTitle("Pause")
            pauseResumeButton.setEnabled(false)
            startStopButton.setTitle("Start")
            startStopButton.setEnabled(true)
        } else if (status == .Pause) {
            pauseResumeButton.setTitle("Resume")
            pauseResumeButton.setEnabled(true)
            startStopButton.setTitle("Stop")
            startStopButton.setEnabled(true)
        } else if (status == .Started) {
            pauseResumeButton.setTitle("Pause")
            pauseResumeButton.setEnabled(true)
            startStopButton.setTitle("Stop")
            startStopButton.setEnabled(true)
        }
    }

}
