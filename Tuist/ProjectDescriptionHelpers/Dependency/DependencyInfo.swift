//
//  DependencyInfo.swift
//  BaseTemplateManifests
//
//  Created by 김동준 on 9/7/25
//

public struct DependencyInfo: @unchecked Sendable {
    let moduleDependencies: [Module: [Dependency]]
    let microFeatureDependencies: [MicroFeatureModule: MicroFeatureDependencies]
}

public enum Dependency {
    case module(Module)
    case external(ExternalModule)
    case microFeature(MicroFeatureModule) // Interface
    case microFeatureTesting(MicroFeatureModule) // Testing
}

public struct MicroFeatureDependencies {
    let interface: [Dependency]
    let implementation: [Dependency]
    let testing: [Dependency]
    let tests: [Dependency]
    let demo: [Dependency]
    
    public init(
        interface: [Dependency] = [],
        implementation: [Dependency] = [],
        testing: [Dependency] = [],
        tests: [Dependency] = [],
        demo: [Dependency] = []
    ) {
        self.interface = interface
        self.implementation = implementation
        self.testing = testing
        self.tests = tests
        self.demo = demo
    }
}

public let dependencyInfo: DependencyInfo = DependencyInfo(
    moduleDependencies: [
        .App: [
            .module(.Root),
            .module(.Main),
            .module(.MicroFeature(.Splash)),
            .module(.MicroFeature(.SignIn)),
            .module(.MicroFeature(.OnBoarding)),
            .module(.MicroFeature(.SignUpDone)),
            .external(.Swinject),
            .module(.MicroFeature(.CoreKeyChainStorage))
        ],
        .Root: [
            .microFeature(.Splash),
            .microFeature(.SignIn),
            .microFeature(.OnBoarding),
            .microFeature(.SignUpDone),
            .module(.Base)
        ],
        .Main: [
            .microFeature(.Feed),
            .microFeature(.Challenge),
            .microFeature(.MyPage),
            .module(.Base)
        ],
        .Base: [
            .module(.DesignSystem)
        ]
    ],
    microFeatureDependencies: [
        .Splash: .init(
            implementation: [
                .external(.ComposableArchitecture),
                .module(.Base)
            ]
        ),
        .SignIn: .init(
            implementation: [
                .external(.ComposableArchitecture),
                .module(.Base)
            ]
        ),
        .OnBoarding: .init(
            implementation: [
                .external(.ComposableArchitecture),
                .module(.Base)
            ]
        ),
        .SignUpDone: .init(
            implementation: [
                .external(.ComposableArchitecture),
                .module(.Base)
            ]
        ),
        .Feed: .init(
            implementation: [
                .module(.Base)
            ]
        ),
        .Challenge: .init(
            implementation: [
                .module(.Base)
            ]
        ),
        .MyPage: .init(
            implementation: [
                .module(.Base)
            ]
        )
    ]
)
