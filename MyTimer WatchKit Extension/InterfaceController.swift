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
    var currentTimer : Time?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        currentTimer = TimerManager.sharedInstance.currentTimer
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
        updateUI()
        startTimer()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        stopTimer()
    }
    
    @IBAction func hourChanged(value: Int) {
        currentTimer?.hour = value
        updateLabel()
    }
    
    @IBAction func minChanged(value: Int) {
        currentTimer?.minute = value
        updateLabel()
    }
    
    @IBAction func secChanged(value: Int) {
        currentTimer?.second = value
        updateLabel()
    }

    @IBAction func pauseResumeAction() {
        if let _ = currentTimer?.timePause {
            currentTimer?.resume()
        } else {
            currentTimer?.pause()
        }
        
        updateLabel()
        updateUI()
        TimerManager.reloadComplications()
    }
    
    @IBAction func startStopAction() {
        
        if let _ = currentTimer?.timeStarted {
            currentTimer?.stop()
            stopTimer()
        } else {
            currentTimer?.start()
            startTimer()
        }
        updateLabel()
        updateUI()
        TimerManager.reloadComplications()
    }
    
    func updateLabel() {
        
        itemLabel.setText(currentTimer?.remainingTimeString())

    }

    
    func resetTimer() {
        
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateLabel"), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if let _ = timer {
            timer!.invalidate()
            timer = nil
        }
    }
    
    func updateUI() {
        if let _ = currentTimer?.timeStarted {
            if let _ = currentTimer?.timePause {
                pauseResumeButton.setTitle("Resume")
                pauseResumeButton.setEnabled(true)
                startStopButton.setTitle("Stop")
                startStopButton.setEnabled(true)
                
                
            } else {
                pauseResumeButton.setTitle("Pause")
                pauseResumeButton.setEnabled(true)
                startStopButton.setTitle("Stop")
                startStopButton.setEnabled(true)
            }
            
            hourPicker.setEnabled(false)
            hourPicker.resignFocus()
            minPicker.setEnabled(false)
            minPicker.resignFocus()
            secondsPicker.setEnabled(false)
            secondsPicker.resignFocus()
            pauseResumeButton.setEnabled(true)
        } else  {
            pauseResumeButton.setTitle("Pause")
            pauseResumeButton.setEnabled(false)
            startStopButton.setTitle("Start")
            startStopButton.setEnabled(true)
            
            hourPicker.setEnabled(true)
            minPicker.setEnabled(true)
            secondsPicker.setEnabled(true)
            secondsPicker.focus()
            pauseResumeButton.setEnabled(false)
        }
        
    }

}
