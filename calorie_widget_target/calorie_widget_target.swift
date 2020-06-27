//
//  calorie_widget_target.swift
//  calorie_widget_target
//
//  Created by Daniel Paddon on 26/06/2020.
//

import WidgetKit
import SwiftUI


// Utility function - this needs to get the calories using healthKit
// For now we will just hardcode them
struct BurnedCalorieLoader {
    static func fetch() -> BurnedCalorieCount {
        let activeCals = 4
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

    public func snapshot(with context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let burned_calories = BurnedCalorieCount(active: 1, resting: 2, total: 3)
        let entry = SimpleEntry(date: Date(), burnedCalories: burned_calories)
        completion(entry)
    }

    public func timeline(with context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        // Refresh every 5 mins
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!

        // Get burned calories
        let burned_calories = BurnedCalorieLoader.fetch()
        
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
                .foregroundColor(.black)
                .bold()
            Text("burned so far today \(Self.format(date:entry.date))")
                .font(.system(.caption))
                .foregroundColor(.black)
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .top, endPoint: .bottom))
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

