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
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.26.0"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.10.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "6.0.0"),
        .package(url: "https://github.com/kakao/kakao-ios-sdk.git", from: "2.20.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.5.0"),
        .package(url: "https://github.com/ReactorKit/ReactorKit.git", from: "3.2.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.10.2"),
        .package(url: "https://github.com/kean/Nuke.git", exact: "13.0.6")
    ]
)
