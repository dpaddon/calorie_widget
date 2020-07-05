//
//  ContentView.swift
//  calorie_widget
//
//  Created by Daniel Paddon on 26/06/2020.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var calorieSession: CalorieManager

    var body: some View {
        Text("Welcome to Calorie Manager!")
            .padding()
            .onAppear {
                // Request HealthKit store authorization.
                print("App launched")
                print("App triggering auth request")
                self.calorieSession.requestAuthorization()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CalorieManager())
    }
    
}
