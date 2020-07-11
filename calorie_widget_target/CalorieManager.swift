//
//  CalorieManager.swift
//  calorie_widget
//
//  Created by Daniel Paddon on 05/07/2020.
//

import Foundation
import HealthKit
import Combine


class CalorieManager: NSObject, ObservableObject {
    
    let healthStore = MyHealthStore()
    
    var activeCaloriesBurned = 0
    var basalCaloriesBurned = 0
    var totalCaloriesBurned = 0
    var burnedCalorieOutput = BurnedCalorieCount(active: 0, resting: 0, total: 0)
    
    var weeklyActiveCalsDict: [Date:Int] = [:]
    var weeklyRestingCalsDict: [Date:Int] = [:]
    
    var weeklyActiveCalsSortedList: [Int] = []
    var weeklyRestingCalsSortedList: [Int] = []
    var weeklyTotalCalsSortedList: [Int] = []
    
    
    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // Requesting authorization.
        /// - Tag: RequestAuthorization
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        // The quantity types to read from the health store.
        let typesToRead: Set = [
//            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!
        ]
        
        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            // Handle error.
            print("Auth request failed")
        }
    }
    
    public func fetch() -> Void {
        
        guard let activeQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned) else {
            fatalError("*** Unable to create an activeEnergyBurned type ***")
        }
        guard let basalQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned) else {
            fatalError("*** Unable to create an activeEnergyBurned type ***")
        }
        
        // Get the active calories
        healthStore.TodayCalories(quantityType: activeQuantityType, completion: { todayCalories, error -> Void in
            if let todayCalories = todayCalories {
                self.activeCaloriesBurned = Int(todayCalories)
            }
        })
        
        // Get the resting/basal calories
        healthStore.TodayCalories(quantityType: basalQuantityType, completion: { todayCalories, error -> Void in
            if let todayCalories = todayCalories {
                self.basalCaloriesBurned = Int(todayCalories)
            }
        })
        
        // Add 'em up
        self.totalCaloriesBurned = self.activeCaloriesBurned + self.basalCaloriesBurned
        
        // Fire 'em out
        print("Assigning self.burnedCalorieOutput")
        self.burnedCalorieOutput = BurnedCalorieCount(active: self.activeCaloriesBurned,
                                                      resting: self.basalCaloriesBurned,
                                                      total: self.totalCaloriesBurned)
        
        // Get the summary stats for the week
        
        // Active calories
        healthStore.getWeekCalsByDay(quantityType: activeQuantityType, completion: {weeklyCalOutput, error -> Void in
            if let weeklyCalOutput = weeklyCalOutput {
                self.weeklyActiveCalsDict = weeklyCalOutput
            }
        })

        // Resting calories
        healthStore.getWeekCalsByDay(quantityType: basalQuantityType, completion: {weeklyCalOutput, error -> Void in
            if let weeklyCalOutput = weeklyCalOutput {
                self.weeklyRestingCalsDict = weeklyCalOutput
            }
        })
        
        self.weeklyActiveCalsSortedList = GetValuesBySortedKeys(dict: self.weeklyActiveCalsDict)
        self.weeklyRestingCalsSortedList = GetValuesBySortedKeys(dict: self.weeklyRestingCalsDict)
        
        self.weeklyTotalCalsSortedList = zip(self.weeklyActiveCalsSortedList,self.weeklyRestingCalsSortedList).map(+)
        
        self.weeklyRestingCalsSortedList = ScaleWeeklyCals(arr: self.weeklyRestingCalsSortedList)
        
        
    }
    

    
    
}
