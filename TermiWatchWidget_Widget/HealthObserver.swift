//
//  EnergyObserver.swift
//  Calories
//
//  Created by MacBook Pro M1 on 2022/02/21.
//

import HealthKit

struct HealthInfo {
    let steps: Int
    let excercise: Int
    let excerciseTime: Int
    let standHours: Int
    let heartRate: Int
    
    init(steps: Int, excercise: Int, excerciseTime: Int, standHours: Int, heartRate: Int) {
        self.steps = steps
        self.excercise = excercise
        self.excerciseTime = excerciseTime
        self.standHours = standHours
        self.heartRate = heartRate
    }
    
    init(){
        self.init(steps: 0, excercise: 0, excerciseTime: 0, standHours: 0, heartRate: 0)
    }
  
    func description() -> String {
        return "Steps:  \t\(steps)\n"
            +  "excercise:  \t\(excercise)\n"
            +  "excerciseTime:  \t\(excerciseTime)\n"
            +  "standHours:  \t\(standHours)\n"
            +  "heartRate:  \t\(heartRate)\n"
    }

}

// MARK: - HealthObserver
class HealthObserver {
    /// - Tag: Health Store
    let healthStore: HKHealthStore
    
    let hkDataTypesOfInterest = Set([
        HKObjectType.activitySummaryType(),
        HKCategoryType.categoryType(forIdentifier: .appleStandHour)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
    ])
    
    init() {
        self.healthStore = HKHealthStore()
        healthStore.requestAuthorization(toShare: nil, read: hkDataTypesOfInterest) { result,error in
            print(result.description + " \n " + (error?.localizedDescription ?? ""))
        }
    }
    
    func fetchSample(quantityType: HKQuantityType, unit: HKUnit, completion: @escaping (Int) -> ()){
     
        let predicate = HKQuery.predicateForSamples(
          withStart: .distantPast,
          end: Date(),
          options: .strictEndDate
        )

        let sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(
          key: HKSampleSortIdentifierStartDate,
          ascending: false
        )]
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: 1, sortDescriptors: sortDescriptors) {
            (query, results, error) in
            if error != nil {
                print(error.debugDescription)
                   // 处理错误
            } else if let results = results {
//               for sample in results {
                if let quantitySample = results.first as? HKQuantitySample {
                   let value = quantitySample.quantity.doubleValue(for: unit)
//                   print("\(quantityType.identifier),\(quantityType.description), \(value) \(unit.unitString)")
                   completion(Int(value))
               }
//               }
            }
        }
        healthStore.execute(query)
    }
    
    func fetchActivitySummary( completion: @escaping (HKActivitySummary) -> ()){
        let predicate = HKQuery.predicateForActivitySummary(
            with: DateComponents(components: [.year, .month, .day], date: Date())
        )
        let query = HKActivitySummaryQuery(predicate: predicate) { query, results, error in
            
            if error != nil {
                   // 处理错误
            } else if let results = results {
                completion(results.first ?? HKActivitySummary())
            }
        }
        healthStore.execute(query)
    }
    func subscribeToActivitySummary(sampleType: HKSampleType,completion: @escaping (_ summary: HKActivitySummary) -> Void){
        
        var isStop = false

        let query = HKObserverQuery(
            sampleType: sampleType,
            predicate: nil
        ) { _, _, error in
            guard error == nil else {
                print(error!)
                
                return
            }
            if(!isStop){
                self.fetchActivitySummary { summary in
                    completion(summary)
                }
                isStop = true
            }
            
        }
        
        healthStore.execute(query)
    }
    
    func fetchStatistics(
        quantityType: HKQuantityType,
        options: HKStatisticsOptions,
        startDate: Date,
        endDate: Date,
        interval: DateComponents,
        completion: @escaping (HKStatistics) -> () ){

        let query = HKStatisticsCollectionQuery(
          quantityType: quantityType,
          quantitySamplePredicate: nil,
          options: options,
          anchorDate: startDate,
          intervalComponents: interval
        )

        query.initialResultsHandler = { query, collection, error in
            guard let statsCollection = collection else {
                return
            }
            
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { stats, stop in
                completion(stats)
            }
        }

        healthStore.execute(query)
    }
    
    func subscribeToStatisticsForToday(
      forQuantityType quantityType:
      HKQuantityType,
      unit: HKUnit,
      options: HKStatisticsOptions,
      healthStore: HKHealthStore = .init(),
      completion: @escaping (Int) -> Void) {
      
          let query = HKObserverQuery(
            sampleType: quantityType,
            predicate: nil
          ) { _, _, error in
                guard error == nil else {
                  print(error!)

                  return
                }

                  self.fetchStatistics(quantityType: quantityType, options: options, startDate: Calendar.current.startOfDay(for: Date()) , endDate: Date(), interval: DateComponents(day: 1)) { stats in
                      let value = stats.sumQuantity()?.doubleValue(for: unit) ?? 0
                      completion(Int(value))
                  }
          }

          healthStore.execute(query)
    }
}

