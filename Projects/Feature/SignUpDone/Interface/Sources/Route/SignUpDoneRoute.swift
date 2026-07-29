//
//  SignUpDoneRoute.swift
//  SignUpDoneInterface
//
//  Created by 김동준 on 6/26/26
//

public enum SignUpDoneRoute: Equatable {
    case routeToMain
}

@MainActor
public protocol SignUpDoneRouter: AnyObject {
    func route(from route: SignUpDoneRoute)
}
