//
//  HealthPermissionService.swift
//  CoreHealth
//
//  Created by 김동준 on 8/4/26.
//

import CoreHealthInterface
import HealthKit

public struct HealthPermissionService: HealthPermissionInterface {
    private let healthStore: HKHealthStore

    public init() {
        self.healthStore = HKHealthStore()
    }

    public func shouldShowHealthPermissionPrompt() async -> Bool {
        guard
            HKHealthStore.isHealthDataAvailable(),
            let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)
        else { return false }

        do {
            let status = try await healthStore.statusForAuthorizationRequest(
                toShare: [],
                read: [stepCountType]
            )
            return status == .shouldRequest
        } catch {
            return false
        }
    }

    public func requestHealthPermission() async -> Bool {
        guard
            HKHealthStore.isHealthDataAvailable(),
            let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)
        else { return false }

        do {
            try await healthStore.requestAuthorization(
                toShare: [],
                read: [stepCountType]
            )
            return true
        } catch {
            return false
        }
    }
}
