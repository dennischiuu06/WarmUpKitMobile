//
//  HealthKitManager.swift
//  WarmUpKit
//
//  Created by dennis.k.chiu on 22/9/2022.
//

import Foundation
import HealthKit

protocol HeartRateDelegate {
    func heartRateUpdated(heartRateSamples: [HKSample])
}

protocol WorkoutTrackingDelegate {
    func didReceiveHealthKitEnergy(_ energy: Double, _ avgEnergy: Double)
    func didReceiveHealthKitStepCounts(stepCounts: Double, avgSteps: Double, stepsData: [Double])
}


class HealthKitManager: NSObject {
    static let shared = HealthKitManager()
    
    let healthStore = HKHealthStore()
    
    var heartRateDelegate: HeartRateDelegate?
    
    var delegate: WorkoutTrackingDelegate?

    var anchor: HKQueryAnchor?
    
    var date = Date()
    
    func authorizeHealthKitAccess(_ completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate),
              let footstep = HKObjectType.quantityType(forIdentifier: .stepCount),
              let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
              let height = HKObjectType.quantityType(forIdentifier: .height),
              let weight = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let energy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let healthKitTypesToShare = Set([HKObjectType.workoutType(), heartRateType])
        
        let healthKitTypesToRead: Set<HKObjectType> = [HKObjectType.workoutType(),
                                                       heartRateType,
                                                       footstep,
                                                       distance,
                                                       height,
                                                       weight,
                                                       energy]
        
        healthStore.requestAuthorization(toShare: healthKitTypesToShare, read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
    
    func getHealthKitStepsInfo() {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        let startOfMonth = getStartDay()
        let endOfMonth = getEndDay(startOfMonth: startOfMonth)
        let dayInt = getDayInt(endOfMonth: endOfMonth)
        
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** Unable to get the step count type ***")
        }
        
        var interval = DateComponents()
        interval.day = 1
        
        let calendar = Calendar.current
        //        let anchorDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: self.date)
        let anchorDate = calendar.date(bySetting: .day, value: 1, of: date)
        
        let query = HKStatisticsCollectionQuery.init(quantityType: stepCountType,
                                                     quantitySamplePredicate: nil,
                                                     options: .cumulativeSum,
                                                     anchorDate: anchorDate!,
                                                     intervalComponents: interval)
        
        query.initialResultsHandler = { query, results, error in
            guard let statsCollection = results else { return }
            var thisDay = startOfMonth
            
            var dataArray: [Double] = []

            var totalSteps = 0.0

            for _ in 1...dayInt {
                let nextDay: Date = calendar.date(byAdding: .day, value: 1, to: thisDay)!
                // Plot the weekly step counts over the past 3 months
                statsCollection.enumerateStatistics(from: thisDay, to: thisDay) { statistics, stop in
                    if let quantity = statistics.sumQuantity() {
                        let _ = statistics.startDate
                        let value = quantity.doubleValue(for: HKUnit.count())
                        
                        dataArray.append(value)
                        totalSteps += value
                    } else {
                        let defaultData = Double(0)
                    
                        dataArray.append(defaultData)
                    }
                }
                thisDay = nextDay
            }
            let avgSteps = totalSteps / Double(dayInt)

            self.delegate?.didReceiveHealthKitStepCounts(stepCounts: totalSteps, avgSteps: avgSteps, stepsData: dataArray)
        }
        
        healthStore.execute(query)

    }
    
    func getActiveEnergy() {
        let startOfMonth = getStartDay()
        let endOfMonth = getEndDay(startOfMonth: startOfMonth)
        let dayInt = getDayInt(endOfMonth: endOfMonth)
        
        let healthKitStore = HKHealthStore()
        var energy = 0.0
        if let energyType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned) {
            
            let startOfMonth = getStartDay()
            let endOfMonth = getEndDay(startOfMonth: startOfMonth)
            
            let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfMonth, options: .strictStartDate)
            
            let updateHandler = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, sample, error) -> Void in
                
                if let sample = sample {
                    energy = sample.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0
                    let avgEnergy = Double(dayInt)
                    self.delegate?.didReceiveHealthKitEnergy(energy, avgEnergy)

                }
            }
            

            healthKitStore.execute(updateHandler)
        }
    }
    
    func getTodaysHeartRates() {
       //predicate
        let healthKitStore = HKHealthStore()

       let calendar = NSCalendar.current
       let now = NSDate()
       let components = calendar.dateComponents([.year, .month, .day], from: now as Date)
       
        guard let startDate:NSDate = calendar.date(from: components) as NSDate? else { return }
        var dayComponent    = DateComponents()
        dayComponent.day    = 1
        let endDate:NSDate? = calendar.date(byAdding: dayComponent, to: startDate as Date) as NSDate?
        let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date?, options: [])
        
        //descriptor
        let sortDescriptors = [
                               NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
                             ]
        if let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) {
            
            let heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 25, sortDescriptors: sortDescriptors, resultsHandler: { (query, results, error) in
                guard error == nil else {
                    print("error")
                    return
                }
                print(results)
                
                guard let heartRateSamples = results as? [HKQuantitySample] else {
                    return
                }
                print(heartRateSamples)
                var datasourcett: [HKQuantitySample] = []

                datasourcett.append(contentsOf: heartRateSamples)
                print(datasourcett)
                
            }) //eo-query
            healthKitStore.execute(heartRateQuery)
        }
    }
    
    func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        guard let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return nil
        }
        
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate,
                                                        end: nil,
                                                        options: .strictEndDate)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        
        let heartRateQuery = HKAnchoredObjectQuery(type: heartRateType,
                                                   predicate: compoundPredicate,
                                                   anchor: nil,
                                                   limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) in
            guard let newAnchor = newAnchor,
                  let sampleObjects = sampleObjects else {
                      return
                  }
            self.anchor = newAnchor
            self.heartRateDelegate?.heartRateUpdated(heartRateSamples: sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            guard let newAnchor = newAnchor,
                  let sampleObjects = sampleObjects else { return }
            
            self.anchor = newAnchor
            self.heartRateDelegate?.heartRateUpdated(heartRateSamples: sampleObjects)
        }
        return heartRateQuery
    }
    
    func getMostRecentSample(for sampleType: HKSampleType,
                             completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
        
        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        
        let limit = 1
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            
            //2. Always dispatch to the main thread when complete.
            DispatchQueue.main.async {
                
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else {
                          
                          completion(nil, error)
                          return
                      }
                
                completion(mostRecentSample, nil)
            }
        }
        
        HKHealthStore().execute(sampleQuery)
    }
    
}

extension HealthKitManager {
    func getStartDay() -> Date {
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from: date)
        let startOfMonth = Calendar.current.date(from: comp)!
        return startOfMonth
    }
    
    func getEndDay(startOfMonth: Date) -> Date {
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.day = -1
        let endOfMonth = Calendar.current.date(byAdding: comps2, to: startOfMonth)
        
        return endOfMonth!
    }
    
    func getDayInt(endOfMonth: Date) -> Int {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "dd"
        let dayString = dayFormatter.string(from: endOfMonth)
        let dayInt = Int(dayString)
        return dayInt!
    }
}
