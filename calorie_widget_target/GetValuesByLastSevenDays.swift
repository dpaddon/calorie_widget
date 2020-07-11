//
//  GetValuesBySortedKeys.swift
//  calorie_widget_targetExtension
//
//  Created by Daniel Paddon on 11/07/2020.
//

import Foundation


public func GetValuesByLastSevenDays(dict: Dictionary<Date,Int>) -> [Int] {
    let cal = NSCalendar.current
    var date = NSDate()

    var dateComponents = cal.dateComponents([.day , .month , .year, .weekday], from: NSDate() as Date)
    
    date = cal.date(from: dateComponents) as! NSDate
    
    var days = [NSDate]()

    for _ in 1 ... 7 {
        // get day component:
//        let day = cal.dateComponents([.day], from: date as Date)
        
        days.append(date)

        // move back in time by one day:
        date = cal.date(byAdding: .day, value: -1, to: date as Date)! as NSDate
    }

    print("Dict keys: ", dict.keys)
    print("Days: ", days)
    
    var sortedValues:[Int] = []

    for day in days {
        sortedValues.append(dict[day as Date] ?? 0)
    }
    
    return sortedValues
}
