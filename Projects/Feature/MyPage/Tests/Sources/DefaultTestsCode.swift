import Foundation
import XCTest
@testable import MyPage

final class MyPageTests: XCTestCase {
    func testProfileUpdateRequestEncodesImageKeyWhenPresent() throws {
        let request = MyPageProfileUpdateRequest(
            nickname: "민석",
            birthDate: "2000-01-01",
            imageKey: "profiles/1/2026/07/profile.jpg"
        )
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(request))
                as? [String: Any]
        )

        XCTAssertEqual(json["nickname"] as? String, "민석")
        XCTAssertEqual(json["birthDate"] as? String, "2000-01-01")
        XCTAssertEqual(
            json["imageKey"] as? String,
            "profiles/1/2026/07/profile.jpg"
        )
    }

    func testProfileUpdateRequestOmitsImageKeyWhenAbsent() throws {
        let request = MyPageProfileUpdateRequest(
            nickname: "민석",
            birthDate: "2000-01-01"
        )
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(request))
                as? [String: Any]
        )

        XCTAssertNil(json["imageKey"])
    }
}
