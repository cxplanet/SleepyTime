//
//  SettingsController.swift
//  SleepyTime
//
//  Created by James Lorenzo on 10/22/14.
//  Copyright (c) 2014 James Lorenzo. All rights reserved.
//

import UIKit
import CoreLocation

class SettingsController: UIViewController
{
    @IBOutlet weak var screenBrightness: UISlider?
    @IBOutlet weak var timePicker: UIDatePicker?
    
    let hoursKey = "alarmTimeHrs"
    let minutesKey = "alarmTimeMins"
    
    var alarmHour : Int = 0
    var alarmMin : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        screenBrightness?.value = Float(UIScreen.mainScreen().brightness)
        
        // see if we have an awake time already set
        timePicker?.addTarget(self, action: Selector("timePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        updateAlarmPickerWithUserDefaults()
    }
    
    func timePickerChanged(datePicker:UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        
        let calendar = NSCalendar.currentCalendar()
        let dateParts = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: timePicker!.date)
        
        NSLog("Hour is \(dateParts.hour)  minutes \(dateParts.minute)")
        
        updateAlarmDefaults(dateParts.hour, mins: dateParts.minute)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateAlarmPickerWithUserDefaults()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let hours = defaults.objectForKey(hoursKey) as? Int {
            if let minutes = defaults.objectForKey(minutesKey) as? Int {
                // set up the timer with a new date
                NSLog("Defaults: Alarm hour is \(hours)  minutes \(minutes)")
            }
        }
    }
    
    func updateAlarmDefaults(hours : Int, mins : Int)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
    
        defaults.setInteger(hours, forKey: hoursKey)
        defaults.setInteger(mins, forKey: minutesKey)
        
        NSLog("Set defaults: Alarm hour is \(hours)  minutes \(mins)")
    }
    
    @IBAction func changeBrightness(sender: UISlider)
    {
        NSLog("Current slider value: \(sender.value)")
        
    }
    
}
