//
//  Module+Extension.swift
//  BaseTemplateManifests
//
//  Created by 김동준 on 9/7/25
//

import ProjectDescription

extension Module {
    var name: String {
        switch self {
        case .App: projectEnvironment.targetName
        }
    }
    
    func targets(hasDemo: Bool = false) -> [Target] {
        switch self {
        case .App:
            return [.target(moduleType: self)]
        }
    }
    
    var product: Product {
        switch self {
        case .App: .app
        }
    }
    
    var hasResources: Bool {
        switch self {
        case .App:
            true
        }
    }
    
    var infoPlist: InfoPlist {
        switch self {
        case .App:
            .file(path: "Support/Info.plist")
        }
    }
    
    func schemes(hasDemo: Bool = false) -> [Scheme] {
        switch self {
        case .App:
            .scheme(name: projectEnvironment.appName, environments: .all)
        }
    }
    
    var additionalFiles: [FileElement]? {
        switch self {
        case .App: ["../../XCConfig/Shared.xcconfig"]
        }
    }
    
    var resourceSynthesizers: [ResourceSynthesizer] {
        switch self {
        default: []
        }
    }
    
    var bundleID: String {
        return "${BUNDLE_IDENTIFIER}"
    }
    
    var path: Path {
        switch self {
        default: .relativeToRoot("Projects/\(name)")
        }
    }
}
