//
//  Dependency+Extension.swift
//  BaseTemplateManifests
//
//  Created by 김동준 on 9/7/25
//

import ProjectDescription

public extension Array where Element == TargetDependency {
    static func dependencies(moduleType: Module) -> [TargetDependency] {
        switch moduleType {
        default:
            dependencyInfo.moduleDependencies[moduleType, default: []].map {
                TargetDependency.resolve($0)
            }
        }
    }
}

extension TargetDependency {
    static func resolve(_ dependency: Dependency) -> TargetDependency {
        switch dependency {
        case .module(let module):
            return .project(
                target: module.name,
                path: module.path
            )
        }
    }
}
