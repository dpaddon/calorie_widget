//
//  GetValuesBySortedKeys.swift
//  calorie_widget_targetExtension
//
//  Created by Daniel Paddon on 11/07/2020.
//

import Foundation


public func GetValuesBySortedKeys(dict: Dictionary<Date,Int>) -> [Int] {
    let sortedKeys = dict.keys.sorted()
    var sortedValues:[Int] = []

    for key in sortedKeys {
        sortedValues.append(dict[key]!)
    }
    
    return sortedValues
}
