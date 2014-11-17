//
//  DateTimeUtils.swift
//  SleepyTime
//
//  Created by James Lorenzo on 11/13/14.
//  Copyright (c) 2014 James Lorenzo. All rights reserved.
//

import Foundation

struct DateTimeUtils
{
    static func minutesAndHours(date: NSDate) -> (hours: Int, minutes: Int)
    {
        let calendar = NSCalendar.currentCalendar();
        let hours = calendar.component(NSCalendarUnit.CalendarUnitHour, fromDate: date)
        let minutes = calendar.component(NSCalendarUnit.CalendarUnitMinute, fromDate: date)
        
        return (hours, minutes)
    }
    
//    // for a given time, calculate the datetime. Assume that if the alarm ti
//    static func calcTimeToAlarm(currTime: NSDate, alarmHour: Int, alarmMinutes: Int) -> (NSDate)
//    {
//        let (hours, mins) = minutesAndHours(currTime)
//        // XXX need to edge case the set alam at 1 for 6 wakeup
//        var hoursForward = (24 - hours) + alarmHour
//        if hoursForward >= 24 {
//            hoursForward = hoursForward%24
//        }
//        let minsForward = (60 - mins) + alarmMinutes
//        let timeForward = Double(hoursForward * 60 * 60 + minsForward * 60)
//        
//        return currTime.dateByAddingTimeInterval(timeForward)
//    }
    
    static func minutesAndHoursToEnd(endTime: NSDate) -> (hours: Int, minutes: Int)
    {
        let secondsToGo = endTime.timeIntervalSinceNow
        let hours = Int(floor(secondsToGo/3600))
        let minutes = Int(secondsToGo/60) - (hours * 60)
        
        return (hours, minutes)
    }
    
    static func stringFromDate(convertDate: NSDate) -> (String)
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm:ss zzz"
        let dateString = formatter.stringFromDate(convertDate)
        
        return dateString
    }
    
    // Best guess algorithm - if the alarm is in the past, push
    // it forward. If its the same day, let it be
    static func calcAlarmTime(currAlarmTime: NSDate) -> NSDate
    {
        var daysPast = 0
        let timeDelta = currAlarmTime.timeIntervalSinceNow
        // has it occured in the past
        if timeDelta < 0
        {
            daysPast = Int(abs(floor(timeDelta/(24*60*60))))
        }
        let timeInterval = Double(daysPast) * Constants.dayInSeconds
        return currAlarmTime.dateByAddingTimeInterval(timeInterval)
    }

}
