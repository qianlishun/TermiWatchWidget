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
        WeatherWidget()
        HealthWidget()
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

struct WeatherProvider: TimelineProvider {
    
    var widgetLocationManager = WidgetLocationManager()

    func placeholder(in context: Context) -> WeatherEntry {
        return WeatherEntry(weather: WeatherViewInfo(current: QWeather(date: Date(), condition: "局部小雨", symbol: "cloud.rain", temperature: "20℃"), after1Hours: QWeather(date: Date()+3600,condition: "局部大雪", symbol: "snow", temperature: "-5℃"),alert: ""))

    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {

        let entry = WeatherEntry(weather: WeatherViewInfo(current: QWeather(date: Date(), condition: "局部小雨", symbol: "cloud.rain", temperature: "20℃"), after1Hours: QWeather(date: Date()+3600,condition: "局部大雪", symbol: "snow", temperature: "-5℃"),alert: ""))

        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

        widgetLocationManager.fetchLocation(handler: { location in
            Task{
                var currentDate = Date()
                let oneHour: TimeInterval = 30*60

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
        Task{

            let health = await healthObserver.getHealthInfo()
            let entry = HealthEntry( health: health )
       
            let timeline = Timeline(entries: [entry], policy: .never)
            
            completion(timeline)
        }
    }
}

struct WeatherWidgetEntryView : View {
    var entry: WeatherProvider.Entry
    @Environment(\.widgetFamily) var family
    
    let font = Font.system(size: 13)

    var body: some View {
        switch family {
        case .accessoryCircular:
            
            Text("Q")
             
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                HStack {
                    MyText("user@void:~ $ now")
                }.frame(height: 10)
                
                HStack {
                    MyText("[ALER.]")
                    Image(systemName: "exclamationmark.triangle").frame(width: 16).imageScale(.small).foregroundStyle(.yellow).minimumScaleFactor(0.8)
                    Text(entry.weather.alert).font(font).foregroundStyle(.red)
                }.frame(height: 10)
                
                HStack {
                    MyText("[TEMP]")
                    let temp = entry.weather.current.temperature
                    let temp2 = entry.weather.current.temperature

                    HStack(spacing: 0){
                        MyText(temp.value)
                        MyText(temp.unit)
                    }.foregroundColor(.white)
                    MyText("→")
                    HStack(spacing: 0){
                        MyText(temp2.value)
                        MyText(temp2.unit)
                    }.foregroundColor(.blue)
                }.frame(height: 10)
                
                HStack {
                    MyText("[CuRR]")
                    Image(systemName: entry.weather.current.symbol).frame(width: 15).imageScale(.small)
                    Text(entry.weather.current.condition).font(font).frame( maxWidth: .infinity,alignment: .leading).foregroundColor(.white).minimumScaleFactor(0.8)
                }.frame(height: 10)

                HStack {
                    MyText("[NEXT]")
                    Image(systemName: entry.weather.after1Hours.symbol).frame(width: 15).imageScale(.small)
                    Text(entry.weather.after1Hours.condition).font(font).frame( maxWidth: .infinity,alignment: .leading).foregroundColor(.blue).minimumScaleFactor(0.8)
                }.frame(height: 10)

            }
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
            VStack(alignment: .leading) {
                HStack{
                    MyText("[KEEP]")
                    Image(systemName: "figure.run").imageScale(.small)
                    MyText("\(entry.health.excerciseTime)").foregroundStyle(.cyan)
                    Image(systemName: "figure.stand").imageScale(.small)
                    MyText("\(entry.health.standHours)").foregroundStyle(.brown)
                    MyText("                               ")
                }.frame(height: 10)
                
                HStack {
                    MyText("[STEP]")
                    Image(systemName: "figure.walk").imageScale(.small)
                    MyText("\(entry.health.steps)").foregroundStyle(.indigo)
                }.frame(height: 10)
                
                HStack {
                    MyText("[KCAL]")
                    Image(systemName: "flame").imageScale(.small)
                    MyText("\(entry.health.excercise)").foregroundStyle(.red)
                }.frame(height: 10)
                
                HStack {
                    MyText("[L_HR]")
                    Image(systemName: "heart.circle").imageScale(.small)
                    MyText("\(entry.health.heartRate)").foregroundStyle(.orange)
                }.frame(height: 10)
                
                HStack {
                    MyText("user@void:~ $ ")
                }.frame(height: 10.5)
            }
        default:
            VStack{}
        }
    }
}


struct WeatherViewInfo {
    let current: QWeather
    let after1Hours: QWeather
    let alert: String
    
    init(current: QWeather, after1Hours: QWeather, alert: String) {
        self.current = current
        self.after1Hours = after1Hours
        self.alert = alert
    }
    
    init(){
        self.init(current: QWeather(), after1Hours: QWeather(), alert: "" )
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

struct MyText: View {
    let font = Font.system(size: 13)
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View{
        Text(text).font(font).frame(alignment: .leading)
    }

}

#Preview(as: .accessoryRectangular) {
    WeatherWidget()
} timeline: {
    WeatherEntry(weather: WeatherViewInfo(current: QWeather(date: Date(), condition: "局部小雨", symbol: "cloud.rain", temperature: "20℃"), after1Hours: QWeather(date: Date()+3600,condition: "局部大雪", symbol: "snow", temperature: "-11℃"),alert: "大风预警"))
}


#Preview(as: .accessoryRectangular) {
    HealthWidget()
} timeline: {
    HealthEntry(health: HealthInfo(steps: 9999, excercise: 99, excerciseTime: 99, standHours: 99, heartRate: 60))
}
