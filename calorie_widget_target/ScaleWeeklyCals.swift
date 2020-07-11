//
//  ScaleWeeklyCals.swift
//  Calorie Widget
//
//  Created by Daniel Paddon on 11/07/2020.
//

import Foundation

public func ScaleWeeklyCals(arr: [Int]) -> [Int] {
    let maxBarHeight = 35 * 0.9 // We want the highest val this week to display as 95% of the max bar height
    let maxCals = arr.max() ?? 2500
    let scale = maxBarHeight / Double(maxCals)
    
    var scaledArr = arr
    
    for i in 0..<arr.count {
        scaledArr[i] = Int(Double(arr[i]) * scale)
        }
    
    return scaledArr
}
