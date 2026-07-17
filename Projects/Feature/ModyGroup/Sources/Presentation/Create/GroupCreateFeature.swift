//
//  GroupCreateFeature.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import ComposableArchitecture
import CommonDomain
import ModyGroupInterface

@Reducer
public struct GroupCreateFeature {
    private let groupUseCase: GroupUseCaseProtocol

    @ObservableState
    public struct State: Equatable {
        enum AlertCase: Equatable {
            case error(NetworkError)
        }

        let showsBackButton: Bool
        var groupName: String = ""
        var isLoading: Bool = false
        var alertCase: AlertCase?
        let maxGroupNameCount = 14

        var isGroupNameValid: Bool? {
            guard !groupName.isEmpty else { return nil }
            return groupName.count <= maxGroupNameCount
        }

        var groupNameErrorMessage: String? {
            guard isGroupNameValid == false else { return nil }
            return "최대 \(maxGroupNameCount)자까지 입력할 수 있어요."
        }

        var isNextButtonEnabled: Bool {
            isGroupNameValid == true && !isLoading
        }

        public init(showsBackButton: Bool = true) {
            self.showsBackButton = showsBackButton
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case backButtonTapped
        case nextButtonTapped
        case createGroupSuccessfully(code: String)
        case createGroupFailure(NetworkError)
    }

    public init(groupUseCase: GroupUseCaseProtocol) {
        self.groupUseCase = groupUseCase
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .nextButtonTapped:
                guard state.isNextButtonEnabled else { return .none }
                let groupName = state.groupName
                state.isLoading = true

                return .run { send in
                    do {
                        let code = try await groupUseCase.createGroup(name: groupName)
                        await send(.createGroupSuccessfully(code: code))
                    } catch let error as NetworkError {
                        await send(.createGroupFailure(error))
                    } catch {
                        await send(.createGroupFailure(.unknown))
                    }
                }
            case .createGroupSuccessfully:
                state.isLoading = false
                return .none
            case let .createGroupFailure(error):
                state.isLoading = false
                state.alertCase = .error(error)
                return .none
            case .backButtonTapped:
                return .none
            }
        }
    }
}
