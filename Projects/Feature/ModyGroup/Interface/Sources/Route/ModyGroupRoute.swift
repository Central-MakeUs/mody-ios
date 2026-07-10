//
//  ModyGroupRoute.swift
//  ModyGroupInterface
//
//  Created by 김동준 on 6/26/26
//

public enum ModyGroupRoute: Equatable {
    case back
    case finish
}

public enum ModyGroupEntryPoint: Equatable {
    case root
    case main
}

public enum ModyGroupInitialScreen: Equatable {
    case participate
    case create
}

@MainActor
public protocol ModyGroupRouter: AnyObject {
    func route(from route: ModyGroupRoute)
}
