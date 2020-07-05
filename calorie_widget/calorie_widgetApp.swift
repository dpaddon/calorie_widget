//
//  calorie_widgetApp.swift
//  calorie_widget
//
//  Created by Daniel Paddon on 26/06/2020.
//

import SwiftUI

@main
struct calorie_widgetApp: App {
    var calorieManager = CalorieManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(calorieManager)
        }
    }
    
}
