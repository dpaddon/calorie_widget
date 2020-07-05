//
//  MyHealthStore.swift
//  calorie_widget
//
//  Created by Daniel Paddon on 05/07/2020.
//

import Foundation
import HealthKit


class MyHealthStore: HKHealthStore {
    func TodayTotalActiveCalories(completion: @escaping (_ activeCaloriesRetrieved: Double) -> Void) {

        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned) else {
            fatalError("*** Unable to create an activeEnergyBurned type ***")
        }

        let calendar = NSCalendar.current
        let interval = NSDateComponents()
        interval.day = 1

        var anchorComponents = calendar.dateComponents([.day , .month , .year], from: NSDate() as Date)
        anchorComponents.hour = 0
        
        guard let anchorDate = calendar.date(from: anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }

        let ActiveCaloriesQuery = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval as DateComponents)
        
        ActiveCaloriesQuery.initialResultsHandler = {query, results, error in
            let endDate = NSDate()

            var totalActiveCalories = 0.0
            let startDate = calendar.date(byAdding: .day, value: 0, to: endDate as Date)
            if let myResults = results{  myResults.enumerateStatistics(from: startDate!, to: endDate as Date) { statistics, stop in
                if let quantity = statistics.sumQuantity(){
                    //let date = statistics.startDate
                    totalActiveCalories = quantity.doubleValue(for: HKUnit.count())
                   // print("\(date): ActiveCalories = \(ActiveCalories)")
                }

                //completion(activeCaloriesRetrieved: totalActiveCalories)

                }
            } else {
                // mostly not executed
                completion(totalActiveCalories)
            }
        }
        execute(ActiveCaloriesQuery)
    }
}
