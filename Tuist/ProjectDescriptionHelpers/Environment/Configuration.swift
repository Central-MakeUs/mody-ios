//
//  Configuration.swift
//  ProjectDescriptionHelpers
//
//  Created by 김동준 on 9/7/25
//

import ProjectDescription

public extension ConfigurationName {
    static let dev = ConfigurationName.configuration(Environment.dev.name)
    static let prod = ConfigurationName.configuration(Environment.prod.name)
}

public extension Array where Element == Configuration {
    static let `default`: [Configuration] = [
        .debug(name: .dev, xcconfig: .path(.dev)),
        .debug(name: .prod, xcconfig: .path(.prod)),
        .release(name: .release, xcconfig: .path(.release))
    ]
}

private extension ProjectDescription.Path {
    static func path(_ configuration: ConfigurationName) -> Self {
        return .relativeToRoot("XCConfig/\(configuration.rawValue).xcconfig")
    }
}
