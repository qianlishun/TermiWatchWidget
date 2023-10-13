//
//  MyWatchWidget.swift
//  MyWatchWidget
//
//  Created by Qianlishun on 2023/10/10.
//

import WidgetKit
import SwiftUI

let terminalName = "void"
let leftTopImageName = "LeftTopImage"

let colorAlert1 = Color.yellow
let colorAlert2 = Color.red
let colorTemp1 = Color.white
let colorTemp2 = Color.blue
let colorCurr = Color.white
let colorNext = Color.blue

let colorKeep1 = Color.cyan
let colorKeep2 = Color.brown
let colorStep = Color.indigo
let colorKcal = Color.red
let colorHR = Color.orange


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
    
    let font = Font.system(size: 13)

    var body: some View {
        switch family {
        case .accessoryCircular:
            
            Text("Q")
             
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                HStack {
                    MyText("user@\(terminalName):~ $ now")
                }.frame(height: 10)
                
                HStack {
                    MyText("[ALER.]")
                    Image(systemName: "exclamationmark.triangle").frame(width: 16).imageScale(.small).foregroundStyle(colorAlert1).minimumScaleFactor(0.8)
                    Text(entry.weather.alert).font(font).foregroundStyle(colorAlert1)
                }.frame(height: 10)
                
                HStack {
                    MyText("[TEMP]")
                    let temp = entry.weather.current.temperature
                    let temp2 = entry.weather.current.temperature

                    HStack(spacing: 0){
                        MyText(temp.value)
                        MyText(temp.unit)
                    }.foregroundColor(colorTemp1)
                    MyText("→")
                    HStack(spacing: 0){
                        MyText(temp2.value)
                        MyText(temp2.unit)
                    }.foregroundColor(colorTemp2)
                }.frame(height: 10)
                
                HStack {
                    MyText("[CuRR]")
                    Image(systemName: entry.weather.current.symbol).frame(width: 15).imageScale(.small)
                    Text(entry.weather.current.condition).font(font).frame( maxWidth: .infinity,alignment: .leading).foregroundColor(colorCurr).minimumScaleFactor(0.8)
                }.frame(height: 10)

                HStack {
                    MyText("[NEXT]")
                    Image(systemName: entry.weather.after1Hours.symbol).frame(width: 15).imageScale(.small)
                    Text(entry.weather.after1Hours.condition).font(font).frame( maxWidth: .infinity,alignment: .leading).foregroundColor(colorNext).minimumScaleFactor(0.8)
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
                    MyText("\(entry.health.excerciseTime)").foregroundStyle(colorKeep1)
                    Image(systemName: "figure.stand").imageScale(.small)
                    MyText("\(entry.health.standHours)").foregroundStyle(colorKeep2)
                    MyText("                               ")
                }.frame(height: 10)
                
                HStack {
                    MyText("[STEP]")
                    Image(systemName: "figure.walk").imageScale(.small)
                    MyText("\(entry.health.steps)").foregroundStyle(colorStep)
                }.frame(height: 10)
                
                HStack {
                    MyText("[KCAL]")
                    Image(systemName: "flame").imageScale(.small)
                    MyText("\(entry.health.excercise)").foregroundStyle(colorKcal)
                }.frame(height: 10)
                
                HStack {
                    MyText("[L_HR]")
                    Image(systemName: "heart.circle").imageScale(.small)
                    MyText("\(entry.health.heartRate)").foregroundStyle(colorHR)
                }.frame(height: 10)
                
                HStack {
                    MyText("user@\(terminalName):~ $ ")
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

#Preview(as: .accessoryCircular) {
    CircularWidget()
} timeline: {
    CircularEntry(image: leftTopImageName, string: "Q")
}
