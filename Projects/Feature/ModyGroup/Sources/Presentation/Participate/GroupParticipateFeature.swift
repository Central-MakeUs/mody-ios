//
//  GroupParticipateFeature.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import ComposableArchitecture
import CommonDomain

@Reducer
public struct GroupParticipateFeature {
    private let groupUseCase: GroupUseCase
    
    @ObservableState
    public struct State: Equatable {
        enum AlertCase: Equatable {
            case error(NetworkError)
        }
        
        enum JoinError: Equatable {
            case notFound
            case groupLimitExceeded
            
            var message: String {
                switch self {
                case .notFound: "존재하지 않는 코드입니다."
                case .groupLimitExceeded: "이미 인원이 꽉 찬 그룹이에요."
                }
            }
        }
        
        let showSignUpDoneContents: Bool
        let showsBackButton: Bool
        var inviteCode: String = ""
        var isLoading: Bool = false
        var joinError: JoinError?
        var alertCase: AlertCase?
        
        var isParticipateButtonEnabled: Bool {
            inviteCode.count == 8 && !isLoading
        }
        
        var isInviteCodeValid: Bool? {
            guard joinError != nil else { return nil }
            return false
        }
        
        public init(
            showSignUpDoneContents: Bool,
            showsBackButton: Bool
        ) {
            self.showSignUpDoneContents = showSignUpDoneContents
            self.showsBackButton = showsBackButton
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case backButtonTapped
        case participateButtonTapped
        case createButtonTapped
        case joinGroupSuccessfully
        case joinGroupFailure(NetworkError, code: String)
    }
    
    public init(groupUseCase: GroupUseCase) {
        self.groupUseCase = groupUseCase
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.inviteCode) { oldValue, newValue in
                Reduce { state, _ in
                    guard oldValue != newValue else { return .none }
                    state.joinError = nil
                    return .none
                }
            }
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .participateButtonTapped:
                guard state.isParticipateButtonEnabled else { return .none }
                let inviteCode = state.inviteCode
                let request = GroupJoinRequest(code: inviteCode)
                state.isLoading = true
                
                return .run { send in
                    do {
                        try await groupUseCase.joinGroup(request: request)
                        await send(.joinGroupSuccessfully)
                    } catch let error as NetworkError {
                        await send(.joinGroupFailure(error, code: inviteCode))
                    } catch {
                        await send(.joinGroupFailure(.unknown, code: inviteCode))
                    }
                }
            case .joinGroupSuccessfully:
                state.isLoading = false
                return .none
            case let .joinGroupFailure(error, code):
                state.isLoading = false
                guard state.inviteCode == code else { return .none }
                
                guard case let .serverError(code, _, fallback) = error else {
                    state.alertCase = .error(error)
                    return .none
                }
                
                switch code {
                case ServerErrorCode.group301.code:
                    state.joinError = .notFound
                case ServerErrorCode.group304.code:
                    state.joinError = .groupLimitExceeded
                default:
                    state.alertCase = .error(fallback)
                }
                return .none
                
            case .backButtonTapped:
                return .none
            case .createButtonTapped:
                return .none
            }
        }
    }
}
