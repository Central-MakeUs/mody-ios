//
//  MicroFeatureModule.swift
//  BaseTemplateManifests
//
//  Created by 김동준 on 9/7/25
//

import ProjectDescription

private let moduleNameAttribute = Template.Attribute.required("name")
private let basePathAttribute = Template.Attribute.required("basePath")
private let hasDemoAttribute = Template.Attribute.optional("hasDemo", default: "false")
private let path = "\(basePathAttribute)/\(moduleNameAttribute)"

private let template = Template(
    description: "A template for micro features module.",
    attributes: [
        moduleNameAttribute,
        basePathAttribute,
        hasDemoAttribute
    ],
    items: [
        .file(
            path: "\(path)/Project.swift",
            templatePath: "Sources/Project.swift.stencil"
        ),
        .file(
            path: "\(path)/Sources/DefaultSourceCode.swift",
            templatePath: "Sources/DefaultSourceCode.swift.stencil"
        ),
        .file(
            path: "\(path)/Interface/Sources/DefaultInterfaceCode.swift",
            templatePath: "Sources/DefaultInterfaceCode.swift.stencil"
        ),
        .file(
            path: "\(path)/Testing/Sources/DefaultTestingCode.swift",
            templatePath: "Sources/DefaultTestingCode.swift.stencil"
        ),
        .file(
            path: "\(path)/Tests/Sources/DefaultTestsCode.swift",
            templatePath: "Sources/DefaultTestsCode.swift.stencil"
        ),
        .file(
            path: "\(path)/Demo/Sources/DefaultDemoCode.swift",
            templatePath: "Sources/DefaultDemoCode.swift.stencil"
        ),
        .file(
            path: "\(path)/Demo/Support/Info.plist",
            templatePath: "Sources/DemoInfo.plist.stencil"
        )
    ]
)
