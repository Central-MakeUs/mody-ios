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
    schemes: .scheme(name: "FeedDemo"),
    resourceSynthesizers: []
)
