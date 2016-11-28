import XCTest
@testable import AlertNotifications

class AlertNotificationsTests: XCTestCase {
    func testPostBody() {
        let newAlert = Alert(what: "Test", where: "Test", severity: .Fatal)
        let alertBody = newAlert.postBody()
        XCTAssertNotNil(alertBody)
        XCTAssertEqual("{\"Severity\":6,\"What\":\"Test\",\"Where\":\"Test\"}", String(data: alertBody!, encoding: .utf8))
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //XCTAssertEqual(AlertNotifications().text, "Hello, World!")
    }


    static var allTests : [(String, (AlertNotificationsTests) -> () throws -> Void)] {
        return [
            ("testPostBody", testPostBody),
            ("testExample", testExample)
        ]
    }
}
