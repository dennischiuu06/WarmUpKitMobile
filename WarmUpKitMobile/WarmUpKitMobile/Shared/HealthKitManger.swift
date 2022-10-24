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
    func didReceiveHealthKitEnergy(_ energy: Double)
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

            for x in 1...dayInt {
                let nextDay: Date = calendar.date(byAdding: .day, value: 1, to: thisDay)!
                // Plot the weekly step counts over the past 3 months
                statsCollection.enumerateStatistics(from: thisDay, to: thisDay) { statistics, stop in
                    if let quantity = statistics.sumQuantity() {
                        let _ = statistics.startDate
                        let value = quantity.doubleValue(for: HKUnit.count())
                        print("Dennis", value)
                        print("Dennis2", Double(x))
                        dataArray.append(value)
//                        let barEntry = BarChartDataEntry(x: (Double(x)), y: value)
//                        dataEntries.append(barEntry)

//                        let barEntry = BarChartDataEntry(x: (Double(i)), y: value)
//                        dataEntries.append(barEntry)
                        totalSteps += value
                        // Call a custom method to plot each data point.String(describing: )
                        
                    }
                }
                thisDay = nextDay
            }
            let avgSteps = totalSteps / Double(dayInt)

            self.delegate?.didReceiveHealthKitStepCounts(stepCounts: totalSteps, avgSteps: avgSteps, stepsData: dataArray)
        }
        
        healthStore.execute(query)

        
//        DispatchQueue.main.async {
//            self.summaryBoard.importData(iconKey: "walk_icon", title: "Steps", firstTitle: "Steps", firstContent: String(totalSteps), secondTitle: "Average Steps", secondContent: String(totalSteps / Double(dayInt)))
//        }
    }
    
    func getActiveEnergy() {
        let healthKitStore = HKHealthStore()
        if let energyType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned) {
            
            let startOfMonth = getStartDay()
            let endOfMonth = getEndDay(startOfMonth: startOfMonth)
            
            let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfMonth, options: .strictStartDate)
            
            let updateHandler = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, sample, error) -> Void in
                
                if let sample = sample {
                    let energy = sample.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0
                    self.delegate?.didReceiveHealthKitEnergy(energy)
                }
            }
            healthKitStore.execute(updateHandler)
        }
    }
//    func readEnergy() -> (kcal: String, energy: String) {
//        var kcal = ""
//        var energy = ""
//        guard let energyType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
//            print("Sample type not available")
//            return ("", "")
//        }
//
//        let now = Date()
//        let startOfDay = Calendar.current.startOfDay(for: now)
//        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
//
//        let energyQuery = HKSampleQuery(sampleType: energyType,predicate: predicate,limit: HKObjectQueryNoLimit,sortDescriptors: nil) {(query, sample, error) in
//            guard error == nil,let quantitySamples = sample as? [HKQuantitySample] else {
//                print("Something went wrong: \(error)")
//                return
//            }
//
//            let total = quantitySamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }
//            print("Total kcal: \(total)")
//            kcal = "\(total)"
//
//            DispatchQueue.main.async {
//                energy = String(format: "Energy: %.2f", total)
//            }
//
//        }
//        HKHealthStore().execute(energyQuery)
//
//        return (kcal, energy)
//    }
    
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
