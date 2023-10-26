//
//  MyWatchWidget.swift
//  MyWatchWidget
//
//  Created by Qianlishun on 2023/10/10.
//

import WidgetKit
import SwiftUI

@main
struct WidgetForWatchOS: WidgetBundle {
    var body: some Widget {
        CircularWidget()
        WeatherWidget()
        HealthWidget()
    }
}

struct CircularWidget: Widget{
    let kind: String = "CircularWidget"

    var body: some WidgetConfiguration {
        
        StaticConfiguration(kind: kind, provider: CircularProvider()) { entry in
            CircularWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }.configurationDisplayName("Circular")
    }

}

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }.configurationDisplayName("Weather")
    }

}

struct HealthWidget: Widget {
    let kind: String = "HealthWidget"

    var body: some WidgetConfiguration {
        
        StaticConfiguration(kind: kind, provider: HealthProvider()) { entry in
            HealthWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }.configurationDisplayName("Health")
    }

}

struct CircularProvider: TimelineProvider {
  
    func placeholder(in context: Context) -> CircularEntry {
        return CircularEntry(image: leftTopImageName, string: "Q")
    }

    func getSnapshot(in context: Context, completion: @escaping (CircularEntry) -> ()) {
        let entry = CircularEntry(image: leftTopImageName, string: "Q")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = CircularEntry(image: leftTopImageName, string: "Q")
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

}

struct WeatherProvider: TimelineProvider {
  
    var widgetLocationManager = WidgetLocationManager()

    func placeholder(in context: Context) -> WeatherEntry {
        return WeatherEntry(weather: WeatherViewInfo(current: QWeather(date: Date(), condition: "局部小雨", symbol: "cloud.rain", temperature: "20℃",humidity: "50%"), after1Hours: QWeather(date: Date()+3600,condition: "局部大雪", symbol: "snow", temperature: "-5℃",humidity: "50%"),alert: ""))

    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {

        let entry = WeatherEntry(weather: WeatherViewInfo(current: QWeather(date: Date(), condition: "局部小雨", symbol: "cloud.rain", temperature: "20℃",humidity: "50%"), after1Hours: QWeather(date: Date()+3600,condition: "局部大雪", symbol: "snow", temperature: "-5℃",humidity: "50%"),alert: ""))

        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

        widgetLocationManager.fetchLocation(handler: { location in
            Task{
                var currentDate = Date()
                let oneHour: TimeInterval = 60*60

                if(HFWeatherKey.count == 0){
                    let weather = try await getWeather(location: location, afterHours: 3)
                    
                    var entries = [WeatherEntry]()
                    for i in 0..<2{
                        let info = WeatherViewInfo(current: weather.weathers[i], after1Hours: weather.weathers[i+1],alert: weather.alerts[0])
                        
                        let entry = WeatherEntry(date: currentDate, weather: info)
                        entries.append(entry)
                        currentDate += oneHour
                    }
                    
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    
                    completion(timeline)
                }else{
                    
                    getHFWeather(location: location) { weather in
                        var entries = [WeatherEntry]()
                        for i in 0..<6{
                            let info = WeatherViewInfo(current: weather.weathers[i], after1Hours: weather.weathers[i+1],alert: weather.alerts[0])
                            
                            let entry = WeatherEntry(date: currentDate, weather: info)
                            entries.append(entry)
                            currentDate += oneHour
                        }
                        
                        let timeline = Timeline(entries: entries, policy: .atEnd)
                        
                        completion(timeline)
                    }
                    
                }
            }
            WidgetCenter.shared.reloadTimelines(ofKind: "HealthWidget")

        })
    }
}

struct HealthProvider: TimelineProvider {
    
    var healthObserver = HealthObserver()

    func placeholder(in context: Context) -> HealthEntry {
        return HealthEntry(health: HealthInfo(steps: 9999, excercise: 99, excerciseTime: 99, standHours: 99, heartRate: 60))
    }

    func getSnapshot(in context: Context, completion: @escaping (HealthEntry) -> ()) {
        let entry = HealthEntry(health: HealthInfo(steps: 9999, excercise: 99, excerciseTime: 99, standHours: 99, heartRate: 60))
            
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
            
        healthObserver.getHealthInfo { health in
            let entry = HealthEntry( health: health )
            
            let timeline = Timeline(entries: [entry], policy: .never)
            
            completion(timeline)
        }
    }
}

struct CircularWidgetEntryView : View{
    var entry: CircularProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            
            let uiImage = UIImage(named: entry.image)
            if(uiImage != nil){
                Image(uiImage: uiImage!)
            }else{
                Text(entry.string)
            }
            
        default:
            VStack{}
        }
    }
}

struct WeatherWidgetEntryView : View {
    var entry: WeatherProvider.Entry
    @Environment(\.widgetFamily) var family
    

    var body: some View {
        switch family {
        case .accessoryCircular:
            
            Text("Q")
             
        case .accessoryRectangular: 
            
            WeatherRectangularView(weather: entry.weather)

        default:
            VStack{}
        }
    }
}

struct HealthWidgetEntryView : View {
    var entry: HealthProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            
            Text("V")
                
        case .accessoryRectangular:

            HealthRectangularView(health: entry.health)
            
        default:
            VStack{}
        }
    }
}

struct CircularEntry: TimelineEntry {
    var date: Date = Date()
    let image: String
    let string: String
    init(image: String, string: String) {
        self.image = image
        self.string = string
    }
    init(){
        self.init(image: "", string: "Q")
    }
}

struct WeatherEntry: TimelineEntry {
    var date: Date = Date()
    let weather: WeatherViewInfo
}

struct HealthEntry: TimelineEntry {
    var date: Date = Date()
    let health: HealthInfo
}


#Preview(as: .accessoryRectangular) {
    WeatherWidget()
} timeline: {
    WeatherEntry(weather: WeatherViewInfo(current: QWeather(date: Date(), condition: "局部小雨", symbol: "cloud.rain", temperature: "20℃",humidity: "50%"), after1Hours: QWeather(date: Date()+3600,condition: "局部大雪", symbol: "snow", temperature: "-11℃",humidity: "50%"),alert: "大风预警"))
}


#Preview(as: .accessoryRectangular) {
    HealthWidget()
} timeline: {
    HealthEntry(health: HealthInfo(steps: 9999, excercise: 99, excerciseTime: 99, standHours: 99, heartRate: 60))
}

#Preview(as: .accessoryCircular) {
    CircularWidget()
} timeline: {
    CircularEntry(image: leftTopImageName, string: "Q")
}
