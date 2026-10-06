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
    schemes: .scheme(name: "ChallengeDemo"),
    resourceSynthesizers: []
)
