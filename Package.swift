// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings
    import ProjectDescriptionHelpers

    let packageSettings = PackageSettings(
        productTypes: [:],
        baseSettings: .settings(configurations: .default),
    )
#endif

let package = Package(
    name: "Mody",
    dependencies: [
        
    ]
)
