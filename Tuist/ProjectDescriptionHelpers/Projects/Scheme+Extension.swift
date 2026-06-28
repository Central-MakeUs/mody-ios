//
//  Scheme+Extension.swift
//  BaseTemplateManifests
//
//  Created by 김동준 on 9/7/25
//

import ProjectDescription

extension Array where Element == Scheme {
    public static func scheme(name: String, environments: [Environment] = []) -> [Scheme] {
        switch environments.isEmpty {
        case true: [.implements(targetName: name, environment: nil)]
        case false: environments.map { .implements(targetName: name, environment: $0) }
        }
    }
}

extension Scheme {
    static func implements(
        targetName: String,
        environment: Environment? = nil
    ) -> Scheme {
        let configurationName: ConfigurationName = switch environment {
        case .some(let environment): .init(stringLiteral: environment.name)
        case nil: .init(stringLiteral: Environment.dev.name)
        }
        
        guard let environment else {
            return .scheme(
                name: targetName,
                shared: true,
                buildAction: .buildAction(targets: ["\(targetName)"]),
                runAction: .runAction(
                    configuration: configurationName,
                    executable: .executable("\(targetName)")
                )
            )
        }
        
        let schemeName = switch environment {
        case .prod: targetName
        default: "\(targetName)-\(environment.name)"
        }
        
        return Scheme.scheme(
            name: schemeName,
            shared: true,
            buildAction: .buildAction(targets: ["\(targetName)"]),
            runAction: .runAction(configuration: configurationName, executable: .executable("\(targetName)")),
            archiveAction: .archiveAction(configuration: configurationName),
            profileAction: .profileAction(configuration: configurationName, executable: .executable("\(targetName)")),
            analyzeAction: .analyzeAction(configuration: configurationName)
        )
    }
}
