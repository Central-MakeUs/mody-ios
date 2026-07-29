//
//  MyPageNotificationSettingRepository.swift
//  MyPage
//
//  Created by 김동준 on 7/19/26.
//

import CommonDomain
import CoreNetworkInterface

public struct MyPageNotificationSettingRepository: MyPageNotificationSettingRepositoryProtocol {
    private let network: CoreNetworkProtocol

    public init(network: CoreNetworkProtocol) {
        self.network = network
    }

    public func getNotificationSettings() async throws -> NotificationSettingState {
        let endpoint = MyPageEndpoint.getNotificationSettings()
        let response: CoreNetworkResponse<NotificationSettingResponse> = try await network.request(endpoint)

        guard let notificationSetting = response.result?.toDomain() else {
            throw NetworkError.invalidResponse
        }

        return notificationSetting
    }

    public func patchNotificationSettings(_ notificationSetting: NotificationSettingState) async throws -> NotificationSettingState {
        let request = NotificationSettingRequest(state: notificationSetting)
        let endpoint = MyPageEndpoint.patchNotificationSettings(request: request)
        let response: CoreNetworkResponse<NotificationSettingResponse> = try await network.request(endpoint)

        guard let updatedNotificationSetting = response.result?.toDomain() else {
            throw NetworkError.invalidResponse
        }

        return updatedNotificationSetting
    }

    public func putSchedules(mealSchedules: [MealScheduleRequest], exerciseSchedules: [ExerciseScheduleRequest]) async throws {
        let request = MealAndExerciseScheduleRequest(mealSchedules: mealSchedules, exerciseSchedules: exerciseSchedules)
        let endpoint = MyPageEndpoint.putSchedules(request: request)
        let _: CoreNetworkResponse<CoreNetworkEmptyResponse> = try await network.request(endpoint)
    }
}
