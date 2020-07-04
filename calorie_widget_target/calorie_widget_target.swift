//
//  calorie_widget_target.swift
//  calorie_widget_target
//
//  Created by Daniel Paddon on 26/06/2020.
//

import WidgetKit
import SwiftUI
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



// Utility function - this needs to get the calories using healthKit
// For now we will just hardcode them
struct BurnedCalorieLoader {
    let healthKitStore = MyHealthStore()
    
    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // Requesting authorization.
        /// - Tag: RequestAuthorization
        // The quantity types to read from the health store.
        let typesToWrite: Set = [
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        ]
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        ]
        
        // Request authorization for those quantity types.
        healthKitStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { (success, error) in
            // Handle error.
            print("Failed while requesting authorisation")
        }
        return
    }
    
    func fetch() -> BurnedCalorieCount {
        var activeCals=0
        
        self.healthKitStore.TodayTotalActiveCalories { (activeCaloriesRetrieved) in
            activeCals = Int(activeCaloriesRetrieved)
        }

        let restingCals = 5
        let totalCals = activeCals + restingCals
        
        let cals_output = BurnedCalorieCount(active: activeCals, resting: restingCals, total: totalCals)
        
        return cals_output
    }
    
}


// This is the bit which actually creates the timeline
// This has 2 methods we need to implement - snapshot() and timeline()
struct Provider: TimelineProvider {
    public typealias Entry = SimpleEntry
    
    let burnedCalorieLoader = BurnedCalorieLoader()

    public func snapshot(with context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let burned_calories = BurnedCalorieCount(active: 1, resting: 2, total: 3)
        let entry = SimpleEntry(date: Date(), burnedCalories: burned_calories)
        completion(entry)
    }

    public func timeline(with context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        var burned_calories = BurnedCalorieCount(active: 1, resting: 2, total: 3)
        // Refresh every 5 mins
        let refreshDate = Calendar.current.date(byAdding: .second, value: 10, to: currentDate)!

        print("Checking authorisation")
        // Get authorised:
        if MyHealthStore.isHealthDataAvailable() {
            print("Requesting authorisation")
            burnedCalorieLoader.requestAuthorization()
            print("Fetching calories")
            // Get burned calories
            burned_calories = burnedCalorieLoader.fetch()
        } else {
            print("Health kit not available")
            burned_calories = BurnedCalorieCount(active: 0, resting: 0, total: 0)
        }
        
        
        let entry = SimpleEntry(date: currentDate, burnedCalories: burned_calories)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}

// This struct holds the calories to display
struct BurnedCalorieCount {
    let active: Int
    let resting: Int
    let total: Int
}

// This bit is what controls what gets loaded when
struct SimpleEntry: TimelineEntry {
    public let date: Date
    public let burnedCalories: BurnedCalorieCount
}

// This is the placeholder which gets displayed in the widget picker
struct PlaceholderView : View {
    var body: some View {
        Text("Loading calories...")
    }
}

// This view defines how the widget looks
struct calorie_widget_targetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(String(entry.burnedCalories.total)) kcal")
                .font(.system(.callout))
                .foregroundColor(.white)
                .bold()
            Text("burned so far today \(Self.format(date:entry.date))")
                .font(.system(.caption))
                .foregroundColor(.white)
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.yellow, .red]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    static func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
}


// Main
@main
struct calorie_widget_target: Widget {
    private let kind: String = "calorie_widget_target"

    public var body: some WidgetConfiguration {
        // StaticConfiguration means there is no customisation available
        // We will need to change this to add the option to include calories consumed too
        StaticConfiguration(kind: kind, provider: Provider(), placeholder: PlaceholderView()) { entry in
            calorie_widget_targetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's calories")
        .description("Shows the total number of calories you've burned today")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}


struct calorie_widget_target_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            calorie_widget_targetEntryView(entry: SimpleEntry(date: Date(), burnedCalories: BurnedCalorieCount(active: 1, resting: 2, total: 3)))
                .previewContext(WidgetPreviewContext(family:
                    .systemSmall))
            
            PlaceholderView()
                .previewContext(WidgetPreviewContext(family:
                    .systemSmall))
        }
    }
}

