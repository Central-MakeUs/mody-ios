//
//  FeedReactor.swift
//  Feed
//
//  Created by 김동준 on 7/11/26
//

import ReactorKit
import CommonDomain
import FeedInterface
import ModyGroupInterface

public final class FeedReactor: Reactor {
    private let groupUseCase: GroupUseCaseProtocol
    private weak var router: FeedRouter?
    public let initialState: State = .init()
    
    public struct State {
        var isFloatingActionButtonExpanded = false
        var groups: [GroupModel] = []
        var selectedGroup: GroupModel?
        var isFetchGroupLoading = false
    }
    
    public enum Mutation {
        case setFloatingActionButtonExpanded(Bool)
        case setGroups([GroupModel])
        case setSelectedGroup(GroupModel)
        case setFetchGroupLoading(Bool)
    }
    
    public enum Action {
        case viewDidLoad
        case didTapDimmedOverlay
        case didTapFloatingActionButton
        case didTapExerciseRecordButton
        case didTapMealRecordButton
        case didTapAddGroup
        case didSelectGroup(GroupModel)
    }
    
    public init(
        groupUseCase: GroupUseCaseProtocol,
        router: FeedRouter
    ) {
        self.groupUseCase = groupUseCase
        self.router = router
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .concat([
                .just(.setFetchGroupLoading(true)),
                fetchGroups(),
                .just(.setFetchGroupLoading(false))
            ])
        case .didTapDimmedOverlay:
            return .just(.setFloatingActionButtonExpanded(false))
        case .didTapFloatingActionButton:
            return .just(.setFloatingActionButtonExpanded(!currentState.isFloatingActionButtonExpanded))
        case .didTapExerciseRecordButton:
            return .just(.setFloatingActionButtonExpanded(false))
        case .didTapMealRecordButton:
            return .just(.setFloatingActionButtonExpanded(false))
        case .didTapAddGroup:
            Task { @MainActor [weak router] in
                router?.route(from: .addGroup)
            }
            return .empty()
        case let .didSelectGroup(group):
            guard currentState.groups.contains(where: { $0.groupId == group.groupId }) else {
                return .empty()
            }
            return .just(.setSelectedGroup(group))
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setFloatingActionButtonExpanded(let isExpanded):
            newState.isFloatingActionButtonExpanded = isExpanded
        case .setGroups(let groups):
            newState.groups = groups
            if newState.selectedGroup == nil, groups.count > 0 {
                newState.selectedGroup = groups.first
            }
        case .setSelectedGroup(let group):
            newState.selectedGroup = group
        case .setFetchGroupLoading(let isLoading):
            newState.isFetchGroupLoading = isLoading
        }
        
        return newState
    }
}

private extension FeedReactor {
    func fetchGroups() -> Observable<Mutation> {
        Observable.create { [weak self] observer in
            let task = Task {
                guard let self else { return }
                do {
                    try await Task.sleep(for: .seconds(1)) // MARK: 현재 응답이 너무 빨라 테스트 용으로 넣었음. (스켈레톤 볼려고)
                    let groups = try await self.groupUseCase.getGroups()
                    observer.onNext(.setGroups(groups))
                } catch {
                    observer.onError(error)
                }

                observer.onCompleted()
            }

            return Disposables.create { task.cancel() }
        }
        .observe(on: MainScheduler.instance)
    }
}
