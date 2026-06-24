//
//  Module.swift
//  BaseTemplateManifests
//
//  Created by 김동준 on 9/7/25
//

public enum Module: Hashable {
    case App
    case MicroFeature(MicroFeatureModule)
}

public enum MicroFeatureModule {
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
        }
    }
}
