//
//  WeatherWidgetEntryView.swift
//  TermiWatchWidget
//
//  Created by Qianlishun on 2023/10/16.
//

import SwiftUI
import WidgetKit

struct WeatherViewInfo {
    let current: QWeather
    let after1Hours: QWeather
    let alert: String
    var dateText : String? = nil
    var bgImage: String? = qWeatherImage

    init(current: QWeather, after1Hours: QWeather, alert: String, dateText: String?) {
        let userdefaults = UserDefaults.init(suiteName: qGroupBundleID)

        self.dateText = dateText
        self.current = current
        self.after1Hours = after1Hours
        self.alert = alert
        self.bgImage = userdefaults?.string(forKey: qWeatherImageKey) ?? qWeatherImage
    }
    
    init(current: QWeather, after1Hours: QWeather, alert: String) {
        self.init(current: current, after1Hours: after1Hours, alert: alert, dateText: nil)
    }
    
    init(){
        self.init(current: QWeather(), after1Hours: QWeather(), alert: "" )
    }
}


struct WeatherRectangularView : View {
    let context: TimelineProviderContext?
    var weather: WeatherViewInfo
    
    let font = Font.system(size: qFontSize)
    let smallFont = Font.system(size: qFontSize-2)

    var body: some View{
        let rowHeight = ((context?.displaySize.height ?? qRowHeight*5) / 5.0) + 0.5
        
        VStack(alignment: .leading,spacing: 0) {
            HStack {
                if((weather.dateText != nil) && weather.dateText!.count > 0){
                    MyText("[DATE]",fontSize: qFontSize+0.5)
                    MyText(weather.dateText!).frame(maxWidth: .infinity, alignment: .leading).minimumScaleFactor(0.8).foregroundStyle(colorDate)
                }else{
                    MyText("user@\(terminalName):~ $ now").frame(maxWidth: .infinity, alignment: .leading)
                }
            }.frame(height: rowHeight)
            if(weather.alert.count>0){
                HStack {
                    MyText("[ALER]",fontSize: qFontSize+0.5)
                    Image(systemName: "exclamationmark.triangle").frame(width: 16).imageScale(.small).foregroundStyle(colorAlert1).minimumScaleFactor(0.8)
                    Text(weather.alert).font(font).foregroundStyle(colorAlert1)
                }.frame(height: rowHeight)
            }
            HStack {
                MyText("[CURR]").kerning(-0.2)
                WXImage(wxIcon: weather.current.symbol).foregroundStyle(color: colorCond)
                Text(weather.current.condition).font(font).frame( maxWidth: .infinity,alignment: .leading).foregroundStyle(colorCond).minimumScaleFactor(0.8)
            }.frame(height: rowHeight)
            
            HStack {
                MyText("[TEMP]")
                Image(systemName: "thermometer.transmission").frame(width: 15).imageScale(.small).foregroundStyle(colorTemp)
                let temp = weather.current.temperature
                HStack(spacing: 0){
                    MyText(temp.value)
                    MyText(temp.unit)
                }.foregroundStyle(colorTemp)
            }.frame(height: rowHeight)
            
            HStack {
                MyText("[HUMI]",fontSize: qFontSize+0.5).kerning(-0.1)
                Image(systemName: "humidity").frame(width: 15).imageScale(.small).foregroundStyle(colorHumi)
                Text(weather.current.humidity).font(font).frame( maxWidth: .infinity,alignment: .leading).foregroundStyle(colorHumi).minimumScaleFactor(0.8)
            }.frame(height: rowHeight)
            
            if(weather.alert.count==0){
                HStack {
                    MyText("[NEXT]").kerning(0.1)
                    HStack{
                        WXImage(wxIcon: weather.after1Hours.symbol).foregroundStyle(color: colorCond)
                        Text(weather.after1Hours.condition).font(smallFont).frame(alignment: .leading).foregroundStyle(colorCond)
                        Text("\(weather.after1Hours.temperature.value)\(weather.after1Hours.temperature.unit)").font(smallFont).foregroundStyle(colorTemp)
                        Text(weather.after1Hours.humidity).font(smallFont).foregroundStyle(colorHumi)
                    }.minimumScaleFactor(0.6)
                }.frame(height: rowHeight)
            }
        }.background(Image(weather.bgImage ?? "").resizable()
            .aspectRatio(contentMode: .fit).opacity(0.35))
    }
}


struct HealthRectangularView : View {
    let context: TimelineProviderContext?
    var health: HealthInfo

    
    var body: some View {
        let rowHeight = ((context?.displaySize.height ?? qRowHeight*5) / 5.0) + 0.5

        VStack(alignment: .leading,spacing: 0) {
            HStack{
                MyText("[KEEP]")
                Image(systemName: "figure.run").imageScale(.small).foregroundStyle(colorKeep1)
                MyText("\(health.excerciseTime)").foregroundStyle(colorKeep1)
                Image(systemName: "figure.stand").imageScale(.small).foregroundStyle(colorKeep2)
                MyText("\(health.standHours)").foregroundStyle(colorKeep2)
            }.frame(height: rowHeight)
            
            HStack {
                MyText("[STEP]")
                Image(systemName: "figure.walk").imageScale(.small).foregroundStyle(colorStep)
                MyText("\(health.steps)").foregroundStyle(colorStep)
            }.frame(height: rowHeight)
            
            HStack {
                MyText("[KCAL]", fontSize: qFontSize-0.5)
                Image(systemName: "flame").imageScale(.small).foregroundStyle(colorKcal)
                MyText("\(health.excercise)").foregroundStyle(colorKcal)
            }.frame(height: rowHeight)
            
            HStack {
                MyText("[L_HR]")
                Image(systemName: "heart.circle").imageScale(.small).foregroundStyle(colorHR)
                MyText("\(health.heartRate)").foregroundStyle(colorHR)
            }.frame(height: rowHeight)
            
            HStack {
                MyText("user@\(terminalName):~ $ ").frame(maxWidth: .infinity, alignment: .leading)
            }.frame(height: rowHeight)
        }.background(Image(health.bgImage ?? "").resizable()
            .aspectRatio(contentMode: .fit).opacity(0.35))
    }
}


struct MyText: View {
    let font: Font
    
    let text: String
    
    init(_ text: String) {
        self.text = text
        self.font = Font.custom("SFMono-Light", size: qFontSize)
    }
    
    init(_ text: String, fontSize: CGFloat){
        self.text = text
        self.font = Font.custom("SFMono-Light", size: fontSize)
    }
    
    var body: some View{
        Text(text).font(font).frame(alignment: .leading)
    }

}

#Preview(body: {
    
    VStack(alignment: .leading, spacing: 1) {
              
        WeatherRectangularView(context: nil, weather: WeatherViewInfo(current: QWeather(date: Date(), condition: "局部小雨", symbol: "cloud.rain", temperature: "20℃",humidity: "50%"), after1Hours: QWeather(date: Date()+3600,condition: "局部大雪", symbol: "snow", temperature: "-11℃",humidity: "50%"),alert: "", dateText: "周末"))
        
        HealthRectangularView(context: nil, health: HealthInfo(steps: 9999, excercise: 99, excerciseTime: 99, standHours: 99, heartRate: 60))
    }
    
})
