//
//  AppAssembly+FirebaseService.swift
//  Mody
//
//  Created by 김동준 on 7/1/26
//

import Swinject
import FirebaseRemoteConfig
import FirebaseService
import FirebaseServiceInterface
import CommonDomain

extension AppAssembly {
    func assembleFirebaseService(in container: Container) {
        container.register(FirebaseServiceInterface.self) { _ in
            FirebaseService(
                remoteConfig: RemoteConfig.remoteConfig(),
                defaultValues: [
                    RemoteConfigKeys.isPhaseOneFlag.rawValue: NSNumber(value: false),
                    RemoteConfigKeys.forceUpdate.rawValue: NSNumber(value: false),
                    RemoteConfigKeys.guestLogin.rawValue: NSNumber(value: false),
                    RemoteConfigKeys.notice.rawValue: "{}" as NSString,
                    RemoteConfigKeys.minimumSupportedVersion.rawValue: "1.0.0" as NSString,
                    RemoteConfigKeys.appStoreURL.rawValue: "" as NSString
                ]
            )
        }
        .inObjectScope(.container)
    }
}
