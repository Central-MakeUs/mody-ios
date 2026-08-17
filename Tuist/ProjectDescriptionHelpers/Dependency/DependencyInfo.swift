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
            .module(.MicroFeature(.Main)),
            .module(.MicroFeature(.Splash)),
            .module(.MicroFeature(.SignIn)),
            .module(.MicroFeature(.OnBoarding)),
            .module(.MicroFeature(.ModyGroup)),
            .module(.MicroFeature(.Feed)),
            .module(.MicroFeature(.Challenge)),
            .module(.MicroFeature(.MyPage)),
            .module(.MicroFeature(.FirebaseService)),
            .module(.MicroFeature(.CoreKeyChainStorage)),
            .module(.MicroFeature(.CoreNetwork)),
            .module(.MicroFeature(.CoreAuth)),
            .module(.MicroFeature(.CoreKakao)),
            .module(.MicroFeature(.CoreCamera)),
            .module(.MicroFeature(.CoreNotification)),
            .module(.MicroFeature(.CoreModyImage)),
            .module(.MicroFeature(.CoreHealth)),

            .external(.FirebaseCore),
            .external(.FirebaseMessaging),
            .external(.Swinject),
            
            .microFeature(.CoreNetwork),
            .microFeature(.CoreAuth),
            .microFeature(.CoreKakao),
            .microFeature(.CoreCamera),
            .microFeature(.CoreNotification),
            .microFeature(.CoreModyImage),
            .microFeature(.CoreHealth),
            .microFeature(.Main)
        ],
        .Root: [
            .microFeature(.Splash),
            .microFeature(.SignIn),
            .microFeature(.OnBoarding),
            .microFeature(.ModyGroup),
            .module(.Base)
        ],
        .DesignSystem: [
            .external(.SnapKit)
        ],
        .Base: [
            .external(.ComposableArchitecture),
            .module(.DesignSystem),
            .module(.ModyLogger),
            .module(.CommonDomain),
            .module(.Util),
            .microFeature(.CoreModyImage)
        ]
    ],
    microFeatureDependencies: [
        .Splash: .init(
            implementation: [
                .external(.ComposableArchitecture),
                .module(.Base),
                .microFeature(.CoreNetwork),
                .microFeature(.FirebaseService),
                .microFeature(.CoreKeyChainStorage),
                .module(.CommonDomain),
                .microFeature(.CoreAuth)
            ]
        ),
        .SignIn: .init(
            implementation: [
                .external(.ComposableArchitecture),
                .module(.Base),
                .module(.CommonDomain),
                .microFeature(.FirebaseService),
                .microFeature(.CoreAuth)
            ]
        ),
        .OnBoarding: .init(
            implementation: [
                .external(.ComposableArchitecture),
                .module(.Base),
                .module(.CommonDomain),
                .microFeature(.CoreNetwork),
                .microFeature(.CoreCamera),
                .microFeature(.CoreNotification),
                .microFeature(.CoreHealth),
                .module(.Util)
            ]
        ),
        .SignUpDone: .init(
            implementation: [
                .external(.ComposableArchitecture),
                .module(.Base)
            ]
        ),
        .ModyGroup: .init(
            interface: [
                .module(.CommonDomain)
            ],
            implementation: [
                .external(.ComposableArchitecture),
                .module(.Base),
                .module(.CommonDomain),
                .microFeature(.CoreNetwork),
                .microFeature(.CoreKakao)
            ]
        ),
        .Feed: .init(
            interface: [
                .module(.CommonDomain)
            ],
            implementation: [
                .module(.Base),
                .module(.CommonDomain),
                .module(.Util),
                .microFeature(.CoreAuth),
                .microFeature(.CoreNetwork),
                .microFeature(.CoreCamera),
                .microFeature(.ModyGroup),
                .external(.ReactorKit),
                .external(.RxSwift),
                .external(.RxCocoa),
                .external(.RxRelay),
                .microFeature(.CoreModyImage)
            ],
            demo: [
                .module(.DesignSystem),
                .module(.MicroFeature(.CoreCamera)),
                .module(.MicroFeature(.CoreModyImage))
            ]
        ),
        .Main: .init(
            implementation: [
                .microFeature(.Feed),
                .microFeature(.Challenge),
                .microFeature(.MyPage),
                .microFeature(.ModyGroup),
                .microFeature(.CoreNotification),
                .microFeature(.CoreModyImage),
                .module(.Base),
                .module(.CommonDomain),
                .module(.Util),
                .external(.ComposableArchitecture),
                .external(.SnapKit),
                .external(.ReactorKit),
                .external(.RxSwift),
                .external(.RxCocoa)
            ]
        ),
        .Challenge: .init(
            interface: [
                .module(.CommonDomain)
            ],
            implementation: [
                .external(.ComposableArchitecture),
                .module(.Base),
                .module(.CommonDomain),
                .module(.Util),
                .microFeature(.CoreAuth),
                .microFeature(.CoreCamera),
                .microFeature(.CoreNetwork),
                .microFeature(.CoreModyImage),
                .microFeature(.CoreHealth)
            ]
        ),
        .MyPage: .init(
            interface: [
                .module(.CommonDomain)
            ],
            implementation: [
                .external(.ComposableArchitecture),
                .module(.Base),
                .module(.CommonDomain),
                .module(.Util),
                .microFeature(.CoreAuth),
                .microFeature(.CoreNetwork),
                .microFeature(.CoreNotification),
                .microFeature(.ModyGroup),
                .microFeature(.CoreCamera),
                .microFeature(.CoreModyImage)
            ],
            demo: [
                .module(.CommonDomain),
                .microFeature(.CoreAuth),
                .module(.MicroFeature(.CoreModyImage))
            ]
        ),
        .CoreNetwork: .init(
            implementation: [
                .external(.Alamofire),
                .module(.CommonDomain),
                .module(.ModyLogger),
                .microFeature(.CoreAnalytics)
            ]
        ),
        .FirebaseService: .init(
            implementation: [
                .external(.FirebaseCore),
                .external(.FirebaseAnalytics),
                .external(.FirebaseCrashlytics),
                .external(.FirebaseRemoteConfig),
                .module(.ModyLogger)
            ]
        ),
        .CoreKakao: .init(
            implementation: [
                .external(.KakaoSDKAuth),
                .external(.KakaoSDKCommon),
                .external(.KakaoSDKShare),
                .external(.KakaoSDKUser)
            ]
        ),
        .CoreAuth: .init(
            interface: [
                .module(.CommonDomain)
            ],
            implementation: [
                .module(.CommonDomain),
                .microFeature(.CoreKeyChainStorage),
                .microFeature(.CoreNetwork),
                .microFeature(.CoreKakao),
                .module(.ModyLogger)
            ]
        ),
        .CoreNotification: .init(
            implementation: [
                .microFeature(.CoreKeyChainStorage),
                .microFeature(.CoreNetwork)
            ]
        ),
        .CoreCamera: .init(
            interface: [
                .microFeature(.CoreModyImage)
            ],
            implementation: [
                .module(.DesignSystem),
                .microFeature(.CoreModyImage),
                .external(.SnapKit)
            ]
        ),
        .CoreModyImage: .init(
            implementation: [
                .module(.CommonDomain),
                .microFeature(.CoreNetwork),
                .external(.Alamofire),
                .external(.Nuke)
            ]
        ),
        .CoreHealth: .init(),
        .CoreAnalytics: .init()
    ]
)
