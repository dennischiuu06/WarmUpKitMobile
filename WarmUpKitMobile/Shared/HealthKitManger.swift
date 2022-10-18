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

class HealthKitManager: NSObject {
    
    static let shared = HealthKitManager()
    
    let healthStore = HKHealthStore()
    
    var heartRateDelegate: HeartRateDelegate?
    
    var anchor: HKQueryAnchor?
    
    var testing = ""
    var date = Date()
    
    func authorizeHealthKitAccess(_ completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        //        //1. Check to see if HealthKit Is Available on this device
        //        guard HKHealthStore.isHealthDataAvailable() else {
        //            //          completion(false, HealthkitSetupError.notAvailableOnDevice)
        //            return
        //        }
        
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
    
    //    func readStep(){
    //        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    //
    //        let now = Date()
    //        let startOfDay = Calendar.current.startOfDay(for: now)
    //        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
    //
    //        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
    //            var resultCount = 0.0
    //
    //            guard let result = result else {
    //                print("Failed to fetch steps rate")
    //                return
    //            }
    //            if let sum = result.sumQuantity() {
    //                resultCount = sum.doubleValue(for: HKUnit.count())
    //            }
    //
    //            print("\(resultCount)")
    //            self.testing = "\(resultCount)"
    //        }
    //        healthStore.execute(query)
    //
    //    }
    //
    //
    //    func readEnergy() {
    //        guard let energyType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
    //            print("Sample type not available")
    //            return
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
    //
    //            }
    //            let total = quantitySamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }
    //            print("Total kcal: \(total)")
    //
    //            //            DispatchQueue.main.async {
    //            print("readEnergy", String(format: "Energy: %.2f", total))
    //            //                self.testing = String(format: "Energy: %.2f", total)
    //            //            }
    //        }
    //        HKHealthStore().execute(energyQuery)
    //    }
    
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
    
    func readStep() -> (totalSteps: String, avgSteps: String) {
        guard HKHealthStore.isHealthDataAvailable() else {
            //          completion(false, HealthkitSetupError.notAvailableOnDevice)
            return ("", "")
        }
        var steps = ""
        var avgSteps = ""
        
        let startOfMonth = getStartDay()
        let endOfMonth = getEndDay(startOfMonth: startOfMonth)
        let dayInt = getDayInt(endOfMonth: endOfMonth)
        print("startOfMonth", startOfMonth)
        print("endOfMonth", endOfMonth)
        print("dayInt", dayInt)
        
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
        
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                // Perform proper error handling here
                return
            }
            //            var dataEntries = [BarChartDataEntry]()
            
            var thisDay = startOfMonth
            var totalSteps = 0.0
            for _ in 1...dayInt {
                var nextDay: Date = calendar.date(byAdding: .day, value: 1, to: thisDay)!
                // Plot the weekly step counts over the past 3 months
                statsCollection.enumerateStatistics(from: thisDay, to: thisDay) { [weak self] statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        let _ = statistics.startDate
                        let value = quantity.doubleValue(for: HKUnit.count())
                        
                        //                        let barEntry = BarChartDataEntry(x: (Double(i)), y: value)
                        //                        dataEntries.append(barEntry)
                        totalSteps += value
                        // Call a custom method to plot each data point.String(describing: )
                        
                    }
                }
                thisDay = nextDay
            }
            
            steps = String(totalSteps)
            avgSteps = String(totalSteps / Double(dayInt))
            DispatchQueue.main.async {
                
                print(totalSteps)
                //                self.sumStep = totalSteps
                //                self.sumStepLabel.text = "\(Int(self.sumStep))"
                print(totalSteps / Double(dayInt))
                //                self.readDistanceWalkAndRun()
            }
            
            //            let chartDataSet = BarChartDataSet(values: dataEntries, label: "Steps")
            //            chartDataSet.drawValuesEnabled = false
            //            chartDataSet.notifyDataSetChanged()
            //            let chartData = BarChartData(dataSets: [chartDataSet])
            //            chartData.barWidth = 0.5
            //            chartData.notifyDataChanged()
            //            self.barChartView.data = chartData
            //            self.barChartView.notifyDataSetChanged()
            //            self.barChartView!.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
            //            print("after chartView height : \(self.chartView.bounds.height)")
            //            print("after barchartView height : \(self.barChartPlace.bounds.height)")
            //
            //            print("barchart x:\(self.barChartView.bounds.origin.x) y:\(self.barChartView.bounds.origin.y) width:\(self.barChartView.bounds.width) height:\(self.barChartView.bounds.height)")
        }
        healthStore.execute(query)
        
        return (steps, avgSteps)
    }
    
    func readEnergy() -> (kcal: String, energy: String) {
        var kcal = ""
        var energy = ""
        guard let energyType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Sample type not available")
            return ("", "")
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let energyQuery = HKSampleQuery(sampleType: energyType,predicate: predicate,limit: HKObjectQueryNoLimit,sortDescriptors: nil) {(query, sample, error) in
            guard error == nil,let quantitySamples = sample as? [HKQuantitySample] else {
                print("Something went wrong: \(error)")
                return
            }
            
            let total = quantitySamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }
            print("Total kcal: \(total)")
            kcal = "\(total)"
            
            DispatchQueue.main.async {
                energy = String(format: "Energy: %.2f", total)
            }
            
        }
        HKHealthStore().execute(energyQuery)
        
        return (kcal, energy)
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

