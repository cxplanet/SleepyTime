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
    @IBOutlet weak var doneButton: UIButton?
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var timeChanged: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        screenBrightness?.value = Float(UIScreen.mainScreen().brightness)
        
        //timePicker?.addTarget(self, action: Selector("timePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        updateAlarmPickerWithUserDefaults()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timeChanged = false
        // need to clip from the superview
        self.view.superview!.layer.cornerRadius = 32
        self.view.superview!.layer.masksToBounds = true
        self.doneButton!.layer.cornerRadius = 8
        self.doneButton!.layer.masksToBounds = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        let alarmTime = timePicker!.date
        let calendar = NSCalendar.currentCalendar();
        let hours = calendar.component(NSCalendarUnit.CalendarUnitHour, fromDate: alarmTime)
        let minutes = calendar.component(NSCalendarUnit.CalendarUnitMinute, fromDate: alarmTime)
        defaults.setObject(hours, forKey: Constants.alarmHour)
        defaults.setObject(minutes, forKey: Constants.alarmMinute)
        defaults.setObject(alarmTime, forKey: Constants.alarmTime)
        defaults.setObject(screenBrightness!.value, forKey: Constants.screenBrightness)
        super.viewWillDisappear(animated)
    }
    
    func timePickerChanged(datePicker:UIDatePicker) {
        // nothing to do yet
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateAlarmPickerWithUserDefaults()
    {
        if let alarm = defaults.objectForKey(Constants.alarmTime) as? NSDate {
            timePicker?.setDate(alarm, animated: false)
        }
    }
    
    
    @IBAction func changeBrightness(sender: UISlider)
    {
        NSLog("Current slider value: \(sender.value)")
        let mainScreen = UIScreen.mainScreen()
        mainScreen.brightness = CGFloat(sender.value)
    }
    
}
