import ProjectDescription
import ProjectDescriptionHelpers

var demoTarget = Target.demo(moduleType: .MicroFeature(.Challenge))
demoTarget.resources = ["Demo/Resources/**"]

let project = Project.implements(
    name: "Challenge",
    targets: [
        demoTarget,
        .target(moduleType: .MicroFeature(.Challenge)),
        .interface(.Challenge),
        .testing(.Challenge),
        .tests(.Challenge)
    ],
    schemes: .scheme(name: "ChallengeDemo") + [
        .scheme(
            name: "ChallengeTests",
            shared: true,
            buildAction: .buildAction(targets: [.target("Challenge"), .target("ChallengeTests")]),
            testAction: .targets(
                [.testableTarget(target: .target("ChallengeTests"))],
                configuration: "DEV",
                options: .options(
                    coverage: true,
                    codeCoverageTargets: [.target("Challenge")]
                )
            )
        )
    ],
    resourceSynthesizers: []
)
