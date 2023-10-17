//
//  WeatherWidgetEntryView.swift
//  TermiWatchWidget
//
//  Created by Qianlishun on 2023/10/16.
//

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
                MyText("user@\(terminalName):~ $ now")
            }.frame(height: 10)
            
            HStack {
                MyText("[ALER.]")
                Image(systemName: "exclamationmark.triangle").frame(width: 16).imageScale(.small).foregroundStyle(colorAlert1).minimumScaleFactor(0.8)
                Text(weather.alert).font(font).foregroundStyle(colorAlert1)
            }.frame(height: 10)
            
            HStack {
                MyText("[TEMP]")
                let temp = weather.current.temperature
                let temp2 = weather.current.temperature
                
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
                Image(systemName: weather.current.symbol).frame(width: 15).imageScale(.small)
                Text(weather.current.condition).font(font).frame( maxWidth: .infinity,alignment: .leading).foregroundColor(colorCurr).minimumScaleFactor(0.8)
            }.frame(height: 10)
            
            HStack {
                MyText("[NEXT]")
                Image(systemName: weather.after1Hours.symbol).frame(width: 15).imageScale(.small)
                Text(weather.after1Hours.condition).font(font).frame( maxWidth: .infinity,alignment: .leading).foregroundColor(colorNext).minimumScaleFactor(0.8)
            }.frame(height: 10)
        }
    }
}


struct HealthRectangularView : View {
    var health: HealthInfo

    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                MyText("[KEEP]")
                Image(systemName: "figure.run").imageScale(.small)
                MyText("\(health.excerciseTime)").foregroundStyle(colorKeep1)
                Image(systemName: "figure.stand").imageScale(.small)
                MyText("\(health.standHours)").foregroundStyle(colorKeep2)
                MyText("                               ")
            }.frame(height: 10)
            
            HStack {
                MyText("[STEP]")
                Image(systemName: "figure.walk").imageScale(.small)
                MyText("\(health.steps)").foregroundStyle(colorStep)
            }.frame(height: 10)
            
            HStack {
                MyText("[KCAL]")
                Image(systemName: "flame").imageScale(.small)
                MyText("\(health.excercise)").foregroundStyle(colorKcal)
            }.frame(height: 10)
            
            HStack {
                MyText("[L_HR]")
                Image(systemName: "heart.circle").imageScale(.small)
                MyText("\(health.heartRate)").foregroundStyle(colorHR)
            }.frame(height: 10)
            
            HStack {
                MyText("user@\(terminalName):~ $ ")
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
