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
    var visibleStars = Array<UIImageView>()
    var currStarScale: CGFloat = 1.0
    
    //let sunSlices = 5.0
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var isTimerRunning = false
    
    var alarmTime: NSDate?
    
    @IBOutlet weak var moonImage: UIImageView?
    @IBOutlet weak var sunImage: UIImageView?
    @IBOutlet weak var settingsButton: UIButton?
    @IBOutlet weak var restartButton: UIButton?
    @IBOutlet weak var countDown: UILabel!
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
        if let alarmTime = defaults.objectForKey(Constants.alarmTime) as? NSDate {
            startAlarmCountdown()
        } else // its a reset data, or first open
        {
            showSettings()
        }
    }
    
    @IBAction func dismissSettings(sender: UIButton!) {
        self.dismissViewControllerAnimated(true, completion: {
            if self.isTimerRunning {
                self.stopTimer()
            }
            self.startAlarmCountdown()
        })
    }
    
    @IBAction func showSettings() {
        let settings = self.storyboard?.instantiateViewControllerWithIdentifier("settings") as SettingsController
        settings.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        settings.modalTransitionStyle = .CrossDissolve
        settings.view.backgroundColor = self.colorize(0x5c9bb6)
        settings.doneButton!.addTarget(self, action: "dismissSettings:", forControlEvents: .TouchUpInside)
        self.presentViewController(settings, animated: true, completion: nil)
    }
    
    func startAlarmCountdown()
    {
        let lastAlarm = defaults.objectForKey(Constants.alarmTime) as NSDate?
        self.alarmTime = DateTimeUtils.calcAlarmTime(lastAlarm!)
        initStarVisibility(alarmTime!, stars: minorStars!)
        startTimer()
    }
    
    func showSleepTime()
    {
        
        UIView.animateWithDuration(1.5, animations: {
            self.view.backgroundColor = self.colorize(0x022937)
            self.moonImage?.alpha = 1.0
            self.sunImage?.alpha = 0.0
            self.restartButton?.alpha = 0.0
            }, completion: {
                (Bool) in
                self.restartButton!.hidden = true
        })
    }
    
    func showWakeTime()
    {
        self.sunImage?.hidden = false;
        self.restartButton?.hidden = false
        UIView.animateWithDuration(1.5, animations: {
            self.view.backgroundColor = self.colorize(0x5c9bb6)
            self.moonImage?.alpha = 0.0
            self.sunImage?.alpha = 1.0
            self.restartButton?.alpha = 1.0
            }, completion: {
                (Bool) in
                
        })
    }
    
    @IBAction func resetAlarm(sender : UIButton!) {
        showSleepTime()
        resetImages()
    }
    
    func startTimer()
    {
        NSLog("Starting timer");
        timer = NSTimer.scheduledTimerWithTimeInterval(1 * 10, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    func updateTimer()
    {
        if visibleStars.count > 0 {
            let (hours, mins) = DateTimeUtils.minutesAndHoursToEnd(alarmTime!)
            
            let countdown = ("Time left: \(hours):\(mins)")
            countDown.text = countdown
            if let star = visibleStars[0] as UIImageView? {
                self.scaleImage(star, hour:hours, minute:mins)
            }
        }
    }
    
    func stopTimer()
    {
        NSLog("Stopping timer")
        timer.invalidate()
    }
    
    func scaleImage(minorStar: UIImageView, hour: Int, minute: Int)
    {
        let transScale = self.imageScaleFactor(minute)
        if currStarScale > transScale
        {
            currStarScale = transScale
            let centerPoint = minorStar.center
            // rotate and scale the star
            UIView.animateWithDuration(1.5, animations: {

                let rotation = 360 * self.scaleFactor
                let rotate = CGAffineTransformMakeRotation(rotation)
                let scale = CGAffineTransformMakeScale(transScale, transScale)
                minorStar.transform = CGAffineTransformConcat(rotate, scale)
                minorStar.center = centerPoint
                }, completion: {
                    (Bool) in
                    self.scaleFactor++
                    if transScale == 0.005 {
                        
                        self.removeStar(minorStar)// restore the scale factor
                        self.scaleFactor = 1.0
                        self.currStarScale = 1.0 // XXX this is a race condition
                    }
            })
        }

    }
    
//    func updateImages()
//    {
//        // short term hack to determine if we are done. We may want to programmatically
//        // add the star creation to an array, and pop them off as the become invisible
//        var hasVisibileStar = false
//        for minorStar in self.minorStars! {
//            if minorStar.hidden == false {
//                hasVisibileStar = true
//                let centerPoint = minorStar.center
//                // rotate and scale the star
//                UIView.animateWithDuration(1.5, animations: {
//                //UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{
//                    let transScale = self.imageScaleFactor(self.scaleFactor)
//                    let rotation = 360 * self.scaleFactor
//                    let rotate = CGAffineTransformMakeRotation(rotation)
//                    let scale = CGAffineTransformMakeScale(transScale, transScale)
//                    minorStar
//                    minorStar.transform = CGAffineTransformConcat(rotate, scale)
//                    minorStar.center = centerPoint
//                    }, completion: {
//                        (Bool) in
//                        self.scaleFactor++
//                        if self.scaleFactor > 4.0 {
//                            
//                            UIView.animateWithDuration(0.5,
//                                animations: {
//                                    minorStar.alpha = 0.0
//                                },
//                                completion: { finished in
//                                    minorStar.hidden = true
//                            })
//                            
//                            // restore the scale factor
//                            self.scaleFactor = 1.0
//                        }
//                })
//                return
//            }
//        }
//        if hasVisibileStar == false {
//            showWakeTime()
//        }
//    }
    
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
    
    func imageScaleFactor(minutes: Int) -> CGFloat
    {
        var cgScaleFactor: CGFloat = 1.0
        
        if minutes < 2 {
            cgScaleFactor = 0.005
        }
        else if minutes < 10 {
            cgScaleFactor = 0.25
        }
        else if minutes < 20 {
            cgScaleFactor = 0.40
        }
        else if minutes < 30 {
            cgScaleFactor = 0.55
        }
        else if minutes < 40 {
            cgScaleFactor = 0.70
        }
        else if minutes < 50 {
            cgScaleFactor = 0.85
        }
        else if minutes < 60 {
            cgScaleFactor = 1.0
        }

        return cgScaleFactor
    }
    
    func initStarVisibility(alarmTime: NSDate, stars: Array<UIImageView>)
    {
        visibleStars.removeAll(keepCapacity: true)
        
        for star in stars {
            visibleStars.append(star)
        }
        
        var (hours2Go, mins2Go) = DateTimeUtils.minutesAndHoursToEnd(alarmTime)
        hours2Go++
        
        // currently, we scale stars according to time - 1 star to 1 hour.
        while (hours2Go < visibleStars.count){
            if let star = visibleStars[0] as UIImageView?// in case of 0 length array
            {
                removeStar(star)
            }
        }
        // last, scale the remaining star accoring to the number of minutes left
        // in that hour
        let star = visibleStars[0]
            scaleImage(star, hour: hours2Go, minute: mins2Go)
    }
    
    func removeStar(star: UIImageView)
    {
        UIView.animateWithDuration(0.5,
            animations: {
                star.alpha = 0.0
            },
            completion: { finished in
                star.hidden = true
        })
        self.visibleStars.removeAtIndex(0)
        if visibleStars.count == 0 {
            showWakeTime()
        }
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

