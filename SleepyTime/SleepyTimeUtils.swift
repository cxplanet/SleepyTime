//
//  SleepyTileUtils.swift
//  SleepyTime
//
//  Created by James Lorenzo on 11/24/14.
//  Copyright (c) 2014 James Lorenzo. All rights reserved.
//

import Foundation
import UIKit

struct SleepyTimeUtils
{
    // colorize function takes HEX and Alpha converts then returns aUIColor object
    static func colorize (hex: Int, alpha: Double = 1.0) -> UIColor {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0xFF00) >> 8) / 255.0
        let blue = Double((hex & 0xFF)) / 255.0
        var color: UIColor = UIColor( red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha) )
        return color
    }
}
