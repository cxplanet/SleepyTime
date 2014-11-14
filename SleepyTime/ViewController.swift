//
//  ViewController.swift
//  SleepyTime
//
//  Created by James Lorenzo on 10/22/14.
//  Copyright (c) 2014 James Lorenzo. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    var timer = NSTimer()
    var scaleFactor = 1.0 as CGFloat;
    let locationManager = CLLocationManager()
    
    let timerInterval = 2.0
    let sunSlices = 5.0
    let defaults = NSUserDefaults.standardUserDefaults()
    
    let alarmKey = "alarmTime"
    let dayInSeconds = 24 * 60 * 60
    
    @IBOutlet weak var moonImage: UIImageView?
    @IBOutlet weak var sunImage: UIImageView?
    @IBOutlet weak var settingsButton: UIButton?
    @IBOutlet var minorStars: Array<UIImageView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = colorize(0x022937)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let alarmHour = defaults.objectForKey(Constants.alarmHour) as? Int {
            startCountdown()
        } else // its a reset data, or first open
        {
            showInitialSettings()
        }
    }
    
    func showInitialSettings() {
        let settings = self.storyboard?.instantiateViewControllerWithIdentifier("settings") as SettingsController
        settings.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        settings.modalTransitionStyle = .CrossDissolve
        settings.view.backgroundColor = self.colorize(0x5c9bb6)
        settings.doneButton!.addTarget(self, action: "dismissSettings:", forControlEvents: .TouchUpInside)
        self.presentViewController(settings, animated: true, completion: nil)
    }
    
    @IBAction func dismissSettings(sender: UIButton!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        startCountdown()
    }
    
    func showSettingsPopup() {
        var alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func showSettings() {
        self.showInitialSettings()
    }
    
    func startCountdown()
    {
        let hour = defaults.objectForKey(Constants.alarmHour) as? Int
        let minute = defaults.objectForKey(Constants.alarmMinute) as? Int
        let now = NSDate()
        let alarmTime = DateTimeUtils.calcTimeToAlarm(now, alarmHour: hour!, alarmMinutes: minute!)
    }
    
    func showSleepTime()
    {
        UIView.animateWithDuration(1.5, animations: {
            self.view.backgroundColor = self.colorize(0x022937)
            self.moonImage?.alpha = 1.0
            self.sunImage?.alpha = 0.0
            }, completion: {
                (Bool) in
                self.moonImage!.hidden = true
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
    
    func calcAlarmTime()
    {
        let now = NSDate()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let alarmTime = defaults.objectForKey("alarmKey") as? NSDate
        {
            
            
        }
    }
    
    func startTimer()
    {
        NSLog("Starting timer");
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
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
                        if self.scaleFactor > 4.0 {
                            
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
    
    func shootingStar(starImg : UIImageView)
    {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 16,y: 239))
        path.addCurveToPoint(CGPoint(x: 301, y: 239), controlPoint1: CGPoint(x: 136, y: 373), controlPoint2: CGPoint(x: 178, y: 110))
        
        // create a new CAKeyframeAnimation that animates the objects position
        let anim = CAKeyframeAnimation(keyPath: "position")
        
        // set the animations path to our bezier curve
        anim.path = path.CGPath
        
        // set some more parameters for the animation
        // this rotation mode means that our object will rotate so that it's parallel to whatever point it is currently on the curve
        anim.rotationMode = kCAAnimationRotateAuto
        anim.repeatCount = Float.infinity
        anim.duration = 5.0
        
        // we add the animation to the squares 'layer' property
        starImg.layer.addAnimation(anim, forKey: "animate position along path")
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
        
        switch scaleSize
        {
        case 1.0:
            cgScaleFactor = 0.80
        case 2.0:
            cgScaleFactor = 0.50
        case 3.0:
            cgScaleFactor = 0.25
        case 4.0:
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
        // NSLog("Reset star count: \(self.minorStars?.count)")
        for minorStar in self.minorStars! {
            UIView.animateWithDuration(0.5, animations: {
                minorStar.transform = CGAffineTransformIdentity
                minorStar.alpha = alphaVal
                })
            minorStar.hidden = false
        }
    }
    
    
}

