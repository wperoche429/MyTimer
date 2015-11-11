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


class InterfaceController: WKInterfaceController, TimeDelegate {
    
    
    @IBOutlet var itemLabel: WKInterfaceLabel!
    @IBOutlet var pauseResumeButton: WKInterfaceButton!
    @IBOutlet var startStopButton: WKInterfaceButton!
    @IBOutlet var hourPicker: WKInterfacePicker!
    @IBOutlet var minPicker: WKInterfacePicker!
    @IBOutlet var secondsPicker: WKInterfacePicker!
//    var timer : NSTimer?
    var timer : Time?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        timer = TimerManager.sharedInstance.currentTimer
        var hourItems: [WKPickerItem] = []
        for hr in 0...23 {
            let pickerItem = WKPickerItem()
            pickerItem.caption = "hour"
            pickerItem.title = String(hr)
            hourItems.append(pickerItem)
        }
        hourPicker.setItems(hourItems)
        hourPicker.setSelectedItemIndex((timer?.hour)!)
        
        var minItems: [WKPickerItem] = []
        for min in 0...59 {
            let pickerItem = WKPickerItem()
            pickerItem.caption = "minute"
            pickerItem.title = String(min)
            minItems.append(pickerItem)
        }
        minPicker.setItems(minItems)
        minPicker.setSelectedItemIndex((timer?.minute)!)
        
        var secItems: [WKPickerItem] = []
        for sec in 0...59 {
            let pickerItem = WKPickerItem()
            pickerItem.caption = "seconds"
            pickerItem.title = String(sec)
            secItems.append(pickerItem)
        }
        secondsPicker.setItems(secItems)
        secondsPicker.setSelectedItemIndex((timer?.second)!)
        updateLabel()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        updateUI()
        timer?.subscribe(self)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        timer?.unsubscribe(self)
    }
    
    @IBAction func hourChanged(value: Int) {
        timer?.hour = value
        updateLabel()
    }
    
    @IBAction func minChanged(value: Int) {
        timer?.minute = value
        updateLabel()
    }
    
    @IBAction func secChanged(value: Int) {
        timer?.second = value
        updateLabel()
    }

    @IBAction func pauseResumeAction() {
        if let _ = timer?.timePause {
            timer?.resume()
        } else {
            timer?.pause()
        }
        
        updateLabel()
        updateUI()
        TimerManager.reloadComplications()
    }
    
    @IBAction func startStopAction() {
        
        if let _ = timer?.timeStarted {
            timer?.stop()
        } else {
            timer?.start()
        }
        updateLabel()
        updateUI()
        TimerManager.reloadComplications()
    }
    
    func updateLabel() {
        
        itemLabel.setText(timer?.timeInString)

    }


    
    func updateUI() {
        if let _ = timer?.timeStarted {
            if let _ = timer?.timePause {
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
    
    func timeUpdate(timeInString: String) {
        itemLabel.setText(timeInString)
        updateUI()
    }


}
