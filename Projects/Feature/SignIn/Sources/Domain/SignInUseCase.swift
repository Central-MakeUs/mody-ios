//
//  SignInUseCase.swift
//  SignIn
//
//  Created by 김동준 on 7/26/26.
//

public struct SignInUseCase {
    private let signInRepository: SignInRepositoryProtocol

    public init(signInRepository: SignInRepositoryProtocol) {
        self.signInRepository = signInRepository
    }

    public func isDemoLoginEnabled() -> Bool {
        signInRepository.isDemoLoginEnabled()
    }
}
