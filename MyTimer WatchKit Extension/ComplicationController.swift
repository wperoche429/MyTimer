//
//  ComplicationController.swift
//  MyTimer WatchKit Extension
//
//  Created by William Peroche on 9/11/15.
//  Copyright © 2015 William Peroche. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    var timer : NSTimer?
    
    // MARK: - Timeline Configuration
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.Forward])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        let currentDate = NSDate()
        handler(currentDate)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        let currentDate = NSDate()
        let endDate =
        currentDate.dateByAddingTimeInterval(NSTimeInterval(1))
        
        handler(endDate)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        // Call the handler with the current timeline entry
        if complication.family == .ModularLarge {
            let template = CLKComplicationTemplateModularLargeStandardBody()
            let currentTimer = TimerManager.sharedInstance.currentTimer!
            if let _ = currentTimer.timeStarted {
                if let _ = timer {
                    //Do nothing
                } else {
                    timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("reloadComplications"), userInfo: nil, repeats: true)
                }
            } else {
                if let _ = timer {
                    timer!.invalidate()
                    timer = nil
                }
            }
            
            template.headerTextProvider = CLKSimpleTextProvider(text: "My Timer")
            template.body1TextProvider = CLKSimpleTextProvider(text: currentTimer.remainingTimeString())
            
            let entry = CLKComplicationTimelineEntry(date: NSDate(),
                complicationTemplate: template)
            
            handler(entry)
        } else {
            handler(nil)
        }
    }
    
    func reloadComplications() {
        TimerManager.reloadComplications()
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        handler(nil);
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        let template = CLKComplicationTemplateModularLargeStandardBody()
        template.headerTextProvider =
            CLKSimpleTextProvider(text: "My Timer")
        template.body1TextProvider =
            CLKSimpleTextProvider(text: "Remaining Time")
        
        handler(template)
    }
    
}
