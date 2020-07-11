//
//  MyHealthStore.swift
//  calorie_widget
//
//  Created by Daniel Paddon on 05/07/2020.
//

import Foundation
import HealthKit


class MyHealthStore: HKHealthStore {
    func TodayCalories(quantityType: HKQuantityType, completion: @escaping (_ todayCalories: Double?,Error?) -> Void) {

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
                    totalActiveCalories = quantity.doubleValue(for: HKUnit.kilocalorie())
                    print("Total active calories: ", totalActiveCalories)
                   // print("\(date): ActiveCalories = \(ActiveCalories)")
                }
                completion(totalActiveCalories, nil)
                }
            } else {
                // mostly not executed
//                completion(totalActiveCalories)
            }
        }
        execute(ActiveCaloriesQuery)
    }
    
    public func getWeekCalsByDay(quantityType: HKQuantityType, completion: @escaping (_ weeklyCalOutput: Dictionary<Date,Int>?,Error?) -> Void) {
        var weeklyCalOutput: [Date: Int] = [:]
        let calendar = NSCalendar.current
         
        let interval = NSDateComponents()
        interval.day = 1
         
        // Set the anchor date to today at midnight
        var anchorComponents = calendar.dateComponents([.day , .month , .year, .weekday, .hour], from: NSDate() as Date)
        anchorComponents.hour! = 0
         
        guard let anchorDate = calendar.date(from: anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
         
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval as DateComponents)
         
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                // Perform proper error handling here
                fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
            }
            
            let endDate = NSDate()
            
            guard let startDate = calendar.date(byAdding: .day, value: -7, to: anchorDate as Date) else {
                fatalError("*** Unable to calculate the start date ***")
            }
            
            // Plot the weekly step counts over the past 3 months
            statsCollection.enumerateStatistics(from: startDate, to: endDate as Date) { [unowned self] statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.kilocalorie())
                    
                    // Save the value in our output dict
                    weeklyCalOutput[date]=Int(value)
                }
            }
            
            completion(weeklyCalOutput, nil)
        }
         
        execute(query)
    }
    
}
