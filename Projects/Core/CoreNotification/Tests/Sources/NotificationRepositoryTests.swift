//  NotificationRepositoryTests.swift
//  CoreNotificationTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreKeyChainStorageInterface
import CoreNetworkTesting
import CoreNotificationInterface
import XCTest

@testable import CoreNotification

final class NotificationRepositoryTests: XCTestCase {
    func testMatchingTokenSkipsNetworkAndSaveEvenWhenDeviceChanges() async throws {
        let network = NotificationNetworkSpy()
        network.error = NotificationTestError.unexpectedCall
        let storage = NotificationKeyChainSpy()
        storage.token = "same"
        let sut = makeSUT(network: network, storage: storage)

        let result = try await sut.postPushFCMToken("same", deviceID: "new-device")

        XCTAssertNil(result)
        XCTAssertEqual(storage.readKeys, [KeyChainStorageKey.fcmToken.rawValue])
        XCTAssertTrue(network.endpoints.isEmpty)
        XCTAssertTrue(storage.savedTokens.isEmpty)
    }

    func testNewAndChangedTokensRegisterAndPersist() async throws {
        for existing: String? in [nil, "old"] {
            let network = NotificationNetworkSpy()
            network.response = try CoreNetworkJSONFixture.response()
            let storage = NotificationKeyChainSpy()
            storage.token = existing
            let sut = makeSUT(network: network, storage: storage)

            let result = try await sut.postPushFCMToken("new", deviceID: "device")

            XCTAssertEqual(result, true)
            XCTAssertEqual(network.endpoints.count, 1)
            let endpoint = try XCTUnwrap(network.endpoints.first)
            XCTAssertEqual(endpoint.path, "api/v1/notifications/push-token")
            XCTAssertEqual(endpoint.method, .POST)
            let body = try CoreNetworkJSONFixture.body(of: endpoint)
            XCTAssertEqual(body as NSDictionary, ["deviceId": "device", "platform": "IOS", "fcmToken": "new"] as NSDictionary)
            XCTAssertEqual(storage.token, "new")
            XCTAssertEqual(storage.savedTokens.count, 1)
            XCTAssertEqual(storage.savedTokens.first?.key, KeyChainStorageKey.fcmToken.rawValue)
            XCTAssertEqual(storage.savedTokens.first?.value, "new")
        }
    }

    func testSuccessfulRegistrationDeduplicatesNextCall() async throws {
        let network = NotificationNetworkSpy()
        network.response = try CoreNetworkJSONFixture.response()
        let storage = NotificationKeyChainSpy()
        let sut = makeSUT(network: network, storage: storage)

        let first = try await sut.postPushFCMToken("token", deviceID: nil)
        let second = try await sut.postPushFCMToken("token", deviceID: nil)

        XCTAssertEqual(first, true)
        XCTAssertNil(second)
        XCTAssertEqual(network.endpoints.count, 1)
        XCTAssertEqual(storage.readKeys.count, 2)
        XCTAssertEqual(storage.savedTokens.count, 1)
        let body = try CoreNetworkJSONFixture.body(of: XCTUnwrap(network.endpoints.first))
        XCTAssertNil(body["deviceId"])
    }

    func testReadFailureStillAttemptsRegistration() async throws {
        let network = NotificationNetworkSpy()
        network.response = try CoreNetworkJSONFixture.response()
        let storage = NotificationKeyChainSpy()
        storage.token = "same"
        storage.readError = NotificationTestError.expected
        let sut = makeSUT(network: network, storage: storage)

        let result = try await sut.postPushFCMToken("same", deviceID: nil)

        XCTAssertEqual(result, true)
        XCTAssertEqual(network.endpoints.count, 1)
        XCTAssertEqual(storage.readKeys.count, 1)
        XCTAssertEqual(storage.savedTokens.count, 1)
    }

    func testRegistrationErrorOrCancellationReturnsFalseWithoutSaving() async throws {
        for error: Error in [NotificationTestError.expected, CancellationError()] {
            let network = NotificationNetworkSpy()
            network.error = error
            let storage = NotificationKeyChainSpy()
            storage.token = "old"
            let sut = makeSUT(network: network, storage: storage)

            let result = try await sut.postPushFCMToken("new", deviceID: nil)

            XCTAssertEqual(result, false)
            XCTAssertEqual(network.endpoints.count, 1)
            XCTAssertEqual(storage.token, "old")
            XCTAssertTrue(storage.savedTokens.isEmpty)
        }
    }

