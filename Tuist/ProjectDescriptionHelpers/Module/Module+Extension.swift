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
        case .MicroFeature(let microFeatureModule): microFeatureModule.name
        default: "\(self)"
        }
    }
    
    func targets(hasDemo: Bool = false) -> [Target] {
        switch self {
        case .App:
            return [.target(moduleType: self)]
        case .MicroFeature(let module):
            var targets: [Target] = hasDemo ? [.demo(moduleType: self)] : []
            
            targets.append(contentsOf: [
                .target(moduleType: self),
                .interface(module),
                .testing(module),
                .tests(module)
            ])
            
            return targets
        default:
            return [.target(moduleType: self)]
        }
    }
    
    var product: Product {
        switch self {
        case .App: .app
        default: .staticLibrary
        }
    }
    
    var hasResources: Bool {
        switch self {
        case .App:
            true
        default:
            false
        }
    }
    
    var infoPlist: InfoPlist {
        switch self {
        case .App:
            .file(path: "Support/Info.plist")
        default:
            .default
        }
    }
    
    func schemes(hasDemo: Bool = false) -> [Scheme] {
        switch self {
        case .App:
            .scheme(name: projectEnvironment.appName, environments: .all)
        case .MicroFeature(let module):
            hasDemo ? [.implements(targetName: module.demoName)] : []
        default:
            []
        }
    }
    
    var additionalFiles: [FileElement]? {
        switch self {
        case .App: ["../../XCConfig/Shared.xcconfig"]
        default: nil
        }
    }
    
    var resourceSynthesizers: [ResourceSynthesizer] {
        switch self {
        default: []
        }
    }
    
    var bundlePrefix: String {
        let organizationName = projectEnvironment.organizationName

        return "com.\(organizationName)"
    }
    
    var bundleID: String {
        if case .App = self { return "${BUNDLE_IDENTIFIER}" }
        
        let appName = projectEnvironment.appName.lowercased()
        
        let moduleName = switch self {
        case .MicroFeature(let module): module.name.lowercased()
        default: name.lowercased()
        }
        
        return "\(bundlePrefix).\(appName)-\(moduleName)"
    }
    
    var path: Path {
        switch self {
        case .MicroFeature(let module): .relativeToRoot(module.path)
        case .Root: .relativeToRoot("Projects/Feature/Root")
        default: .relativeToRoot("Projects/\(name)")
        }
    }
}
