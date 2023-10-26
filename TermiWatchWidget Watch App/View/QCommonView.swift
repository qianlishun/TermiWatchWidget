//
//  WeatherWidgetEntryView.swift
//  TermiWatchWidget
//
//  Created by Qianlishun on 2023/10/16.
//

import SwiftUI

// 如果配置了和风APIKey，则使用和风API代替WeatherKit
let HFWeatherKey = ""

let terminalName = "void"
let leftTopImageName = "LeftTopImage"

let colorAlert1 = Color.yellow
let colorAlert2 = Color.red
let colorTemp = Color(r: 253, g: 143, b: 63)
let colorHumi = Color.blue
let colorCond = Color(r: 255, g: 215, b: 0)
let colorWind = Color.white

let colorKeep1 = Color.cyan
let colorKeep2 = Color.brown
let colorStep = Color.indigo
let colorKcal = Color(r:238,g:98,b:48)
let colorHR = Color(r:235,g:74,b:98)


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


struct WeatherRectangularView : View {
    var weather: WeatherViewInfo
    
    let font = Font.system(size: 13)

    var body: some View{
        VStack(alignment: .leading) {
            HStack {
                MyText("user@\(terminalName):~ $ now").frame(maxWidth: .infinity, alignment: .leading)
            }.frame(height: 10)
            if(weather.alert.count>0){
                HStack {
                    MyText("[ALER.]")
                    Image(systemName: "exclamationmark.triangle").frame(width: 16).imageScale(.small).foregroundStyle(colorAlert1).minimumScaleFactor(0.8)
                    Text(weather.alert).font(font).foregroundStyle(colorAlert1)
                }.frame(height: 10)
            }
            HStack {
                MyText("[CuRR]")
                WXImage(wxIcon: weather.current.symbol).foregroundStyle(color: colorCond)
                Text(weather.current.condition).font(font).frame( maxWidth: .infinity,alignment: .leading).foregroundStyle(colorCond).minimumScaleFactor(0.8)
            }.frame(height: 10)
            
            HStack {
                MyText("[TEMP]")
                Image(systemName: "thermometer.transmission").frame(width: 15).imageScale(.small).foregroundStyle(colorTemp)
                let temp = weather.current.temperature
                HStack(spacing: 0){
                    MyText(temp.value)
                    MyText(temp.unit)
                }.foregroundStyle(colorTemp)
            }.frame(height: 10)
                        
            HStack {
                MyText("[HUMI]")
                Image(systemName: "humidity").frame(width: 15).imageScale(.small).foregroundStyle(colorHumi)
                Text(weather.current.humidity).font(font).frame( maxWidth: .infinity,alignment: .leading).foregroundStyle(colorHumi).minimumScaleFactor(0.8)
            }.frame(height: 10)
            
            if(weather.alert.count==0){
                HStack {
                    MyText("[NEXT]")
                    WXImage(wxIcon: weather.after1Hours.symbol).foregroundStyle(color: colorCond)
                    Text(weather.after1Hours.condition).font(font).frame(alignment: .leading).foregroundStyle(colorCond).minimumScaleFactor(0.8)
                    Text("\(weather.after1Hours.temperature.value)\(weather.after1Hours.temperature.unit)").font(font).foregroundStyle(colorTemp)
                    Text(weather.after1Hours.humidity).font(font).foregroundStyle(colorHumi)
                }.frame(height: 10)
            }
        }
    }
}


struct HealthRectangularView : View {
    var health: HealthInfo

    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                MyText("[KEEP]")
                Image(systemName: "figure.run").imageScale(.small).foregroundStyle(colorKeep1)
                MyText("\(health.excerciseTime)").foregroundStyle(colorKeep1)
                Image(systemName: "figure.stand").imageScale(.small).foregroundStyle(colorKeep2)
                MyText("\(health.standHours)").foregroundStyle(colorKeep2)
                MyText("                               ")
            }.frame(height: 10)
            
            HStack {
                MyText("[STEP]")
                Image(systemName: "figure.walk").imageScale(.small).foregroundStyle(colorStep)
                MyText("\(health.steps)").foregroundStyle(colorStep)
            }.frame(height: 10)
            
            HStack {
                Text("[KCAL]").font(.system(size: 13))
                Image(systemName: "flame").imageScale(.small).foregroundStyle(colorKcal)
                MyText("\(health.excercise)").foregroundStyle(colorKcal)
            }.frame(height: 10)
            
            HStack {
                MyText("[L_HR]")
                Image(systemName: "heart.circle").imageScale(.small).foregroundStyle(colorHR)
                MyText("\(health.heartRate)").foregroundStyle(colorHR)
            }.frame(height: 10)
            
            HStack {
                MyText("user@\(terminalName):~ $ ").frame(maxWidth: .infinity, alignment: .leading)
            }.frame(height: 10.5)
        }
    }
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
