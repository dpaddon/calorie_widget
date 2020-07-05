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
//        var activeCals = 0
        
        healthStore.TodayTotalActiveCalories(completion: { totalActiveCalories, error -> Void in
            if let totalActiveCalories = totalActiveCalories {
                self.activeCaloriesBurned = Int(totalActiveCalories)
                self.basalCaloriesBurned = 0 // Get the basal calories here
                self.totalCaloriesBurned = self.activeCaloriesBurned + self.basalCaloriesBurned
                
                print("Assigning self.burnedCalorieOutput")
                self.burnedCalorieOutput = BurnedCalorieCount(active: self.activeCaloriesBurned,
                                                              resting: self.basalCaloriesBurned,
                                                              total: self.totalCaloriesBurned)
            }
        })
        

        
    }
    
    
    
}
