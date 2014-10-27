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
    
    let alarmKey = "alarmTime"
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        screenBrightness?.value = Float(UIScreen.mainScreen().brightness)
        
        // see if we have an awake time already set
        timePicker?.addTarget(self, action: Selector("timePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        updateAlarmPickerWithUserDefaults()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // for now, just blindly update alarm time
        defaults.setObject(timePicker!.date, forKey: alarmKey)
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
        if let alarm = defaults.objectForKey(alarmKey) as? NSDate {
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
