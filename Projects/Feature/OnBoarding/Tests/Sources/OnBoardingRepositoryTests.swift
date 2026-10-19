import CommonDomain
import CoreNetworkInterface
import Foundation
import XCTest
@testable import OnBoarding

final class OnBoardingRepositoryTests: XCTestCase {
    func testPostsAuthorizedProfileRequestAndReturnsMemberID() async throws {
        let response = try JSONDecoder().decode(
            OnBoardingProfileResponse.self,
            from: Data(#"{"memberId":42}"#.utf8)
        )
        let network = OnBoardingNetworkSpy(result: .success(CoreNetworkResponse(result: response)))
        let request = makeProfileRequest()

        let memberID = try await OnBoardingRepository(network: network)
            .postSetupOnBoardingProfileInfo(request: request)

        XCTAssertEqual(memberID, 42)
        XCTAssertEqual(network.endpoints.count, 1)
        XCTAssertEqual(network.endpoints.first?.path, "api/v1/onboarding/profile")
        XCTAssertEqual(network.endpoints.first?.method, .POST)
        XCTAssertEqual(network.endpoints.first?.requiresAuthorization, true)
        XCTAssertEqual(network.endpoints.first?.bodyParameters as? OnBoardingProfileRequest, request)
    }

    func testMissingMemberIDIsInvalidResponse() async {
        let network = OnBoardingNetworkSpy(result: .success(CoreNetworkResponse(result: nil)))

        do {
            _ = try await OnBoardingRepository(network: network)
                .postSetupOnBoardingProfileInfo(request: makeProfileRequest())
            XCTFail("Expected invalid response")
        } catch {
            XCTAssertEqual(error as? NetworkError, .invalidResponse)
        }
    }

    func testPropagatesNetworkFailure() async {
        let network = OnBoardingNetworkSpy(result: .failure(NetworkError.timeout))

        do {
            _ = try await OnBoardingRepository(network: network)
                .postSetupOnBoardingProfileInfo(request: makeProfileRequest())
            XCTFail("Expected network failure")
        } catch {
            XCTAssertEqual(error as? NetworkError, .timeout)
        }
        XCTAssertEqual(network.endpoints.count, 1)
    }
}
