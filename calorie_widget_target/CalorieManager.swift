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
    
    public func fetch() -> BurnedCalorieCount {
        var cals_output = BurnedCalorieCount(active: 1, resting: 2, total: 42)
        var activeCals=0
        
        healthStore.TodayTotalActiveCalories { (activeCaloriesRetrieved) in
            activeCals = Int(activeCaloriesRetrieved)
        }

        let restingCals = 5
        let totalCals = activeCals + restingCals
        
        cals_output = BurnedCalorieCount(active: activeCals, resting: restingCals, total: totalCals)
        
        return cals_output
    }
    
    
    
}
