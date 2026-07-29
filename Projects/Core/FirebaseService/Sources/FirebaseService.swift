//
//  FirebaseService.swift
//  FirebaseService
//
//  Created by 김동준 on 7/1/26
//

import FirebaseServiceInterface
import FirebaseRemoteConfig
import FirebaseCrashlytics

public final class FirebaseService: FirebaseServiceInterface {
    private let remoteConfig: RemoteConfig
    private let defaultValues: [String: NSObject]

    public init(
        remoteConfig: RemoteConfig,
        defaultValues: [String: NSObject]
    ) {
        self.remoteConfig = remoteConfig
        self.defaultValues = defaultValues
        configureFirebaseMonitoring()
    }
    
    public func fetchAndActivate() async {
        do {
            try await remoteConfig.fetchAndActivate()
        } catch {
            // TODO: Error Logging
        }
    }
}

public extension FirebaseService {
    func getString(forKey key: String) -> String {
        remoteConfig[key].stringValue
    }
    
    func getBool(forKey key: String) -> Bool {
        remoteConfig[key].boolValue
    }

    func getJson<Value: Decodable>(
        forKey key: String,
        as type: Value.Type
    ) -> Value? {
        try? remoteConfig
            .configValue(forKey: key)
            .decoded(asType: type)
    }
}

public extension FirebaseService {
    func configureFirebaseMonitoring() {
        configureCrashlytics()
        configureRemoteConfig()
    }
    
    func configureCrashlytics() {
        #if DEV
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        #else
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        #endif
    }
    
    func configureRemoteConfig() {
        let settings = RemoteConfigSettings()

        #if DEV
        settings.minimumFetchInterval = 0
        #else
        settings.minimumFetchInterval = 300
        #endif

        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(defaultValues)
    }
}
