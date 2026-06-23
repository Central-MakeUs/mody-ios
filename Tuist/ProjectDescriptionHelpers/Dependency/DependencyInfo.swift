//
//  DependencyInfo.swift
//  BaseTemplateManifests
//
//  Created by 김동준 on 9/7/25
//

public struct DependencyInfo: @unchecked Sendable {
    let moduleDependencies: [Module: [Dependency]]
}

public enum Dependency {
    case module(Module)
}

public let dependencyInfo: DependencyInfo = DependencyInfo(
    moduleDependencies: [
        .App: [
            
        ]
    ]
)
