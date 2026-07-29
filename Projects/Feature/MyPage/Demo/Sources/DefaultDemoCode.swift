import CommonDomain
import CoreAuthInterface
import CoreModyImage
import SwiftUI
import MyPage

@main
struct MyPageDemoApp: App {
    var body: some Scene {
        WindowGroup {
            MyPageView(
                store: .init(initialState: MyPageFeature.State()) {
                    MyPageFeature(
                        authUseCase: MyPageDemoAuthUseCase(),
                        myPageUseCase: MyPageUseCase(
                            myPageRepository: MyPageDemoRepository()
                        ),
                        router: { _ in },
                        output: { _ in }
                    )
                },
                imageLoader: NukeRemoteImageLoader.shared
            )
        }
    }
}

private struct MyPageDemoAuthUseCase: AuthUseCaseProtocol {
    func signIn(
        loginType: SocialLoginType,
        accessToken: String
    ) async throws -> AuthSession {
        throw CancellationError()
    }

    func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo {
        UserInfo(
            memberId: 0,
            nickname: "나는야화영",
            profileImageUrl: nil,
            daysTogether: 20,
            personalInfoCompleted: true,
            groupOnboardingCompleted: true,
            mainAccessible: true
        )
    }

    func logout() async throws {}

    func deleteAccount() async throws {}
}

private struct MyPageDemoRepository: MyPageRepositoryProtocol {
    func getMyPageProfile() async throws -> MyPageProfile {
        MyPageProfile(
            socialLoginType: .kakao,
            name: "김모디",
            birthDate: "2000-01-01"
        )
    }

    func updateMyPageProfile(
        _ request: MyPageProfileUpdateRequest
    ) async throws {}

    func getWeightRecord() async throws -> WeightRecord {
        WeightRecord(
            startWeightKg: 56,
            currentWeightKg: 53,
            targetWeightKg: 50
        )
    }

    func postRecordWeight(recordedOn: String, weightKg: Double) async throws {}
}
