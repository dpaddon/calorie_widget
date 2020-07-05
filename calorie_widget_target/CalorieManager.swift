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
    
    var cals_output = BurnedCalorieCount(active: 0, resting: 0, total: 0)
    
    public func fetch() -> Void {
        var activeCals = 0
        
        healthStore.TodayTotalActiveCalories(completion: { totalActiveCalories, error -> Void in
            if let totalActiveCalories = totalActiveCalories {
                activeCals = Int(totalActiveCalories)
                print("activeCals inside call: ", activeCals)
                let restingCals = 5
                let totalCals = activeCals + restingCals
                
                print("Assigning self.cals_output")
                self.cals_output = BurnedCalorieCount(active: activeCals, resting: restingCals, total: totalCals)
            }
        })
        

        
    }
    
    
    
}
