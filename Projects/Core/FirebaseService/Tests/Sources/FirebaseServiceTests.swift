//  FirebaseServiceTests.swift
//  FirebaseServiceTests
//
//  Created by 김동준 on 10/9/26.
//

import FirebaseCore
import FirebaseCrashlytics
import FirebaseRemoteConfig
import FirebaseService
import XCTest

final class FirebaseServiceTests: XCTestCase {
    private var app: FirebaseApp!
    private var remoteConfig: RemoteConfig!

    override func setUpWithError() throws {
        try super.setUpWithError()
        #if !DEV
        throw XCTSkip("The service enables Crashlytics collection outside DEV; run the DEV test scheme.")
        #endif
        // Use synthetic options and local defaults only; never fetch from Firebase.
        if FirebaseApp.app() == nil {
            FirebaseApp.configure(options: makeOptions())
        }
        let name = "FirebaseServiceTests-\(UUID().uuidString)"
        FirebaseApp.configure(name: name, options: makeOptions())
        app = try XCTUnwrap(FirebaseApp.app(name: name))
        remoteConfig = RemoteConfig.remoteConfig(app: app)
    }

    override func tearDownWithError() throws {
        remoteConfig = nil
        if let app {
            let deleted = expectation(description: "Delete isolated Firebase app")
            app.delete { success in
                XCTAssertTrue(success)
                deleted.fulfill()
            }
            wait(for: [deleted], timeout: 5)
        }
        app = nil
        try super.tearDownWithError()
    }

    func testInitializationConfiguresDevelopmentFetchIntervalAndDefaults() {
        _ = makeService(defaults: ["version": "1.2.3" as NSString])

        XCTAssertEqual(remoteConfig.configSettings.minimumFetchInterval, 0)
        XCTAssertEqual(remoteConfig.defaultValue(forKey: "version")?.stringValue, "1.2.3")
        XCTAssertEqual(remoteConfig.configValue(forKey: "version").source, .default)
    }

    func testInitializationDisablesCrashlyticsCollectionInDevelopment() {
        _ = makeService()

        XCTAssertFalse(Crashlytics.crashlytics().isCrashlyticsCollectionEnabled())
    }

    func testStringUsesRequestedKeyAndPreservesUnicode() {
        let sut = makeService(defaults: [
            "title": "서비스 안내 🔔" as NSString,
            "version": "2.0.0" as NSString
        ])

        XCTAssertEqual(sut.getString(forKey: "title"), "서비스 안내 🔔")
        XCTAssertEqual(sut.getString(forKey: "version"), "2.0.0")
    }

    func testBoolUsesRequestedKeyForTrueAndFalse() {
        let sut = makeService(defaults: [
            "enabled": NSNumber(value: true),
            "disabled": NSNumber(value: false)
        ])

        XCTAssertTrue(sut.getBool(forKey: "enabled"))
        XCTAssertFalse(sut.getBool(forKey: "disabled"))
    }

    func testMissingKeysReturnEmptyStringFalseAndNil() {
        let sut = makeService()

        XCTAssertEqual(sut.getString(forKey: "missing"), "")
        XCTAssertFalse(sut.getBool(forKey: "missing"))
        XCTAssertNil(sut.getJson(forKey: "missing", as: Configuration.self))
    }

    func testJSONDecodesRequestedModelAndIgnoresUnknownFields() {
        let sut = makeService(defaults: [
            "config": #"{"title":"공지","enabled":true,"extra":123}"# as NSString,
            "other": #"{"title":"다른 공지","enabled":false}"# as NSString
        ])

        XCTAssertEqual(
            sut.getJson(forKey: "config", as: Configuration.self),
            Configuration(title: "공지", enabled: true)
        )
        XCTAssertEqual(
            sut.getJson(forKey: "other", as: Configuration.self),
            Configuration(title: "다른 공지", enabled: false)
        )
    }

    func testJSONSupportsArrayValues() {
        let sut = makeService(defaults: ["items": #"["first","second"]"# as NSString])

        XCTAssertEqual(sut.getJson(forKey: "items", as: [String].self), ["first", "second"])
    }

    func testInvalidMalformedAndIncompleteJSONReturnNil() {
        let sut = makeService(defaults: [
            "malformed": "{" as NSString,
            "wrongType": #"{"title":"공지","enabled":"yes"}"# as NSString,
            "missingField": #"{"title":"공지"}"# as NSString,
            "null": "null" as NSString,
            "empty": "" as NSString
        ])

        for key in ["malformed", "wrongType", "missingField", "null", "empty"] {
            XCTAssertNil(sut.getJson(forKey: key, as: Configuration.self), key)
        }
    }

    func testReconfigurationRestoresOriginalDefaultsAndFetchInterval() {
        let sut = makeService(defaults: ["version": "1.0.0" as NSString])
        remoteConfig.setDefaults(["version": "9.0.0" as NSString])
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 900
        remoteConfig.configSettings = settings
        XCTAssertEqual(sut.getString(forKey: "version"), "9.0.0")

        sut.configureFirebaseMonitoring()

        XCTAssertEqual(sut.getString(forKey: "version"), "1.0.0")
        XCTAssertEqual(remoteConfig.configSettings.minimumFetchInterval, 0)
        XCTAssertFalse(Crashlytics.crashlytics().isCrashlyticsCollectionEnabled())
    }

    private func makeService(defaults: [String: NSObject] = [:]) -> FirebaseService {
        FirebaseService(remoteConfig: remoteConfig, defaultValues: defaults)
    }

    private func makeOptions() -> FirebaseOptions {
        let options = FirebaseOptions(
            googleAppID: "1:123456789:ios:0123456789abcdef",
            gcmSenderID: "123456789"
        )
        options.apiKey = "AIza" + String(repeating: "0", count: 35)
        options.projectID = "mody-firebase-service-tests"
        return options
    }
}

private struct Configuration: Decodable, Equatable {
    let title: String
    let enabled: Bool
}
