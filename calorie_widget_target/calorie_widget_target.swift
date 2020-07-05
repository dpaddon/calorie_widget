//
//  calorie_widget_target.swift
//  calorie_widget_target
//
//  Created by Daniel Paddon on 26/06/2020.
//

import WidgetKit
import SwiftUI
import HealthKit



// This is the bit which actually creates the timeline
// This has 2 methods we need to implement - snapshot() and timeline()
struct Provider: TimelineProvider {
    public typealias Entry = SimpleEntry
    
//    @EnvironmentObject var calorieSession: CalorieManager
    let calorieSession = CalorieManager()

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
            print("Fetching calories")
            // Get burned calories
            calorieSession.fetch()
            burned_calories = calorieSession.cals_output
            print("Fetched calories...")
            print(burned_calories)
        } else {
            print("Health kit not available")
            burned_calories = BurnedCalorieCount(active: 0, resting: 0, total: 0)
        }
        
        
        let entry = SimpleEntry(date: currentDate, burnedCalories: burned_calories)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
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

