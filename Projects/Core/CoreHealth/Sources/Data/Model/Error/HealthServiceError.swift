//
//  HealthServiceError.swift
//  CoreHealth
//
//  Created by 김동준 on 8/5/26.
//

import Foundation

enum HealthServiceError: Error {
    case healthDataUnavailable
    case stepCountTypeUnavailable
    case dateRangeCalculationFailed
}
