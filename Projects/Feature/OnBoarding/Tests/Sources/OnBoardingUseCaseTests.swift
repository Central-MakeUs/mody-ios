import CommonDomain
import XCTest
@testable import OnBoarding

final class OnBoardingUseCaseTests: XCTestCase {
    func testPassesProfileRequestToRepositoryAndReturnsMemberID() async throws {
        let repository = OnBoardingRepositorySpy(result: .success(42))
        let request = makeProfileRequest()

        let memberID = try await OnBoardingUseCase(onBoardingRepository: repository)
            .setupOnBoardingProfileInfo(request: request)

        XCTAssertEqual(memberID, 42)
        XCTAssertEqual(repository.requests, [request])
    }

    func testPropagatesRepositoryError() async {
        let repository = OnBoardingRepositorySpy(result: .failure(NetworkError.networkUnavailable))

        do {
            _ = try await OnBoardingUseCase(onBoardingRepository: repository)
                .setupOnBoardingProfileInfo(request: makeProfileRequest())
            XCTFail("Expected repository error")
        } catch {
            XCTAssertEqual(error as? NetworkError, .networkUnavailable)
        }
        XCTAssertEqual(repository.requests.count, 1)
    }
}
