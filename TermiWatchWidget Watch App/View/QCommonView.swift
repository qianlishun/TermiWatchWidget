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
    
    init(current: QWeather, after1Hours: QWeather, alert: String, dateText: String?) {
        self.dateText = dateText
        self.current = current
        self.after1Hours = after1Hours
        self.alert = alert
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

    var body: some View{
        let rowHeight = ((context?.displaySize.height ?? qRowHeight*5) / 5.0) + 0.5
        
        VStack(alignment: .leading,spacing: 0) {
            HStack {
                if((weather.dateText != nil) && weather.dateText!.count > 0){
                    Text("[DATE]").font(.system(size: qFontSize+0.5))
                    MyText(weather.dateText!).frame(maxWidth: .infinity, alignment: .leading)
                }else{
                    MyText("user@\(terminalName):~ $ now").frame(maxWidth: .infinity, alignment: .leading)
                }
            }.frame(height: rowHeight)
            if(weather.alert.count>0){
                HStack {
                    MyText("[ALER.]")
                    Image(systemName: "exclamationmark.triangle").frame(width: 16).imageScale(.small).foregroundStyle(colorAlert1).minimumScaleFactor(0.8)
                    Text(weather.alert).font(font).foregroundStyle(colorAlert1)
                }.frame(height: rowHeight)
            }
            HStack {
                MyText("[CuRR]")
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
                MyText("[HUMI]")
                Image(systemName: "humidity").frame(width: 15).imageScale(.small).foregroundStyle(colorHumi)
                Text(weather.current.humidity).font(font).frame( maxWidth: .infinity,alignment: .leading).foregroundStyle(colorHumi).minimumScaleFactor(0.8)
            }.frame(height: rowHeight)
            
            if(weather.alert.count==0){
                HStack {
                    MyText("[NEXT]")
                    WXImage(wxIcon: weather.after1Hours.symbol).foregroundStyle(color: colorCond)
                    Text(weather.after1Hours.condition).font(font).frame(alignment: .leading).foregroundStyle(colorCond).minimumScaleFactor(0.8)
                    Text("\(weather.after1Hours.temperature.value)\(weather.after1Hours.temperature.unit)").font(font).foregroundStyle(colorTemp)
                    Text(weather.after1Hours.humidity).font(font).foregroundStyle(colorHumi)
                }.frame(height: rowHeight)
            }
        }
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
                MyText("                               ")
            }.frame(height: rowHeight)
            
            HStack {
                MyText("[STEP]")
                Image(systemName: "figure.walk").imageScale(.small).foregroundStyle(colorStep)
                MyText("\(health.steps)").foregroundStyle(colorStep)
            }.frame(height: rowHeight)
            
            HStack {
                Text("[KCAL]").font(.system(size: qFontSize-0.5))
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
        }
    }
}


struct MyText: View {
    let font = Font.system(size: qFontSize)
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View{
        Text(text).font(font).frame(alignment: .leading)
    }

}