    func testMalformedRegistrationResponseReturnsFalseWithoutSaving() async throws {
        let network = NotificationNetworkSpy()
        network.response = Data("invalid".utf8)
        let storage = NotificationKeyChainSpy()
        let sut = makeSUT(network: network, storage: storage)

        let result = try await sut.postPushFCMToken("new", deviceID: nil)

        XCTAssertEqual(result, false)
        XCTAssertTrue(storage.savedTokens.isEmpty)
    }

    func testSaveFailureReturnsFalseAndNextCallRetriesRegistration() async throws {
        let network = NotificationNetworkSpy()
        network.response = try CoreNetworkJSONFixture.response()
        let storage = NotificationKeyChainSpy()
        storage.token = "old"
        storage.saveError = NotificationTestError.expected
        let sut = makeSUT(network: network, storage: storage)

        let first = try await sut.postPushFCMToken("new", deviceID: nil)
        storage.saveError = nil
        let second = try await sut.postPushFCMToken("new", deviceID: nil)

        XCTAssertEqual(first, false)
        XCTAssertEqual(second, true)
        XCTAssertEqual(network.endpoints.count, 2)
        XCTAssertEqual(storage.savedTokens.count, 2)
        XCTAssertEqual(storage.token, "new")
    }

    func testListMapsPageAndDoesNotTouchStorage() async throws {
        let network = NotificationNetworkSpy()
        network.response = try CoreNetworkJSONFixture.response(result: NotificationTestFixture.list)
        let storage = NotificationKeyChainSpy()
        let sut = makeSUT(network: network, storage: storage)

        let page = try await sut.getNotifications(cursor: 100, size: 30, allRead: false)

        XCTAssertEqual(page, NotificationTestFixture.page)
        XCTAssertEqual(network.endpoints.count, 1)
        XCTAssertEqual(network.endpoints.first?.path, "api/v1/notifications")
        XCTAssertEqual(network.endpoints.first?.queryParameters, ["cursor": "100", "size": "30", "allRead": "false"])
        XCTAssertTrue(storage.readKeys.isEmpty)
        XCTAssertTrue(storage.savedTokens.isEmpty)
    }

    func testUnreadMapsTrueFalseAndMissingFieldWithoutStorageAccess() async throws {
        for result: [String: Any] in [["hasUnread": true], ["hasUnread": false], [:]] {
            let network = NotificationNetworkSpy()
            network.response = try CoreNetworkJSONFixture.response(result: result)
            let storage = NotificationKeyChainSpy()
            let sut = makeSUT(network: network, storage: storage)

            let unread = try await sut.hasUnreadNotification()

            XCTAssertEqual(unread, result["hasUnread"] as? Bool ?? false)
            XCTAssertEqual(network.endpoints.count, 1)
            XCTAssertEqual(network.endpoints.first?.path, "api/v1/notifications/unread-exists")
            XCTAssertTrue(storage.readKeys.isEmpty)
            XCTAssertTrue(storage.savedTokens.isEmpty)
        }
    }

    func testListAndUnreadPropagateErrorsAndCancellation() async {
        for error: Error in [NotificationTestError.expected, CancellationError()] {
            let network = NotificationNetworkSpy()
            network.error = error
            let storage = NotificationKeyChainSpy()
            let sut = makeSUT(network: network, storage: storage)

            await XCTAssertThrowsErrorAsync({ try await sut.getNotifications(cursor: nil, size: 15, allRead: true) }) {
                XCTAssertEqual($0 as NSError, error as NSError)
            }
            await XCTAssertThrowsErrorAsync({ try await sut.hasUnreadNotification() }) {
                XCTAssertEqual($0 as NSError, error as NSError)
            }
            XCTAssertEqual(network.endpoints.count, 2)
            XCTAssertTrue(storage.readKeys.isEmpty)
            XCTAssertTrue(storage.savedTokens.isEmpty)
        }
    }

    func testListAndUnreadPropagateEmptyResponseError() async throws {
        let network = NotificationNetworkSpy()
        network.response = try CoreNetworkJSONFixture.response()
        let sut = makeSUT(network: network, storage: NotificationKeyChainSpy())

        await XCTAssertThrowsErrorAsync({ try await sut.getNotifications(cursor: nil, size: 15, allRead: true) }) {
            XCTAssertEqual(String(describing: $0), "emptyResponse")
        }
        await XCTAssertThrowsErrorAsync({ try await sut.hasUnreadNotification() }) {
            XCTAssertEqual(String(describing: $0), "emptyResponse")
        }
    }

    private func makeSUT(network: NotificationNetworkSpy, storage: NotificationKeyChainSpy) -> NotificationRepository {
        NotificationRepository(notificationService: NotificationService(network: network), keyChainStorage: storage)
    }
}
