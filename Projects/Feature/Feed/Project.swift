import ProjectDescription
import ProjectDescriptionHelpers

var demoTarget = Target.demo(moduleType: .MicroFeature(.Feed))
demoTarget.resources = ["Demo/Resources/**"]

let project = Project.implements(
    name: "Feed",
    targets: [
        demoTarget,
        .target(moduleType: .MicroFeature(.Feed)),
        .interface(.Feed),
        .testing(.Feed),
        .tests(.Feed)
    ],
    schemes: .scheme(name: "FeedDemo") + [
        .scheme(
            name: "FeedTests",
            shared: true,
            buildAction: .buildAction(targets: ["Feed", "FeedTests"]),
            testAction: .targets(
                [.testableTarget(target: "FeedTests")],
                configuration: "DEV",
                options: .options(
                    coverage: true,
                    codeCoverageTargets: ["Feed"]
                )
            )
        )
    ],
    resourceSynthesizers: []
)
