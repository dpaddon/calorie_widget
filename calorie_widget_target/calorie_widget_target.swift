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
        let burned_calories = BurnedCalorieCount(active: 1, resting: 2, total: 1234)
        let entry = SimpleEntry(date: Date(), burnedCalories: burned_calories, sortedWeeklyCals: [1,2,3,4,5,6,7])
        completion(entry)
    }

    public func timeline(with context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        var burned_calories: BurnedCalorieCount
        // Refresh every 5 mins
        let refreshDate = Calendar.current.date(byAdding: .second, value: 10, to: currentDate)!

        print("Checking authorisation")
        // Get authorised:
        if MyHealthStore.isHealthDataAvailable() {
            print("Fetching calories")
            // Get burned calories
            calorieSession.fetch()
            burned_calories = calorieSession.burnedCalorieOutput
            print("Fetched calories...")
            print(burned_calories)
        } else {
            print("Health kit not available")
            burned_calories = BurnedCalorieCount(active: 0, resting: 0, total: 0)
        }
        
        // Get the sorted calories
        let sortedWeeklyCals = calorieSession.weeklyCalsSortedList
        
        
        let entry = SimpleEntry(date: currentDate,
                                burnedCalories: burned_calories,
                                sortedWeeklyCals: sortedWeeklyCals)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}


// This bit is what controls what gets loaded when
struct SimpleEntry: TimelineEntry {
    public let date: Date
    public let burnedCalories: BurnedCalorieCount
    public let sortedWeeklyCals: [Int]
}

// This is the placeholder which gets displayed in the widget picker
struct PlaceholderView : View {
    var body: some View {
        calorie_widget_targetEntryView(entry: SimpleEntry(date: Date(), burnedCalories: BurnedCalorieCount(active: 1, resting: 2, total: 1234),
                                                          sortedWeeklyCals: [1,2,3,4,5,6,7]))
    }
}

// This view defines how the widget looks
struct calorie_widget_targetEntryView : View {
    var entry: Provider.Entry
    
    var baseFontSize = 40.0

    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemMedium:
            VStack(alignment: .trailing, spacing: 10) {
                HStack(alignment: .lastTextBaseline, spacing: 25) {
                    HStack(alignment: .center, spacing: 10)
                    {
                        ForEach(entry.sortedWeeklyCals, id: \.self){
                            data in
                            BarView(value: CGFloat(data))
                        }
                    }.padding(.top, 24)
                     .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                    
                    Text("\(formatCalories(calories: entry.burnedCalories.total))")
                        .font(.system(size: CGFloat(baseFontSize * 1), weight: .thin))
                        .foregroundColor(.white)
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .trailing)
                }
                
                HStack(alignment: .lastTextBaseline, spacing: 25) {
                    Image(systemName: "flame")
                        .font(.system(size: CGFloat(baseFontSize * 0.6), weight: .thin))
                        .imageScale(.large)
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                    
                    Text("kcal")
                        .font(.system(size: CGFloat(baseFontSize * 0.5), weight: .thin))
                        .foregroundColor(.white)
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .trailing)
                }

            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .trailing)
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [.yellow, .red]),                                   startPoint: .topLeading,
                                           endPoint: .bottomTrailing))
            
        default: // Small
            VStack(alignment: .trailing, spacing: 10) {
                Text("\(formatCalories(calories: entry.burnedCalories.total))")
                    .font(.system(size: CGFloat(baseFontSize * 1), weight: .thin))
                    .foregroundColor(.white)
                    .bold()
                
                HStack(alignment: .lastTextBaseline, spacing: 25) {
                    Image(systemName: "flame")
                        .font(.system(size: CGFloat(baseFontSize * 0.6), weight: .thin))
                        .imageScale(.large)
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                    
                    Text("kcal")
                        .font(.system(size: CGFloat(baseFontSize * 0.5), weight: .thin))
                        .foregroundColor(.white)
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .trailing)
                }
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .trailing)
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [.yellow, .red]),                                   startPoint: .topLeading,
                                           endPoint: .bottomTrailing))
        }
    }

    public func formatCalories(calories: Int) -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter.string(from: calories as NSNumber)!
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
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}


struct calorie_widget_target_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            calorie_widget_targetEntryView(entry: SimpleEntry(date: Date(), burnedCalories: BurnedCalorieCount(active: 1, resting: 2, total: 1234),
                                                              sortedWeeklyCals: [1,2,3,4,5,6,7]))
                .previewContext(WidgetPreviewContext(family:
                    .systemSmall))

            calorie_widget_targetEntryView(entry: SimpleEntry(date: Date(), burnedCalories: BurnedCalorieCount(active: 1, resting: 2, total: 1234),
                                                              sortedWeeklyCals: [1,2,3,4,5,6,7]))
                .previewContext(WidgetPreviewContext(family:
                    .systemMedium))
            
            PlaceholderView()
                .previewContext(WidgetPreviewContext(family:
                    .systemSmall))
        }
    }
}

