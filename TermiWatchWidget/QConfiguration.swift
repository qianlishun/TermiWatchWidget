//
//  Config.swift
//  TermiWatchWidget
//
//  Created by Qianlishun on 2023/10/27.
//

import Foundation
import SwiftUI

/*
 如果配置了和风APIKey，则使用和风API代替WeatherKit
 https://dev.qweather.com
 中文 https://dev.qweather.com/docs/configuration/project-and-key/
 English https://dev.qweather.com/en/docs/configuration/project-and-key/
 */
let HFWeatherKey = ""

let terminalName = "void"
let leftTopImageName = "LeftTopImage"

let defaultCity = "39.9042, 116.4074" //  (纬度, 经度) (latitude,longitude)

/// 健康信息刷新间隔 单位：分钟。 按需调节，由于每天刷新有限制，设置过多的频次可能会导致刷新次数用尽后当天不再刷新。
/// Health info refresh interval, unit: minutes. On demand adjustment, due to the daily refresh limit, setting too many refresh frequencies may result in not refreshing again on the same day after the refresh times are exhausted.
let healthRefreshInterval = 15

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
let qRowHeight = 14.0
let qFontSize = 13.0
