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
                    RemoteConfigKeys.isPhaseOneFlag.rawValue: NSNumber(value: false)
                ]
            )
        }
        .inObjectScope(.container)
    }
}
