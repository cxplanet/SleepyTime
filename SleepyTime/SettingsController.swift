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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        screenBrightness?.value = Float(UIScreen.mainScreen().brightness)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeBrightness(sender: UISlider)
    {
        NSLog("Current slider value: \(sender.value)")
    }
    
}
