//
//  FeedReactorDependencies.swift
//  FeedTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import FeedInterface
import ModyGroupInterface

final class FeedGroupUseCaseStub: GroupUseCaseProtocol {
    func createGroup(name: String) async throws -> String { throw NetworkError.unknown }

    func joinGroup(code: String) async throws { throw NetworkError.unknown }

    func getGroups() async throws -> [GroupModel] { [] }

    func exitGroup(groupId: Int) async throws { throw NetworkError.unknown }
}

@MainActor
final class FeedRouterSpy: FeedRouter {
    var onRoute: ((FeedRoute) -> Void)?
    private(set) var routes: [FeedRoute] = []

    func route(from route: FeedRoute) {
        routes.append(route)
        onRoute?(route)
    }
}
