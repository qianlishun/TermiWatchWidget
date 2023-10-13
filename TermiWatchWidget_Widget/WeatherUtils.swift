//
//  WeatherUtils.swift
//  TermiWatch
//
//  Created by Qianlishun on 2023/10/10.
//  Copyright © 2023 Librecz Gábor. All rights reserved.
//
import Foundation
import WeatherKit
import CoreLocation

struct WeatherInfo {
    let current: QWeather
    let weathers: [QWeather] // 0为当前
    let alerts: [String]
    
    init(current: QWeather, weathers: [QWeather], alerts: [String]) {
        self.current = current
        self.weathers = weathers
        self.alerts = alerts
    }
    
    init(){
        self.init(current: QWeather(), weathers: [QWeather()], alerts: [String()] )
    }
}
struct QTemperature{
    let value: String
    let unit: String
    init(value: String, unit: String) {
        self.value = value
        self.unit = unit
    }
    init(_ str: String){
        if str.count == 0{
            self.init()
        }else{
            let unitIndex = str.index(str.endIndex, offsetBy: -1)
            let unit = String(str[unitIndex])
            let temp = str.replacingOccurrences(of: unit, with: "")
            
            self.init(value: temp, unit: unit)
        }
    }
    init(){
        self.init(value: "0", unit: "℃")
    }
}
struct QWeather{
    let date: Date
    let condition: String
    let symbol: String
    let temperature: QTemperature
    
    init(date: Date, condition: String, symbol: String, temperature: String) {
        self.date = date
        self.condition = condition
        self.symbol = symbol
        self.temperature = QTemperature(temperature)
    }
    init() {
        self.init(date: Date() , condition: "", symbol: "", temperature: "")
    }
    
    init(currentWeather: CurrentWeather, tempMF: MeasurementFormatter){
        let condition = currentWeather.condition
        let symbol = currentWeather.symbolName
        let temperature = currentWeather.temperature
        let temp = tempMF.string(from: temperature)
        self.init(date: currentWeather.date, condition: condition.description, symbol: symbol, temperature: temp)
    }
    init(hourWeather: HourWeather, tempMF: MeasurementFormatter){
        let condition = hourWeather.condition
        let symbol = hourWeather.symbolName
        let temperature = hourWeather.temperature
        let temp = tempMF.string(from: temperature)
        self.init(date: hourWeather.date, condition: condition.accessibilityDescription, symbol: symbol, temperature: temp)
    }
}

//, completion: @escaping(String) -> ()
func getWeather(location: CLLocation, afterHours: Int) async throws -> WeatherInfo {
    let weatherService = WeatherService()

    var result: WeatherInfo = WeatherInfo()
    do {
        
        let formatter = MeasurementFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.unitStyle = .short
        formatter.numberFormatter.maximumFractionDigits = 0
        
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .hour, value: afterHours ,to: Date.now)

        let weather = try await weatherService.weather(for: location,including: .current, .hourly(startDate: Date.now, endDate: endDate!),.alerts)
                
        let current = QWeather(currentWeather: weather.0, tempMF: formatter )

        var afters = [QWeather]()
        for i in 0..<afterHours{
            let after = QWeather(hourWeather: weather.1.forecast[i], tempMF: formatter )
            afters.append(after)
        }
        
        var alerts = [String]()
        for i in 0..<afterHours{
            let alert = weather.2?[i].summary ?? ""
            alerts.append(alert)
        }
        
        result = WeatherInfo(current: current, weathers: afters, alerts: alerts)

    }catch {
        
        print("WatchWeatherCall error: \(error.localizedDescription)")
    }
        
    return result
}


class WidgetLocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    private var handler: ((CLLocation) -> Void)?
//    var lastLati = UserDefaults.standard.object(forKey: "LastLocation.lati") ?? 0
//    var lastLong = UserDefaults.standard.object(forKey: "LastLocation.long") ?? 0
//    var updateTime:Date = UserDefaults.standard.object(forKey: "LastLocationTime") as? Date ?? Date.init(timeIntervalSinceNow: -30)
   
    override init() {
        super.init()
        DispatchQueue.main.async {
            self.locationManager = CLLocationManager()
            self.locationManager!.delegate = self
            if self.locationManager!.authorizationStatus == .notDetermined {
                self.locationManager!.requestWhenInUseAuthorization()
            }
        }
    }
    
    func fetchLocation(handler: @escaping (CLLocation) -> Void) {
        self.handler = handler
        
//        print("\(lastLati)" + " " + "\(lastLong)" ,updateTime )
//
//        if( updateTime.timeIntervalSinceNow > -30){
//
//            let lati = UserDefaults.standard.object(forKey: "LastLocation.lati") as! CLLocationDegrees
//            let long = UserDefaults.standard.object(forKey: "LastLocation.long") as! CLLocationDegrees
//
//            let location = CLLocation(latitude: lati, longitude: long)
////            let location = CLLocation(latitude: 18.247872, longitude: 109.508268)
//            handler(location)
//        }else{
            self.locationManager?.requestLocation()
            print("requestLocation")

//        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location = locations.last!
//        lastLati = location.coordinate.latitude
//        lastLong = location.coordinate.longitude
//        
//        updateTime = Date()
//        print("\(lastLati)" + " " + "\(lastLong)" ,updateTime )
//
//        UserDefaults.standard.set(lastLati, forKey: "LastLocation.lati")
//        UserDefaults.standard.set(lastLong, forKey: "LastLocation.long")
//        UserDefaults.standard.set(updateTime, forKey: "LastLocationTime")
        manager.stopUpdatingLocation()

        self.handler!(locations.last!)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
