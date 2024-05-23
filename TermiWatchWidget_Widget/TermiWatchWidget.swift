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
        }.configurationDisplayName(LocalizedStringKey("Circular"))
    }

}

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }.configurationDisplayName(LocalizedStringKey("Weather"))
    }

}

struct HealthWidget: Widget {
    let kind: String = "HealthWidget"

    var body: some WidgetConfiguration {
        
        StaticConfiguration(kind: kind, provider: HealthProvider()) { entry in
            HealthWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }.configurationDisplayName(LocalizedStringKey("Health"))
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
        return WeatherEntry(context: context, weather: WeatherViewInfo(current: QWeather(date: Date(), condition: "局部小雨", symbol: "cloud.rain", temperature: "20℃",humidity: "50%"), after1Hours: QWeather(date: Date()+3600,condition: "局部大雪", symbol: "snow", temperature: "-5℃",humidity: "50%"),alert: ""))

    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {

        let entry = WeatherEntry(context: context, weather: WeatherViewInfo(current: QWeather(date: Date(), condition: "局部小雨", symbol: "cloud.rain", temperature: "20℃",humidity: "50%"), after1Hours: QWeather(date: Date()+3600,condition: "局部大雪", symbol: "snow", temperature: "-5℃",humidity: "50%"),alert: ""))

        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let formatter = getCurrentFormatter()

        widgetLocationManager.fetchLocation(handler: { location in
            Task{

                if(HFWeatherKey.count == 0){
                    let weather = try await getWeather(location: location, afterHours: 6)
                    
                    var entries = [WeatherEntry]()
                    for i in 0..<5{
                        let dateStr = formatter.noYear(from: weather.weathers[i].date)

                        let info = WeatherViewInfo(current: weather.weathers[i], after1Hours: weather.weathers[i+1], alert: weather.alerts[0], dateText: dateStr)
                        
                        let entry = WeatherEntry(context: context, date: info.current.date, weather: info)
                        entries.append(entry)
                    }
                    
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    
                    completion(timeline)
                }else{
                    
                    getHFWeather(location: location) { weather in
                        var entries = [WeatherEntry]()
                        for i in 0..<12{
                            let dateStr = formatter.noYear(from: weather.weathers[i].date)

                            let info = WeatherViewInfo(current: weather.weathers[i], after1Hours: weather.weathers[i+1], alert: weather.alerts[0], dateText: dateStr)
                            
                            let entry = WeatherEntry(context:context, date: info.current.date, weather: info)
                            entries.append(entry)
                        }
                        
                        let timeline = Timeline(entries: entries, policy: .atEnd)
                        
                        completion(timeline)
                    }
                    
                }
            }
        })
        WidgetCenter.shared.reloadTimelines(ofKind: "HealthWidget")
    }
}

struct HealthProvider: TimelineProvider {
    
    var healthObserver = HealthObserver()

    func placeholder(in context: Context) -> HealthEntry {
        return HealthEntry(context: context, health: HealthInfo(steps: 9999, excercise: 99, excerciseTime: 99, standHours: 99, heartRate: 60))
    }

    func getSnapshot(in context: Context, completion: @escaping (HealthEntry) -> ()) {
        let entry = HealthEntry(context: context, health: HealthInfo(steps: 9999, excercise: 99, excerciseTime: 99, standHours: 99, heartRate: 60))
            
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var refresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        if(isEveningNow()){
            refresh = Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date()
        }
        healthObserver.getHealthInfo { health in
            let entry = HealthEntry( context: context, health: health)
            
            let timeline = Timeline(entries: [entry], policy: .after(refresh))
            
            completion(timeline)
        }
    }
    func isEveningNow() -> Bool {
       let date = Date()
       let calendar = Calendar.current
       let components = calendar.component(.hour, from: date)
       
       // 定义晚上的时间范围，例如从22:00到06:00
       return components >= 22 && components <= 6
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
            
            WeatherRectangularView(context: entry.context, weather: entry.weather)

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

            HealthRectangularView(context: entry.context, health: entry.health)
            
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
    let context: TimelineProviderContext?
    var date: Date = Date()
    let weather: WeatherViewInfo
}

struct HealthEntry: TimelineEntry {
    let context: TimelineProviderContext?
    var date: Date = Date()
    let health: HealthInfo
}


#Preview(as: .accessoryRectangular) {
    WeatherWidget()
} timeline: {
    WeatherEntry(context: nil, weather: WeatherViewInfo(current: QWeather(date: Date(), condition: "局部小雨", symbol: "cloud.rain", temperature: "20℃",humidity: "50%"), after1Hours: QWeather(date: Date()+3600,condition: "局部大雪", symbol: "snow", temperature: "-11℃",humidity: "50%"),alert: "大风预警"))
}

#Preview(as: .accessoryRectangular) {
    HealthWidget()
} timeline: {
    HealthEntry(context: nil, health: HealthInfo(steps: 9999, excercise: 99, excerciseTime: 99, standHours: 99, heartRate: 60))
}

#Preview(as: .accessoryCircular) {
    CircularWidget()
} timeline: {
    CircularEntry(image: leftTopImageName, string: "Q")
}
