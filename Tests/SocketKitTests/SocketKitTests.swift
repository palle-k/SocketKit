import XCTest
@testable import SocketKit

class SocketKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(SocketKit().text, "Hello, World!")
    }


    static var allTests : [(String, (SocketKitTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
