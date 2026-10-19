//  NotificationUseCaseTests.swift
//  CoreNotificationTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreNotificationInterface
import XCTest

@testable import CoreNotification

final class NotificationUseCaseTests: XCTestCase {
    func testPushPreservesTriStateResultAndForwardsTokenAndDevice() async {
        for expected: Bool? in [true, false, nil] {
            let repository = NotificationRepositorySpy()
            repository.pushResult = .success(expected)
            let sut = NotificationUseCase(notificationRepository: repository)

            let result = await sut.pushFCMToken("token", deviceID: "device")

            XCTAssertEqual(result, expected)
            XCTAssertEqual(repository.tokens.count, 1)
            XCTAssertEqual(repository.tokens.first?.token, "token")
            XCTAssertEqual(repository.tokens.first?.deviceID, "device")
            XCTAssertTrue(repository.queries.isEmpty)
            XCTAssertEqual(repository.unreadCallCount, 0)
        }
    }

    func testPushForwardsMissingDeviceID() async {
        let repository = NotificationRepositorySpy()
        repository.pushResult = .success(true)
        let sut = NotificationUseCase(notificationRepository: repository)

        let result = await sut.pushFCMToken("token", deviceID: nil)

        XCTAssertEqual(result, true)
        XCTAssertEqual(repository.tokens.count, 1)
        XCTAssertNil(repository.tokens.first?.deviceID)
    }

    func testPushConvertsErrorsAndCancellationToFalse() async {
        for error: Error in [NotificationTestError.expected, CancellationError()] {
            let repository = NotificationRepositorySpy()
            repository.pushResult = .failure(error)
            let sut = NotificationUseCase(notificationRepository: repository)

            let result = await sut.pushFCMToken("token", deviceID: nil)

            XCTAssertEqual(result, false)
            XCTAssertEqual(repository.tokens.count, 1)
        }
    }

    func testListForwardsExplicitArgumentsAndReturnsPage() async throws {
        let repository = NotificationRepositorySpy()
        repository.pageResult = .success(NotificationTestFixture.page)
        let sut = NotificationUseCase(notificationRepository: repository)

        let page = try await sut.getNotifications(cursor: 99, size: 30, allRead: false)

        XCTAssertEqual(page, NotificationTestFixture.page)
        XCTAssertEqual(repository.queries.count, 1)
        XCTAssertEqual(repository.queries.first?.cursor, 99)
        XCTAssertEqual(repository.queries.first?.size, 30)
        XCTAssertEqual(repository.queries.first?.allRead, false)
        XCTAssertTrue(repository.tokens.isEmpty)
        XCTAssertEqual(repository.unreadCallCount, 0)
    }

    func testListDefaultArguments() async throws {
        let repository = NotificationRepositorySpy()
        repository.pageResult = .success(NotificationTestFixture.page)
        let sut = NotificationUseCase(notificationRepository: repository)

        _ = try await sut.getNotifications()

        XCTAssertEqual(repository.queries.count, 1)
        XCTAssertNil(repository.queries.first?.cursor)
        XCTAssertEqual(repository.queries.first?.size, 15)
        XCTAssertEqual(repository.queries.first?.allRead, true)
    }

    func testListPropagatesErrorsAndCancellation() async {
        for error: Error in [NotificationTestError.expected, CancellationError()] {
            let repository = NotificationRepositorySpy()
            repository.pageResult = .failure(error)
            let sut = NotificationUseCase(notificationRepository: repository)

            await XCTAssertThrowsErrorAsync({ try await sut.getNotifications() }) {
                XCTAssertEqual($0 as NSError, error as NSError)
            }
            XCTAssertEqual(repository.queries.count, 1)
        }
    }

    func testUnreadPreservesBothResultsWithoutOtherCalls() async throws {
        for expected in [true, false] {
            let repository = NotificationRepositorySpy()
            repository.unreadResult = .success(expected)
            let sut = NotificationUseCase(notificationRepository: repository)

            let result = try await sut.hasUnreadNotification()

            XCTAssertEqual(result, expected)
            XCTAssertEqual(repository.unreadCallCount, 1)
            XCTAssertTrue(repository.queries.isEmpty)
            XCTAssertTrue(repository.tokens.isEmpty)
        }
    }

    func testUnreadPropagatesErrorsAndCancellation() async {
        for error: Error in [NotificationTestError.expected, CancellationError()] {
            let repository = NotificationRepositorySpy()
            repository.unreadResult = .failure(error)
            let sut = NotificationUseCase(notificationRepository: repository)

            await XCTAssertThrowsErrorAsync({ try await sut.hasUnreadNotification() }) {
                XCTAssertEqual($0 as NSError, error as NSError)
            }
            XCTAssertEqual(repository.unreadCallCount, 1)
        }
    }
}
