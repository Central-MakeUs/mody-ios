import ProjectDescription
import ProjectDescriptionHelpers

// Firebase reads collection preferences from the main bundle before service initialization.
let testHost = Target.target(
    name: "FirebaseServiceTestHost",
    destinations: projectEnvironment.destination,
    product: .app,
    bundleId: "com.jagsim.Mody-firebaseservice.testhost",
    deploymentTargets: projectEnvironment.deploymentTargets,
    infoPlist: .extendingDefault(with: [
        "UILaunchScreen": [:],
        "FirebaseDataCollectionDefaultEnabled": false,
        "FirebaseCrashlyticsCollectionEnabled": false
    ]),
    sources: ["Tests/Host/**"],
    settings: .settings(configurations: .default)
)

let project = Project.module(
    moduleType: .MicroFeature(.FirebaseService),
    hasDemo: false,
    hasTests: true,
    testHost: testHost
)
