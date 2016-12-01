import XCTest
import Kitura
import KituraNet
@testable import AlertNotifications

class AlertNotificationsTests: XCTestCase {
    // Get a generic alert.
    class func getAlertForTest() -> Alert? {
        return Alert(what: "TestWhat", where: "TestWhere", severity: .Fatal, id: "TestID", when: 0, type: .Problem, source: "TestSource", applicationsOrServices: ["TestApps"], URLs: [AlertURL(description: "TestDesc", URL: "TestURL")], details: [Detail(name: "TestName", value: "TestValue")], emailMessageToSend: EmailMessage(subject: "TestSubject", body: "TestBody"), smsMessageToSend: "TestSMS", voiceMessageToSend: "TestVoice")
    }
    
    override class func setUp() {
        super.setUp()
        
        let router = Router()
        router.get("/:id") { req, res, next in
            let responseAlert = getAlertForTest()
            try res.send(data: responseAlert!.postBody()!).end()
        }
        router.post("/") { req, res, next in
            let responseAlert = getAlertForTest()
            try res.send(data: responseAlert!.postBody()!).end()
        }
        router.delete("/:id") { req, res, next in
            res.statusCode = HTTPStatusCode.noContent
            try res.send("Successful request").end()
        }
        
        Kitura.addHTTPServer(onPort: 3000, with: router)
        
        Kitura.start()
    }
    
    override class func tearDown() {
        super.tearDown()
        
        Kitura.stop()
    }
    
    // Ensure that the Alert object can correctly be written out to a JSON string.
    func testAlertPostBody() throws {
        let newAlert = AlertNotificationsTests.getAlertForTest()
        XCTAssertNotNil(newAlert)
        let alertBody = try newAlert!.postBody()
        XCTAssertNotNil(alertBody)
        let alertJsonString = String(data: alertBody!, encoding: .utf8)
        XCTAssertNotNil(alertJsonString)
        
        // Ensure the JSON data was written out correctly.
        XCTAssert(alertJsonString!.contains("\"What\":\"TestWhat\""))
        XCTAssert(alertJsonString!.contains("\"Where\":\"TestWhere\""))
        XCTAssert(alertJsonString!.contains("\"Severity\":6"))
        XCTAssert(alertJsonString!.contains("\"Identifier\":\"TestID\""))
        XCTAssert(alertJsonString!.contains("\"When\":0"))
        XCTAssert(alertJsonString!.contains("\"Type\":\"Problem\""))
        XCTAssert(alertJsonString!.contains("\"Source\":\"TestSource\""))
        XCTAssert(alertJsonString!.contains("\"ApplicationsOrServices\":[\"TestApps\"]"))
        XCTAssert(alertJsonString!.contains("\"URLs\":[{"))
        XCTAssert(alertJsonString!.contains("\"URL\":\"TestURL\""))
        XCTAssert(alertJsonString!.contains("\"Description\":\"TestDesc\""))
        XCTAssert(alertJsonString!.contains("\"Details\":[{"))
        XCTAssert(alertJsonString!.contains("\"Name\":\"TestName\""))
        XCTAssert(alertJsonString!.contains("\"Value\":\"TestValue\""))
        XCTAssert(alertJsonString!.contains("\"EmailMessageToSend\":{"))
        XCTAssert(alertJsonString!.contains("\"Subject\":\"TestSubject\""))
        XCTAssert(alertJsonString!.contains("\"Body\":\"TestBody\""))
        XCTAssert(alertJsonString!.contains("\"SMSMessageToSend\":\"TestSMS\""))
        XCTAssert(alertJsonString!.contains("\"VoiceMessageToSend\":\"TestVoice\""))
    }
    
    // Ensure that the alert POST function works correctly.
    func testAlertPost() throws {
        let testExpectation = expectation(description: "Calls a POST request on our small Kitura server.")
        
        let newAlert = AlertNotificationsTests.getAlertForTest()
        XCTAssertNotNil(newAlert)
        
        func testCallback(alert: Alert?, error: Swift.Error?) {
            if error != nil {
                XCTFail("POST returned with error: \(error!.localizedDescription)")
            } else {
                XCTAssertNotNil(alert)
                XCTAssertEqual("TestID", alert!.id)
            }
            testExpectation.fulfill()
        }
        
        let creds = ServerCredentials(url: "http://localhost:3000", name: "foo", password: "bar")
        do {
            let _ = try newAlert!.post(usingCredentials: creds, callback: testCallback)
        } catch AlertNotificationError.AlertError(let errorMessage) {
            XCTFail("POST request failed: \(errorMessage)")
        }
        
        waitForExpectations(timeout: 10) { error in
            if error != nil {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
    }
    
    // Ensure that the alert class GET function works correctly.
    func testAlertGet() throws {
        let testExpectation = expectation(description: "Calls a GET request on our small Kitura server.")
        
        func testCallback(alert: Alert?, error: Swift.Error?) {
            if error != nil {
                XCTFail("GET returned with error: \(error!.localizedDescription)")
            } else {
                XCTAssertNotNil(alert)
                XCTAssertEqual("TestID", alert!.id)
            }
            testExpectation.fulfill()
        }
        
        let creds = ServerCredentials(url: "http://localhost:3000", name: "foo", password: "bar")
        do {
            let _ = try Alert.get(shortId: "fooId", usingCredentials: creds, callback: testCallback)
        } catch AlertNotificationError.AlertError(let errorMessage) {
            XCTFail("GET request failed: \(errorMessage)")
        }
        
        waitForExpectations(timeout: 10) { error in
            if error != nil {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
    }
    
    // Ensure that the alert class DELETE function works correctly.
    func testAlertDelete() throws {
        let testExpectation = expectation(description: "Calls a DELETE request on our small Kitura server.")
        
        func testCallback(statusCode: Int?, error: Swift.Error?) {
            if error != nil {
                XCTFail("DELETE returned with error: \(error!.localizedDescription)")
            } else {
                XCTAssertNotNil(statusCode)
                XCTAssertEqual(statusCode, 204)
            }
            testExpectation.fulfill()
        }
        
        let creds = ServerCredentials(url: "http://localhost:3000", name: "foo", password: "bar")
        do {
            let _ = try Alert.delete(shortId: "fooId", usingCredentials: creds, callback: testCallback)
        } catch AlertNotificationError.AlertError(let errorMessage) {
            XCTFail("DELETE request failed: \(errorMessage)")
        }
        
        waitForExpectations(timeout: 10) { error in
            if error != nil {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
    }

    static var allTests : [(String, (AlertNotificationsTests) -> () throws -> Void)] {
        return [
            ("testAlertPostBody", testAlertPostBody),
            ("testAlertPost", testAlertPost),
            ("testAlertGet", testAlertGet),
            ("testAlertDelete", testAlertDelete)
        ]
    }
}
