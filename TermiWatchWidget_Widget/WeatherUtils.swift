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
import SwiftUI



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
    
    init(current: HFWeatherNow, weathers: [HFWeather24h]){
        var weathers2 = weathers.map({ hf in
            QWeather(hfWeather: hf)
        })
        let currentQ = QWeather(hfWeather: current)
        weathers2.insert(currentQ, at: 0)
        self.init(current: currentQ, weathers: weathers2, alerts: [String()])
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
    let humidity: String
    
    init(date: Date, condition: String, symbol: String, temperature: String, humidity: String) {
        self.date = date
        self.condition = condition
        self.symbol = symbol
        self.temperature = QTemperature(temperature)
        self.humidity = humidity
    }
    init() {
        self.init(date: Date() , condition: "", symbol: "sparkles", temperature: "",humidity: "")
    }
    
    init(currentWeather: CurrentWeather, tempMF: MeasurementFormatter){
        let condition = currentWeather.condition
        let symbol = currentWeather.symbolName
        let temperature = currentWeather.temperature
        let temp = tempMF.string(from: temperature)
        let humidity = String("\(Int(currentWeather.humidity*100))%")
        self.init(date: currentWeather.date, condition: condition.description, symbol: symbol, temperature: temp, humidity: humidity)
    }
    init(hourWeather: HourWeather, tempMF: MeasurementFormatter){
        let condition = hourWeather.condition
        let symbol = hourWeather.symbolName
        let temperature = hourWeather.temperature
        let temp = tempMF.string(from: temperature)
        let humidity = String("\(Int(hourWeather.humidity*100))%")
        self.init(date: hourWeather.date, condition: condition.accessibilityDescription, symbol: symbol, temperature: temp, humidity: humidity)
    }
    init(hfWeather: HFWeatherNow){
        self.init(date: hfWeather.obsTime, condition: hfWeather.text, symbol: hfWeather.icon, temperature: hfWeather.temp+"℃", humidity: hfWeather.humidity+"%")
    }
    init(hfWeather: HFWeather24h){
        self.init(date: hfWeather.fxTime, condition: hfWeather.text, symbol: hfWeather.icon, temperature: hfWeather.temp+"℃", humidity: hfWeather.humidity+"%")
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

func HFWeatherNowAPI(
    location: CLLocation,
    apiKey: String = HFWeatherKey
) -> URL {
  return URL(
    string: "https://devapi.qweather.com/v7/weather/now?"
        + "location=\(location.coordinate.longitude),\(location.coordinate.latitude)"
        + "&key=\(apiKey)"
  )!
}
func HFWeather24hAPI(
    location: CLLocation,
    apiKey: String = HFWeatherKey
) -> URL {
  return URL(
    string: "https://devapi.qweather.com/v7/weather/24h?"
        + "location=\(location.coordinate.longitude),\(location.coordinate.latitude)"
        + "&key=\(apiKey)"
  )!
}

struct HFWeatherNow : Codable {
    let obsTime: Date
    let text: String
    let icon: String
    let temp: String
    let humidity: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        obsTime = try container.decode(Date.self, forKey: .obsTime)
        text = try container.decode(String.self, forKey: .text)
        let iconStr = try container.decode(String.self, forKey: .icon)
        icon = "svg".appending(iconStr)
        temp = try container.decode(String.self, forKey: .temp)
        humidity = try container.decode(String.self, forKey: .humidity)
    }
    init(obsTime: Date, text: String, icon: String, temp: String, humidity: String) {
        self.obsTime = obsTime
        self.text = text
        self.icon = "svg".appending(icon)
        self.temp = temp
        self.humidity = humidity
    }
    init(){
        self.init(obsTime: Date(), text: "", icon: "999", temp: "", humidity: "")
    }
}

struct HFWeather24h : Codable {
    let fxTime: Date
    let text: String
    let icon: String
    let temp: String
    let humidity: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fxTime = try container.decode(Date.self, forKey: .fxTime)
        text = try container.decode(String.self, forKey: .text)
        let iconStr = try container.decode(String.self, forKey: .icon)
        icon = "svg".appending(iconStr)
        temp = try container.decode(String.self, forKey: .temp)
        humidity = try container.decode(String.self, forKey: .humidity)
    }
    init(fxTime: Date, text: String, icon: String, temp: String, humidity: String) {
        self.fxTime = fxTime
        self.text = text
        self.icon = "svg".appending(icon)
        self.temp = temp
        self.humidity = humidity
    }
    init(){
        self.init(fxTime:Date(),  text: "", icon: "999", temp: "", humidity: "")
    }
}


