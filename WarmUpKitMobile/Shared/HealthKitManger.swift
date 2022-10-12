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
    
    func authorizeHealthKitAccess(_ completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        
        guard let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate),
            let footstep : HKObjectType = HKObjectType.quantityType(forIdentifier: .stepCount),
            let distance : HKObjectType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
            else {
                print("Could not get heart rate type")
                return
        }
        
        let typesToShare = Set([HKObjectType.workoutType(), heartRateType])
        let typesToRead = Set([HKObjectType.workoutType(),heartRateType, footstep,distance])
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            print("Was healthkit authorization successful? \(success) Errors: \(String(describing: error))")
            completion(success, error)
        }
    }
    
    
//    func authorizeHealthKitAccess(_ completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
//        //1. Check to see if HealthKit Is Available on this device
//        guard HKHealthStore.isHealthDataAvailable() else {
//            //          completion(false, HealthkitSetupError.notAvailableOnDevice)
//            return
//        }
//
//
//        guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
//              let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate),
//              let footstep = HKObjectType.quantityType(forIdentifier: .stepCount),
//              let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
//              let height = HKObjectType.quantityType(forIdentifier: .height),
//              let weight = HKObjectType.quantityType(forIdentifier: .bodyMass),
//              let energy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
//
//        let healthKitTypesToShare = Set([HKObjectType.workoutType(), heartRateType])
//
//        let healthKitTypesToRead: Set<HKObjectType> = [HKObjectType.workoutType(),
//                                                       dateOfBirth,
//                                                       heartRateType,
//                                                       footstep,
//                                                       distance,
//                                                       height,
//                                                       weight,
//                                                       energy]
//
//        healthStore.requestAuthorization(toShare: healthKitTypesToShare, read: healthKitTypesToRead) { (success, error) in
//            completion(success, error)
//        }
//    }
    
    func readStep(){
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            var resultCount = 0.0
            
            guard let result = result else {
                print("Failed to fetch steps rate")
                return
            }
            if let sum = result.sumQuantity() {
                resultCount = sum.doubleValue(for: HKUnit.count())
            }
            
            print("\(resultCount)")
            self.testing = "\(resultCount)"
        }
        healthStore.execute(query)
        
    }
    
    func readHeight(){
        let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        
        let heightquery = HKSampleQuery(sampleType: heightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) {
            (heightquery, results, error) in
            
            if let height = results?.last as? HKQuantitySample{
                //                DispatchQueue.main.async(execute: {()->Void in
                print("readHeight", "\(height.quantity)")
                //                    self.heightLabel.text = "\(height.quantity)"
                //                });
                
            }else{
                print("cannot get height data \n\(String(describing: results)), error == \(String(describing:   error))")
            }
        }
        healthStore.execute(heightquery)
    }
    
    
    func readEnergy() {
        guard let energyType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Sample type not available")
            return
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
            
            //            DispatchQueue.main.async {
            print("readEnergy", String(format: "Energy: %.2f", total))
            //                self.testing = String(format: "Energy: %.2f", total)
            //            }
        }
        HKHealthStore().execute(energyQuery)
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

