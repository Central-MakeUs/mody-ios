//
//  Project+Extension.swift
//  BaseTemplateManifests
//
//  Created by 김동준 on 9/7/25
//

import ProjectDescription

public extension Project {
    static func module(moduleType: Module, hasDemo: Bool = false) -> Project {
        Project.implements(
            name: moduleType.name,
            targets: moduleType.targets(hasDemo: hasDemo),
            schemes: moduleType.schemes(hasDemo: hasDemo),
            additionalFiles: moduleType.additionalFiles,
            resourceSynthesizers: moduleType.resourceSynthesizers
        )
    }
}

// MARK: Implement
public extension Project {
    static func implements(
        name: String,
        targets: [Target],
        schemes: [Scheme],
        additionalFiles: [FileElement]? = nil,
        resourceSynthesizers: [ResourceSynthesizer]
    ) -> Project {
        Project(
            name: name,
            organizationName: projectEnvironment.organizationName,
            options: .options(automaticSchemesOptions: .disabled),
            settings: .settings(
                base: projectEnvironment.baseSetting,
                configurations: .default,
                defaultSettings: projectEnvironment.defaultSettings
            ),
            targets: targets,
            schemes: schemes,
            additionalFiles: additionalFiles ?? [],
            resourceSynthesizers: resourceSynthesizers
        )
    }
}
