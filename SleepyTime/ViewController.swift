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
    
    let timerInterval = 2.0
    let sunSlices = 5.0
    
    @IBOutlet weak var moonImage: UIImageView?
    @IBOutlet weak var sunImage: UIImageView?
    @IBOutlet weak var settingsButton: UIButton?
    @IBOutlet var minorStars: Array<UIImageView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        // no need to draw battery power here
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.view.backgroundColor = colorize(0x022937)
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
    
    func showSleepTime()
    {
        UIView.animateWithDuration(1.5, animations: {
            self.view.backgroundColor = self.colorize(0x022937)
            self.moonImage?.alpha = 1.0
            self.sunImage?.alpha = 0.0
            }, completion: {
                (Bool) in
                //self.moonImage?.hidden = true
        })
    }
    
    func showWakeTime()
    {
        self.sunImage?.hidden = false;
        UIView.animateWithDuration(1.5, animations: {
            self.view.backgroundColor = self.colorize(0x5c9bb6)
            self.moonImage?.alpha = 0.0
            self.sunImage?.alpha = 1.0
            }, completion: {
                (Bool) in
                
        })
    }
    
    @IBAction func toggleTimer(sender : UIButton!) {
        if(sender.selected)
        {
            stopTimer()
            resetImages()
        }
        else
        {
            showSleepTime()
            startTimer()
        }
        sender.selected = !sender.selected
    }
    
    @IBAction func toggleWakeup(sender : UIButton!) {
        if(sender.selected)
        {
            resetImages()
            showSleepTime()
        }
        else
        {
            
            showWakeTime()
        }
        sender.selected = !sender.selected
    }
    
    func startTimer()
    {
        NSLog("Starting timer");
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
    }
    
    func updateTimer()
    {
        updateImages()
    }
    
    func stopTimer()
    {
        NSLog("Stopping timer")
        timer.invalidate()
    }
    
    func updateImages()
    {
        // short term hack to determine if we are done. We may want to programmatically
        // add the star creation to an array, and pop them off as the become invisible
        var hasVisibileStar = false
        for minorStar in self.minorStars! {
            if minorStar.hidden == false {
                hasVisibileStar = true
                let centerPoint = minorStar.center
                // rotate and scale the star
                UIView.animateWithDuration(1.5, animations: {
                //UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{
                    let transScale = self.imageScaleFactor(self.scaleFactor)
                    let rotation = 360 * self.scaleFactor
                    let rotate = CGAffineTransformMakeRotation(rotation)
                    let scale = CGAffineTransformMakeScale(transScale, transScale)
                    minorStar.transform = CGAffineTransformConcat(rotate, scale)
                    minorStar.center = centerPoint
                    }, completion: {
                        (Bool) in
                        self.scaleFactor++
                        if self.scaleFactor > 2.0 {
                            
                            UIView.animateWithDuration(0.5,
                                animations: {
                                    minorStar.alpha = 0.0
                                },
                                completion: { finished in
                                    minorStar.hidden = true
                            })
                            
                            // restore the scale factor
                            self.scaleFactor = 1.0
                        }
                })
                return
            }
        }
        if hasVisibileStar == false {
            showWakeTime()
        }
    }
    
    // colorize function takes HEX and Alpha converts then returns aUIColor object
    func colorize (hex: Int, alpha: Double = 1.0) -> UIColor {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0xFF00) >> 8) / 255.0
        let blue = Double((hex & 0xFF)) / 255.0
        var color: UIColor = UIColor( red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha) )
        return color
    }
    
    func imageScaleFactor(scaleSize : CGFloat) -> CGFloat
    {
        var cgScaleFactor : CGFloat
        
        switch scaleFactor
        {
        case 1.0:
            cgScaleFactor = 0.8
        case 2.0:
            cgScaleFactor = 0.6
        case 3.0:
            cgScaleFactor = 0.4
        case 4.0:
            cgScaleFactor = 0.2
        case 5.0:
            cgScaleFactor = 0.005
        default:
            cgScaleFactor = 1.0
        }
        return cgScaleFactor
    }
    
    func resetImages(showAll : Bool = true)
    {
        let alphaVal : CGFloat = showAll ? 1.0 : 0.0
        showSleepTime()
        NSLog("Reset star count: \(self.minorStars?.count)")
        for minorStar in self.minorStars! {
            UIView.animateWithDuration(0.5, animations: {
                minorStar.transform = CGAffineTransformIdentity
                minorStar.alpha = alphaVal
                })
            minorStar.hidden = false
        }
    }
    
    
}

