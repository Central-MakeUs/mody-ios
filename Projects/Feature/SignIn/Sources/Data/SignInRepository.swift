//
//  SignInRepository.swift
//  SignIn
//
//  Created by 김동준 on 7/26/26.
//

import CommonDomain
import FirebaseServiceInterface

public struct SignInRepository: SignInRepositoryProtocol {
    private let firebaseService: FirebaseServiceInterface

    public init(firebaseService: FirebaseServiceInterface) {
        self.firebaseService = firebaseService
    }

    public func isDemoLoginEnabled() -> Bool {
        firebaseService.getBool(forKey: RemoteConfigKeys.guestLogin.rawValue)
    }
}
