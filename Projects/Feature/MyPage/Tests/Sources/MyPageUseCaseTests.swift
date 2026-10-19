//
//  MyPageUseCaseTests.swift
//  MyPageTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import XCTest
@testable import MyPage

final class MyPageUseCaseTests: XCTestCase {
    func testProfileAndWeightResultsAndRequestsAreForwarded() async throws {
        let repository = MyPageRepositorySpy()
        let sut = MyPageUseCase(myPageRepository: repository)
        let profile = try await sut.fetchMyPageProfile()
        let weight = try await sut.getWeightRecord()
        let request = MyPageProfileUpdateRequest(nickname: "새 이름", birthDate: "2001-02-03", imageKey: "profile/key")
        try await sut.updateMyPageProfile(request)
        try await sut.recordWeight(recordedOn: "2026-10-05", weightKg: 70.5)

        XCTAssertEqual(profile, MyPageFixture.profile)
        XCTAssertEqual(weight, MyPageFixture.weight)
        XCTAssertEqual(repository.profileFetchCount, 1)
        XCTAssertEqual(repository.weightFetchCount, 1)
        XCTAssertEqual(repository.profileRequests, [request])
        XCTAssertEqual(repository.weightRequests.count, 1)
        XCTAssertEqual(repository.weightRequests.first?.recordedOn, "2026-10-05")
        XCTAssertEqual(repository.weightRequests.first?.weightKg, 70.5)
    }

    func testRepositoryErrorsArePreserved() async {
        let repository = MyPageRepositorySpy()
        repository.profileResult = .failure(NetworkError.networkUnavailable)
        repository.weightResult = .failure(NetworkError.networkUnavailable)
        repository.updateResult = .failure(NetworkError.networkUnavailable)
        let sut = MyPageUseCase(myPageRepository: repository)
        let operations: [() async throws -> Void] = [
            { _ = try await sut.fetchMyPageProfile() },
            { _ = try await sut.getWeightRecord() },
            { try await sut.updateMyPageProfile(.init(nickname: "모디", birthDate: "2000-01-02")) },
            { try await sut.recordWeight(recordedOn: "2026-10-05", weightKg: 70) }
        ]
        for operation in operations {
            do { try await operation(); XCTFail("Expected repository error") }
            catch { XCTAssertEqual(error as? NetworkError, .networkUnavailable) }
        }
    }

    func testNotificationUseCaseForwardsSettingsAndSchedules() async throws {
        let repository = MyPageNotificationRepositorySpy()
        let sut = MyPageNotificationSettingUseCase(repository: repository)
        let settings = MyPageFixture.settings
        let fetched = try await sut.fetchNotificationSettings()
        let updated = try await sut.updateNotificationSettings(settings)
        try await sut.updateSchedules(mealSchedules: settings.mealSchedules, exerciseSchedules: settings.exerciseSchedules)

        XCTAssertEqual(fetched, settings)
        XCTAssertEqual(updated, settings)
        XCTAssertEqual(repository.fetchCount, 1)
        XCTAssertEqual(repository.updates, [settings])
        XCTAssertEqual(repository.schedules.count, 1)
        XCTAssertEqual(repository.schedules.first?.meals, settings.mealSchedules)
        XCTAssertEqual(repository.schedules.first?.exercises, settings.exerciseSchedules)
    }

    func testNotificationUseCasePreservesFailures() async {
        let repository = MyPageNotificationRepositorySpy()
        repository.fetchResult = .failure(NetworkError.networkUnavailable)
        repository.updateError = NetworkError.networkUnavailable
        let sut = MyPageNotificationSettingUseCase(repository: repository)
        let operations: [() async throws -> Void] = [
            { _ = try await sut.fetchNotificationSettings() },
            { _ = try await sut.updateNotificationSettings(MyPageFixture.settings) },
            { try await sut.updateSchedules(mealSchedules: [], exerciseSchedules: []) }
        ]
        for operation in operations {
            do { try await operation(); XCTFail("Expected repository error") }
            catch { XCTAssertEqual(error as? NetworkError, .networkUnavailable) }
        }
    }
}
