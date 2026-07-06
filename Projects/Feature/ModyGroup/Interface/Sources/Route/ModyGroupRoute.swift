//
//  ModyGroupRoute.swift
//  ModyGroupInterface
//
//  Created by 김동준 on 6/26/26
//

public enum ModyGroupRoute: Equatable {
    case routeToMain
}

@MainActor
public protocol ModyGroupRouter: AnyObject {
    func route(from route: ModyGroupRoute)
}
