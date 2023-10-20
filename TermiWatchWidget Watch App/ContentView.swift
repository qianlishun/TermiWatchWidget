//
//  ContentView.swift
//  WatchKitApp Watch App
//
//  Created by Qianlishun on 2023/10/10.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    let viewModel: QTermiViewModel

    var body: some View {
        VStack{
            WeatherRectangularView(weather: viewModel.weather)
            HealthRectangularView(health: viewModel.health)
        }
    }
}


#Preview {
    ContentView(viewModel: QTermiViewModel())
}
