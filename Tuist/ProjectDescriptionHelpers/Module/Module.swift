//
//  Module.swift
//  BaseTemplateManifests
//
//  Created by 김동준 on 9/7/25
//

public enum Module: Hashable {
    case Util
    case ModyLogger
    case CommonDomain
    case Base
    case DesignSystem
    case Root
    case App
    case MicroFeature(MicroFeatureModule)
    case External(ExternalModule)
}

public enum ExternalModule {
    case ComposableArchitecture
    case Swinject
    case Alamofire
    case SnapKit
    case KakaoSDKAuth
    case KakaoSDKCommon
    case KakaoSDKShare
    case KakaoSDKUser
    case FirebaseCore
    case FirebaseAnalytics
    case FirebaseCrashlytics
    case FirebaseMessaging
    case FirebaseRemoteConfig
    case ReactorKit
    case RxSwift
    case RxCocoa
    case RxRelay
    case Nuke

    var name: String {
        switch self {
        default: "\(self)"
        }
    }
}

public enum MicroFeatureModule {
    case CoreModyImage
    case CoreCamera
    case CoreNotification
    case CoreKakao
    case ModyGroup
    case CoreAuth
    case FirebaseService
    case CoreNetwork
    case CoreKeyChainStorage
    case SignUpDone
    case MyPage
    case Challenge
    case Feed
    case Main
    case OnBoarding
    case SignIn
    case Splash
    
    var name: String {
        switch self {
        default: "\(self)"
        }
    }
    
    var interfaceName: String { "\(name)Interface" }
    var testingName: String { "\(name)Testing" }
    var testsName: String { "\(name)Tests" }
    var demoName: String { "\(name)Demo" }
    
    var bundleID: String {
        let organizationName = projectEnvironment.organizationName
        let appName = projectEnvironment.appName
        return "com.\(organizationName).\(appName)-\(name.lowercased())"
    }
    
    var path: String {
        switch self {
        case .Splash: "Projects/Feature/Splash"
        case .SignIn: "Projects/Feature/SignIn"
        case .OnBoarding: "Projects/Feature/OnBoarding"
        case .Feed: "Projects/Feature/Feed"
        case .Main: "Projects/Feature/Main"
        case .Challenge: "Projects/Feature/Challenge"
        case .MyPage: "Projects/Feature/MyPage"
        case .SignUpDone: "Projects/Feature/SignUpDone"
        case .CoreKeyChainStorage: "Projects/Core/CoreKeyChainStorage"
        case .CoreNetwork: "Projects/Core/CoreNetwork"
        case .FirebaseService: "Projects/Core/FirebaseService"
        case .CoreAuth: "Projects/Core/CoreAuth"
        case .ModyGroup: "Projects/Feature/ModyGroup"
        case .CoreKakao: "Projects/Core/CoreKakao"
        case .CoreNotification: "Projects/Core/CoreNotification"
        case .CoreCamera: "Projects/Core/CoreCamera"
        case .CoreModyImage: "Projects/Core/CoreModyImage"
        }
    }
}
