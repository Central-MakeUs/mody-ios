//
//  Environment.swift
//  ProjectDescriptionHelpers
//
//  Created by 김동준 on 5/8/26.
    

public enum Environment: CaseIterable {
    case dev
    case prod

    public var name: String {
        switch self {
        case .dev: "DEV"
        case .prod: "PROD"
        }
    }
}

extension [Environment] {
    static var all: Self { Environment.allCases }
}