// MARK: - HealthObserver extension : Keep
extension HealthObserver {
    
    func getHealthInfo(completion: @escaping (HealthInfo) -> ()) {
        print("getHealthInfo...")

        let group = DispatchGroup.init()
        let queue = DispatchQueue.global()
        
        var _steps = 0
        var _excercise = 0
        var _excerciseTime = 0
        var _standHours = 0
        var _heartRate = 0
        
        queue.async(group: group, execute: {
            group.enter()
            self.getCurrentSteps { steps in
                _steps = steps
                group.leave()
                print("getCurrentSteps done")
            }
        })
        queue.async(group: group, execute: {
            group.enter()
            self.getActiveEnergyBurned { excercise in
                _excercise = excercise
                group.leave()
                print("getActiveEnergyBurned done")
            }
        })
        queue.async(group: group, execute: {
            group.enter()
            self.getExerciseTime { excerciseTime in
                _excerciseTime = excerciseTime
                group.leave()
                print("getExerciseTime done")
            }
        })
        queue.async(group: group, execute: {
            group.enter()
            self.getStandHours { standHours in
                _standHours = standHours
                group.leave()
                print("getStandHours done")
            }
        })
        queue.async(group: group, execute: {
            group.enter()
            self.getHeartRate { heartRate in
                _heartRate = heartRate
                group.leave()
                print("getHeartRate done")
            }
        })
        
        group.notify(queue: queue){
            let health = HealthInfo(steps: _steps, excercise: _excercise, excerciseTime: _excerciseTime, standHours: _standHours, heartRate: _heartRate)
            
            print(health)
            completion(health)
        }
    }
    
   
    func getCurrentSteps(completion: @escaping (Int) -> ()) {
        let type: HKQuantityType = HKQuantityType(HKQuantityTypeIdentifier.stepCount)
        print("getCurrentSteps")

        subscribeToStatisticsForToday(forQuantityType: type, unit: HKUnit.count(), options: .cumulativeSum, completion: completion)
    }
    
    func getActiveEnergyBurned(completion: @escaping(Int) -> ()){
        print("getActiveEnergyBurned")
        
        subscribeToActivitySummary(sampleType: HKQuantityType(HKQuantityTypeIdentifier.activeEnergyBurned)) { summary in
            
            let excerciseValue = summary.activeEnergyBurned.doubleValue(
              for: HKUnit.kilocalorie()
            )
            completion(Int(excerciseValue))
        }
    }
    
    func getExerciseTime(completion: @escaping(Int) -> ()){
        print("getExerciseTime")

        subscribeToActivitySummary(sampleType: HKQuantityType(HKQuantityTypeIdentifier.appleExerciseTime)) { summary in
            
            let time = summary.appleExerciseTime.doubleValue(
              for: HKUnit.minute()
            )
            completion(Int(time))
        }
    }
    
    func getStandHours(completion: @escaping(Int) -> ()){
        print("getStandHours")

        subscribeToActivitySummary(sampleType:HKCategoryType(.appleStandHour)) { summary in
            
            let stamd = summary.appleStandHours.doubleValue(
              for: HKUnit.count()
            )
            completion(Int(stamd))
        }
    }

    func getHeartRate(completion: @escaping(Int) -> ()){
        print("getHeartRate")

        fetchSample(quantityType: HKQuantityType(.heartRate), unit: HKUnit(from: "count/min"), completion: completion)
    }

}

extension DateComponents {
  init(
    calendar: Calendar = .autoupdatingCurrent,
    components: Set<Calendar.Component>,
    date: Date
  ) {
    self = calendar.dateComponents(components, from: date)
    self.calendar = calendar
  }
}
