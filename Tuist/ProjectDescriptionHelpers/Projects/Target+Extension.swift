//
//  Target+Extension.swift
//  BaseTemplateManifests
//
//  Created by 김동준 on 9/7/25
//

import ProjectDescription

public extension Target {
    static func target(moduleType: Module) -> Target {
        let resources: ResourceFileElements? = moduleType.hasResources ? ["Resources/**"] : nil
        let infoPlist: InfoPlist = moduleType.infoPlist
        
        return Target.implements(
            name: moduleType.name,
            product: moduleType.product,
            bundleID: moduleType.bundleID,
            resources: resources,
            infoPlist: infoPlist,
            dependencies: .dependencies(moduleType: moduleType)
        )
    }
    
    static func demo(moduleType: Module) -> Target {
        let demoName = "\(moduleType.name)Demo"
        
        return .target(
            name: demoName,
            destinations: projectEnvironment.destination,
            product: .app,
            bundleId: "\(moduleType.bundleID)-demo",
            deploymentTargets: projectEnvironment.deploymentTargets,
            infoPlist: .file(path: "Demo/Support/Info.plist"),
            sources: .demo,
            dependencies: moduleType.demoDependencies,
            settings: .settings(
                base: [ "BUNDLE_NAME": .string(demoName) ],
                configurations: .default
            )
        )
    }
}

// MARK: Implement
private extension Target {
    static func implements(
        name: String,
        product: Product,
        bundleID: String,
        resources: ResourceFileElements? = nil,
        infoPlist: InfoPlist,
        dependencies: [TargetDependency]
    ) -> Target {
        Target.target(
            name: name,
            destinations: projectEnvironment.destination,
            product: product,
            bundleId: bundleID,
            deploymentTargets: projectEnvironment.deploymentTargets,
            infoPlist: infoPlist,
            sources: .default,
            resources: resources,
            dependencies: dependencies,
            settings: .settings(
                base: projectEnvironment.baseSetting,
                configurations: .default,
                defaultSettings: projectEnvironment.defaultSettings
            )
        )
    }
}

extension SourceFilesList? {
    static var `default`: SourceFilesList? { ["Sources/**"] }
    static var demo: SourceFilesList? { ["Demo/Sources/**"] }
    static var interface: SourceFilesList? { ["Interface/Sources/**"] }
    static var testing: SourceFilesList? { ["Testing/Sources/**"] }
    static var tests: SourceFilesList? { ["Tests/Sources/**"] }
}

private extension Module {
    var demoDependencies: [TargetDependency] {
        switch self {
        default:
            [.target(name: name)]
        }
    }
}
