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
    
    // for a given time, calculate the datetime. Assume that if the alarm ti
    static func calcTimeToAlarm(currTime: NSDate, alarmHour: Int, alarmMinutes: Int) -> (NSDate)
    {
        let (hours, mins) = minutesAndHours(currTime)
        // XXX need to edge case the set alam at 1 for 6 wakeup
        let hoursForward = (23 - hours) + alarmHour
        let minsForward = (60 - mins) + alarmMinutes
        let timeForward = Double(hoursForward * 60 * 60 + minsForward * 60)
        
        return currTime.dateByAddingTimeInterval(timeForward)
    }
    
    static func stringFromDate(convertDate: NSDate) -> (String)
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm:ss zzz"
        let dateString = formatter.stringFromDate(convertDate)
        
        return dateString
    }

}
