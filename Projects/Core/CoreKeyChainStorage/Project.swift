import ProjectDescription
import ProjectDescriptionHelpers

let testHost = Target.target(
    name: "CoreKeyChainStorageTestHost",
    destinations: projectEnvironment.destination,
    product: .app,
    bundleId: "com.jagsim.Mody-corekeychainstorage.testhost",
    deploymentTargets: projectEnvironment.deploymentTargets,
    infoPlist: .extendingDefault(with: ["UILaunchScreen": [:]]),
    sources: ["Tests/Host/**"],
    settings: .settings(configurations: .default)
)

let project = Project.module(
    moduleType: .MicroFeature(.CoreKeyChainStorage),
    hasDemo: false,
    hasTests: true,
    testHost: testHost
)
