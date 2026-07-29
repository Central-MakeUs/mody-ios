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
        case .MicroFeature(let module):
            module.implementationDependencies
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
        case .external(let module):
            return .external(name: module.name)
        case .microFeature(let module):
            return .microFeatureInterface(module)
        case .microFeatureTesting(let module):
            return .microFeatureTesting(module)
        }
    }
    
    static func microFeatureInterface(_ module: MicroFeatureModule) -> TargetDependency {
        .project(
            target: module.interfaceName,
            path: .relativeToRoot(module.path)
        )
    }

    static func microFeatureTesting(_ module: MicroFeatureModule) -> TargetDependency {
        .project(
            target: module.testingName,
            path: .relativeToRoot(module.path)
        )
    }
}

extension MicroFeatureModule {
    private var configuredDependencies: MicroFeatureDependencies {
        dependencyInfo.microFeatureDependencies[self] ?? .init()
    }
    
    var interfaceDependencies: [TargetDependency] {
        configuredDependencies.interface.map {
            TargetDependency.resolve($0)
        }
    }
    
    var implementationDependencies: [TargetDependency] {
        [.target(name: interfaceName)] + configuredDependencies.implementation.map {
            TargetDependency.resolve($0)
        }
    }
    
    var testingDependencies: [TargetDependency] {
        [.target(name: interfaceName)] + configuredDependencies.testing.map {
            TargetDependency.resolve($0)
        }
    }
    
    var testDependencies: [TargetDependency] {
        [
            .target(name: name),
            .target(name: testingName)
        ] + configuredDependencies.tests.map {
            TargetDependency.resolve($0)
        }
    }
    
    var demoDependencies: [TargetDependency] {
        [
            .target(name: name),
            .target(name: testingName)
        ] + configuredDependencies.demo.map {
            TargetDependency.resolve($0)
        }
    }
}
