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
        case .External(let externalModule): externalModule.name
        case .MicroFeature(let microFeatureModule): microFeatureModule.name
        default: "\(self)"
        }
    }
    
    func targets(hasDemo: Bool = false) -> [Target] {
        switch self {
        case .App:
            return [.target(moduleType: self)]
        case .DesignSystem:
            return [.target(moduleType: self), .demo(moduleType: self)]
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
        case .DesignSystem: .staticFramework
        default: .staticLibrary
        }
    }
    
    var hasResources: Bool {
        switch self {
        case .App, .DesignSystem:
            true
        default:
            false
        }
    }
    
    var infoPlist: InfoPlist {
        switch self {
        case .App:
            .file(path: "Support/Info.plist")
        case .DesignSystem:
            .extendingDefault(with: [
                "UIAppFonts": .array(Self.designSystemFontFiles)
            ])
        default:
            .default
        }
    }

    var scripts: [TargetScript] {
        switch self {
        case .App: [
                .pre(
                    path: .relativeToRoot("Scripts/Shell/select_google_service_info.sh"),
                    name: "Select GoogleService-Info.plist",
                    basedOnDependencyAnalysis: false
                )
            ]
        default:
            []
        }
    }
    
    func schemes(hasDemo: Bool = false) -> [Scheme] {
        switch self {
        case .App:
            .scheme(name: projectEnvironment.appName, environments: .all)
        case .DesignSystem:
            [.implements(targetName: "\(self.name)Demo")]
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
        case .DesignSystem: [.assets(), .fonts(), .colors, .images]
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
        case .Base: .relativeToRoot("Projects/Feature/Base")
        case .CommonDomain: .relativeToRoot("Projects/Domain/CommonDomain")
        case .ModyLogger: .relativeToRoot("Projects/Shared/ModyLogger")
        case .Util: .relativeToRoot("Projects/Shared/Util")
        default: .relativeToRoot("Projects/\(name)")
        }
    }
}

private extension Module {
    static let designSystemFontFiles: [Plist.Value] = [
        .string("Fonts/Pretendard-Bold.otf"),
        .string("Fonts/Pretendard-Light.otf"),
        .string("Fonts/Pretendard-Medium.otf"),
        .string("Fonts/Pretendard-Regular.otf"),
        .string("Fonts/Pretendard-SemiBold.otf"),
        .string("Fonts/Pretendard-Thin.otf")
    ]
}

private extension ResourceSynthesizer {
    static let colors: Self = .custom(name: "Colors", parser: .assets, extensions: ["xcassets"])
    static let images: Self = .custom(name: "Images", parser: .assets, extensions: ["xcassets"])
}
