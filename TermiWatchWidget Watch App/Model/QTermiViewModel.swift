//
//  QTermiViewModel.swift
//  TermiWatchWidget
//
//  Created by Qianlishun on 2023/10/16.
//

import Foundation

@Observable
class QTermiViewModel {
    var health = HealthInfo()
    var weather = WeatherViewInfo()
    
    let healthObserver = HealthObserver()
    let widgetLocationManager = WidgetLocationManager()

    func updateModel(){
        
        widgetLocationManager.fetchLocation(handler: { location in
            Task{
                let weather = try await getWeather(location: location, afterHours: 2)
                DispatchQueue.main.async {
                    self.weather = WeatherViewInfo(current: weather.weathers[0], after1Hours: weather.weathers[1],alert: weather.alerts[0])
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
