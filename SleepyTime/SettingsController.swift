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
    
    var defaults = NSUserDefaults.standardUserDefaults()
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
        self.view.backgroundColor = SleepyTimeUtils.colorize(0x5c9bb6)
        self.view.superview?.layer.cornerRadius = 32
        self.view.superview?.layer.masksToBounds = true
        self.doneButton?.layer.cornerRadius = 8
        self.doneButton?.layer.masksToBounds = true
    }
    
    override func viewWillDisappear(animated: Bool) {

        super.viewWillDisappear(animated)
    }
    
    @IBAction func dismissDialog()
    {
        var hasChanged = true
        // see if the alarm time has changed. If so, tell the app to restart its timer
        let alarmTime = timePicker!.date
        if let prevAlarmTime = defaults.objectForKey(Constants.alarmTime) as? NSDate
        {
            hasChanged = !alarmTime.isEqualToDate(prevAlarmTime)
        }
        if hasChanged
        {
            defaults.setObject(alarmTime, forKey: Constants.alarmTime)
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.RestartTimerNotification, object: nil)
        }
        
        defaults.setObject(screenBrightness!.value, forKey: Constants.screenBrightness)
        self.dismissViewControllerAnimated(true, completion: nil)
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
