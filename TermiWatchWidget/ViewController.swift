//
//  ViewController.swift
//  TermiWatchWidget
//
//  Created by Qianlishun on 2023/10/10.
//

import UIKit
import CoreLocation
import HealthKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        CLLocationManager().requestWhenInUseAuthorization()
        healthStore.requestAuthorization(toShare: nil, read: hkDataTypesOfInterest) { result,error in
            print(result.description + " \n " + (error?.localizedDescription ?? ""))
        }

    }

    let healthStore = HKHealthStore()
    let hkDataTypesOfInterest = Set([
        HKObjectType.activitySummaryType(),
        HKCategoryType.categoryType(forIdentifier: .appleStandHour)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
    ])
}

