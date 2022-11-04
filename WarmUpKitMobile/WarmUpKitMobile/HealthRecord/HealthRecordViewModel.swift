//
//  HealthRecordViewModel.swift
//  WarmUpKitMobile
//
//  Created by dennis.k.chiu on 7/10/2022.
//

import Foundation
import HealthKit

struct HealthRecordViewModel {
    var datasource: [HKQuantitySample] = []

    var highestRate = "-"
    var lowestRate = "-"

}
