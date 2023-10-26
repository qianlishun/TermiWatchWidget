//
//  QTermiViewModel.swift
//  TermiWatchWidget
//
//  Created by Qianlishun on 2023/10/16.
//

import Foundation

//  如果这里报错，要兼容iOS17以下，true 修改为 false
//  If an error is reported here, it should be compatible with iOS17 or below, and true should be changed to false
#if true
@Observable
class QTermiViewModel {
    var health = HealthInfo()
    var weather = WeatherViewInfo()
    
    let healthObserver = HealthObserver()
    let widgetLocationManager = WidgetLocationManager()

    func updateModel(){
        
        widgetLocationManager.fetchLocation(handler: { location in
            Task{
                if(HFWeatherKey.count==0){
                    let weather = try await getWeather(location: location, afterHours: 2)
                    DispatchQueue.main.async {
                        self.weather = WeatherViewInfo(current: weather.weathers[0], after1Hours: weather.weathers[1],alert: weather.alerts[0])
                    }
                }else{
                    getHFWeather(location: location) { weather in
                        self.weather = WeatherViewInfo(current: weather.weathers[0], after1Hours: weather.weathers[1],alert: weather.alerts[0])
                    }
                }
            }
        })
             
        healthObserver.getHealthInfo { health in
            DispatchQueue.main.async {
                self.health = health
            }
        }
        
    }
}
#else

final class QTermiViewModel: ObservableObject {
    @Published var health = HealthInfo()
    @Published var weather = WeatherViewInfo()

    let healthObserver = HealthObserver()
    let widgetLocationManager = WidgetLocationManager()

    func updateModel(){
        
        widgetLocationManager.fetchLocation(handler: { location in
            Task{
                if(HFWeatherKey.count==0){
                    let weather = try await getWeather(location: location, afterHours: 2)
                    DispatchQueue.main.async {
                        self.weather = WeatherViewInfo(current: weather.weathers[0], after1Hours: weather.weathers[1],alert: weather.alerts[0])
                    }
                }else{
                    getHFWeather(location: location) { weather in
                        self.weather = WeatherViewInfo(current: weather.weathers[0], after1Hours: weather.weathers[1],alert: weather.alerts[0])
                    }
                }
            }
        })
             
        healthObserver.getHealthInfo { health in
            DispatchQueue.main.async {
                self.health = health
            }
        }
        
    }
}

#endif
