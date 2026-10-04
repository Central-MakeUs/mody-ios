//
//  GroupInviteFeatureTests.swift
//  ModyGroupTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import ComposableArchitecture
import XCTest
@testable import ModyGroup

@MainActor
final class GroupInviteFeatureTests: XCTestCase {
    func testEmptyCodeDoesNotShowCopyFeedback() async {
        let store = makeStore(state: .init(inviteCode: "", groupName: "우리 그룹"))

        await store.send(.copyButtonTapped)

        XCTAssertFalse(store.state.isCodeCopied)
    }

    func testShareUsesInviteDetailsAndClearsLoadingOnSuccess() async {
        let share = ShareGroupInviteSpy()
        let store = makeStore(share: share)

        await store.send(.shareButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(\.shareSucceeded) {
            $0.isLoading = false
        }

        XCTAssertEqual(share.requests.count, 1)
        XCTAssertEqual(share.requests.first?.code, "ABCD1234")
        XCTAssertEqual(share.requests.first?.groupName, "우리 그룹")
    }

    func testShareFailureClearsLoadingAndAllowsRetry() async {
        let share = ShareGroupInviteSpy()
        share.result = .failure(NetworkError.networkUnavailable)
        let store = makeStore(share: share)

        for _ in 0..<2 {
            await store.send(.shareButtonTapped) {
                $0.isLoading = true
            }
            await store.receive(\.shareFailed) {
                $0.isLoading = false
            }
        }

        XCTAssertEqual(share.requests.count, 2)
    }

    private func makeStore(
        state: GroupInviteFeature.State = .init(
            inviteCode: "ABCD1234", groupName: "우리 그룹"
        ),
        share: ShareGroupInviteSpy? = nil
    ) -> TestStoreOf<GroupInviteFeature> {
        let share = share ?? ShareGroupInviteSpy()
        return TestStore(initialState: state) {
            GroupInviteFeature(shareGroupInviteUseCase: share)
        }
    }
}
