//
//  Project+Extension.swift
//  BaseTemplateManifests
//
//  Created by 김동준 on 9/7/25
//

import ProjectDescription

public extension Project {
    static func module(
        moduleType: Module,
        hasDemo: Bool = false,
        hasTests: Bool = false
    ) -> Project {
        Project.implements(
            name: moduleType.name,
            targets: moduleType.targets(
                hasDemo: hasDemo,
                hasTests: hasTests
            ),
            schemes: moduleType.schemes(
                hasDemo: hasDemo,
                hasTests: hasTests
            ),
            additionalFiles: moduleType.additionalFiles,
            resourceSynthesizers: moduleType.resourceSynthesizers
        )
    }

    static func module(
        moduleType: Module,
        hasDemo: Bool = false,
        hasTests: Bool = false,
        testHost: Target
    ) -> Project {
        var targets = moduleType.targets(hasDemo: hasDemo, hasTests: hasTests)
        if hasTests {
            guard let index = targets.firstIndex(where: { $0.product == .unitTests }) else {
                preconditionFailure("A test host requires a unit test target")
            }
            targets[index].dependencies.append(.target(name: testHost.name))
            targets[index].settings?.base.merge([
                "TEST_HOST": .string("$(BUILT_PRODUCTS_DIR)/\(testHost.name).app/\(testHost.name)"),
                "BUNDLE_LOADER": "$(TEST_HOST)"
            ])
            targets.append(testHost)
        }

        return Project.implements(
            name: moduleType.name,
            targets: targets,
            schemes: moduleType.schemes(
                hasDemo: hasDemo,
                hasTests: hasTests
            ),
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
