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
    
    let iosVersion = NSString(string: UIDevice.currentDevice().systemVersion).doubleValue
    
    @IBOutlet weak var moonImage: UIImageView?
    @IBOutlet weak var sunImage: UIImageView?
    @IBOutlet weak var settingsButton: UIButton?
    @IBOutlet weak var restartButton: UIButton?
    @IBOutlet weak var countDownLbl: UILabel?
    @IBOutlet var minorStars: Array<UIImageView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = SleepyTimeUtils.colorize(0x022937)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("restartTimer"),
            name: Constants.RestartTimerNotification, object: nil)
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
            settingsButton?.sendActionsForControlEvents(.TouchUpInside)
        }
    }
    
    @IBAction func dismissSettings(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {
            self.restartTimer()
        })
    }
    
    func restartTimer()
    {
        if self.isTimerRunning {
            self.stopTimer()
        }
        self.startAlarmCountdown()
    }
    
    @IBAction func showSettings() {
        let settings = self.storyboard?.instantiateViewControllerWithIdentifier("settings") as SettingsController
        if (iosVersion >= 8.0){
            
            settings.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        }
        else{
            self.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        }
        settings.modalTransitionStyle = .CrossDissolve
        settings.view.backgroundColor = SleepyTimeUtils.colorize(0x5c9bb6)
        settings.doneButton?.addTarget(self, action: "dismissSettings:", forControlEvents: .TouchUpInside)
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
            self.view.backgroundColor = SleepyTimeUtils.colorize(0x022937)
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
            self.view.backgroundColor = SleepyTimeUtils.colorize(0x5c9bb6)
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
        NSLog("Starting timer")
        timer = NSTimer.scheduledTimerWithTimeInterval(1 * 10, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    func updateTimer()
    {
        if visibleStars.count > 0 {
            let (hours, mins) = DateTimeUtils.minutesAndHoursToEnd(alarmTime!)
            
            updateTimerLabel(hours, mins: mins)
            
            if hours < visibleStars.count {
                if let star = visibleStars[0] as UIImageView? {
                    self.scaleImage(star, hour:hours, minute:mins)
                }
            }
        }
    }
    
    func updateTimerLabel(hours: Int, mins: Int)
    {
        let countdown = String(format:"Time left: %02d:%02d", hours, mins)
        countDownLbl!.text = countdown
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
        
        let (hours2Go, mins2Go) = DateTimeUtils.minutesAndHoursToEnd(alarmTime)
        updateTimerLabel(hours2Go, mins: mins2Go)
        
        // currently, we scale stars according to time - 1 star to 1 hour.
        if hours2Go < visibleStars.count {
            while (hours2Go < visibleStars.count - 1){
                if let star = visibleStars[0] as UIImageView?// in case of 0 length array
                {
                    removeStar(star)
                }
            }
            resetStars(visibleStars)
            // last, scale the remaining star accoring to the number of minutes left
            // in that hour
            let star = visibleStars[0]
                scaleImage(star, hour: hours2Go, minute: mins2Go)
        }
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
    
    func resetStars(stars: Array <UIImageView>)
    {
        NSLog("Reset star count: \(self.minorStars?.count)")
        for minorStar in stars {
            UIView.animateWithDuration(0.2, animations: {
                minorStar.alpha = 1.0
                minorStar.hidden = false
                minorStar.transform = CGAffineTransformIdentity
            })
        }
        currStarScale = 1
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if(segue.identifier == "showSetting"){
//            if (iosVersion >= 8.0){
//                
//                //Leave this blank if you have set presentation style to "over current context"
//                
//                
//            }
//            else{  self.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
//                
//                self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
//                
//            }
        }
    }
    
    
}