struct HFWeatherNowResponse: Codable {
    let code: String
    let now: HFWeatherNow
    
}
struct HFWeather24hResponse: Codable {
    let code: String
    let hourly: [HFWeather24h]
    
}
func getHFWeather(location: CLLocation, handler: (@escaping (WeatherInfo) -> Void) ) {
    
    let sessionConfig = URLSessionConfiguration.default
    sessionConfig.requestCachePolicy = .reloadIgnoringLocalCacheData
    sessionConfig.urlCache = nil
    
    var request = URLRequest(url: HFWeatherNowAPI(location: location))
    request.httpMethod = "GET"
    request.setValue("UTF-8", forHTTPHeaderField:"Charset")
    request.setValue("application/json", forHTTPHeaderField:"Content-Type")
    
    var request2 = URLRequest(url: HFWeather24hAPI(location: location))
    request2.httpMethod = "GET"
    request2.setValue("UTF-8", forHTTPHeaderField:"Charset")
    request2.setValue("application/json", forHTTPHeaderField:"Content-Type")
    
    let decoder = JSONDecoder()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
    decoder.dateDecodingStrategy = .formatted(formatter)
    
    URLSession(configuration: sessionConfig).dataTask(with: request) { data, response, error in
        do {
            
            let result = try decoder.decode(HFWeatherNowResponse.self, from: data!)
            if(result.code == "200"){
                
                URLSession(configuration: sessionConfig).dataTask(with: request2) { data, response, error in
                    do {
                        
                        let result2 = try decoder.decode(HFWeather24hResponse.self, from: data!)
                        if(result2.code == "200"){
                            let hf = WeatherInfo(current: result.now, weathers: result2.hourly)
                            handler(hf)
                            
                        }else{
                            print("HF error \(result2.code)")
                            
            //                handler(HFWeather())
                        }
                        
                    } catch {
                        print("无法连接到服务器 \(error)")
            //            handler(HFWeather())
                    }
                }.resume()

                
            }else{
                print("HF error \(result.code)")
                
//                handler(HFWeather())
            }
            
        } catch {
            print("无法连接到服务器 \(error)")
//            handler(HFWeather())
        }
    }.resume()
    
}

class WidgetLocationManager: NSObject, CLLocationManagerDelegate {
    @AppStorage("LastLocation", store: UserDefaults(suiteName: "group.com.void.termiWatch"))
    var lastLocation: String = defaultCity{ // Beijing
        didSet{
            print("lastLocation didset")
        }
    }
    @AppStorage("LastLocationTime", store: UserDefaults(suiteName: "group.com.void.termiWatch"))
    var lastLocationTime: String = ""{
        didSet{
            print("LastLocationTime didset")
        }
    }


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
            
            let status = self.locationManager!.authorizationStatus
            print("location status \(status)")
            if status == .notDetermined {
                self.locationManager!.requestWhenInUseAuthorization()
            }
        }
    }
    
    func fetchLocation(handler: @escaping (CLLocation) -> Void) {
        self.handler = handler
        
        print("CL \(lastLocation) Time \(lastLocationTime)")

        let now:Double = Date().timeIntervalSince1970
        let last:Double = Double(lastLocationTime) ?? 0

        if( now - last < 3600*12){
            print("use cache Location")
            let location = CLLocation(string: lastLocation)
            handler(location)
            return
        }

        self.locationManager?.requestLocation()
        print("requestLocation")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
//        lastLati = location.coordinate.latitude
//        lastLong = location.coordinate.longitude
//
//        updateTime = Date()
        print("didUpdateLocations \(locations)")
//
//        UserDefaults.standard.set(lastLati, forKey: "LastLocation.lati")
//        UserDefaults.standard.set(lastLong, forKey: "LastLocation.long")
//        UserDefaults.standard.set(updateTime, forKey: "LastLocationTime")
        manager.stopUpdatingLocation()

        
        lastLocation = location.string()
        lastLocationTime = Date().since1970TimeIntervalString();
        
        self.handler!(location)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didUpdateLocations \(error)")
        let location = CLLocation(string: lastLocation)
        self.handler!(location)
    }
}

extension CLLocation{
    
    func string() -> String{
        return "\(self.coordinate.latitude),\(self.coordinate.longitude)"
    }
  
    convenience init(string: String){
        let array = string.components(separatedBy: CharacterSet(charactersIn: ","))
        let latitude = Double(array[0]) ?? 0
        let longitude = Double(array[1]) ?? 0
        
        self.init(latitude: latitude, longitude: longitude)
    }
    
}
extension Date{
    
    func since1970TimeIntervalString() -> String{
        return "\(timeIntervalSince1970)"
    }
    
    init(since1970: String){
        let time = TimeInterval(Double(since1970) ?? 0)
        self.init(timeIntervalSince1970: time)
    }
    
}
