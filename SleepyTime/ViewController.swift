//
//  ViewController.swift
//  SleepyTime
//
//  Created by James Lorenzo on 10/22/14.
//  Copyright (c) 2014 James Lorenzo. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate {
    
    var timer = NSTimer()
    var scaleFactor = 1.0 as CGFloat;
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var settingsButton: UIButton?
    @IBOutlet var minorStars: Array<UIImageView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        // no need to draw battery power here
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        // parse the location
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as CLLocation
        var coord = locationObj.coordinate
        // determine sunrise/sunset for this location
        var tz = NSTimeZone.localTimeZone()
        EDSunriseSet.sunrisesetWithTimezone(tz, latitude: coord.latitude, longitude: coord.longitude)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
    }
    
    func showSettingsPopup() {
        var alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func showSettings() {
        let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("settings") as SettingsController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSizeMake(400,400)
        popover?.delegate = self
        popover?.sourceView = self.view
        popover?.sourceRect = self.settingsButton!.frame
        self.presentViewController(nav, animated: true, completion: nil)        
    }
    
    @IBAction func startTimer(sender : UIButton!) {
        if(sender.selected)
        {
            stopTimer()
        }
        else
        {
            startTimer()
        }
        sender.selected = !sender.selected
    }
    
    func startTimer()
    {
        NSLog("Starting timer");
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
    }
    
    func updateTimer()
    {
        NSLog("Timer has fired");
        updateImages()
    }
    
    func stopTimer()
    {
        NSLog("Stopping timer")
        timer.invalidate()
    }
    
    func updateImages()
    {
        NSLog("Star count: \(self.minorStars?.count)")
        for minorStar in self.minorStars! {
            if minorStar.hidden == false {
                let centerPoint = minorStar.center
                // rotate and scale the star
                UIView.animateWithDuration(2.5, animations: {
                    let transScale = 0.75/self.scaleFactor * 0.8
                    let rotation = 360 * self.scaleFactor
                    let rotate = CGAffineTransformMakeRotation(rotation)
                    let scale = CGAffineTransformMakeScale(transScale, transScale)
                    minorStar.transform = CGAffineTransformConcat(rotate, scale)
                    minorStar.center = centerPoint
                    }, completion: {
                        (Bool) in
                        self.scaleFactor++
                        if self.scaleFactor == 5.0 {
                            self.scaleFactor = 1.0
                            
                            UIView.animateWithDuration(1.0,
                                animations: {
                                    minorStar.alpha = 0.0
                                },
                                completion: { finished in
                                    minorStar.hidden = true
                            })
                        }
                })
                return
            }
        }
    }

}

