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
        if (TimerManager.sharedInstance.currentTimer?.timeStarted != nil) {
            if (status == .Idle) {
                startStopAction()
            }
        } else {
            pauseResumeButton.setTitle("Pause")
            pauseResumeButton.setEnabled(false)
            startStopButton.setTitle("Start")
            startStopButton.setEnabled(true)
            secondsPicker.focus()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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
            pauseResumeButton.setTitle("Resume")
            TimerManager.sharedInstance.currentTimer?.pause()
        } else {
            status = .Started
            pauseResumeButton.setTitle("Pause")
            TimerManager.sharedInstance.currentTimer?.resume()
        }
        updateLabel()
        updateTimer()
    }
    
    @IBAction func startStopAction() {
        
        if (status != .Idle) {
            status = .Idle
            startStopButton.setTitle("Start")
            pauseResumeButton.setTitle("Pause")
            TimerManager.sharedInstance.currentTimer?.stop()
        } else {
            status = .Started
            TimerManager.sharedInstance.currentTimer?.start()
            startStopButton.setTitle("Stop")
            pauseResumeButton.setTitle("Pause")
        }
        
        updateLabel()
        updateTimer()
    }
    
    func updateLabel() {
        
        itemLabel.setText(TimerManager.sharedInstance.currentTimer?.remainingTimeString())
        reloadComplications()
        if (status == .Started) {
            if (TimerManager.sharedInstance.currentTimer?.remainingTotalTime == 0) {
                WKInterfaceDevice.currentDevice().playHaptic(.Stop)
                
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
