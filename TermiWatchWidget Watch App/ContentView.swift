//
//  ContentView.swift
//  WatchKitApp Watch App
//
//  Created by Qianlishun on 2023/10/10.
//

import SwiftUI
//import HealthKit

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }

    init() {
//        healthStore.requestAuthorization(toShare: nil, read: hkDataTypesOfInterest) { result,error in
//            print(result.description + " \n " + (error?.localizedDescription ?? ""))
//            Task{
//              let health = await HealthObserver().getHealthInfo()
//                print(health.description())
//            }
//        }
     
    }
    
//    let healthStore = HKHealthStore()
//    let hkDataTypesOfInterest = Set([
//        HKObjectType.activitySummaryType(),
//        HKCategoryType.categoryType(forIdentifier: .appleStandHour)!,
//        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
//        HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
//        HKObjectType.quantityType(forIdentifier: .heartRate)!,
//        HKObjectType.quantityType(forIdentifier: .stepCount)!,
//    ])
}


#Preview {
    ContentView()
}
