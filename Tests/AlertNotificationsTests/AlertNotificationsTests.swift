import XCTest
@testable import AlertNotifications

class AlertNotificationsTests: XCTestCase {
    // Ensure that the Alert object can correctly be written out to a JSON string.
    func testAlertPostBody() {
        let newAlert = Alert(what: "TestWhat", where: "TestWhere", severity: .Fatal, id: "TestID", when: 0, type: .Problem, source: "TestSource", applicationsOrServices: ["TestApps"], URLs: [AlertURL(description: "TestDesc", URL: "TestURL")], details: [Detail(name: "TestName", value: "TestValue")], emailMessageToSend: EmailMessage(subject: "TestSubject", body: "TestBody"), smsMessageToSend: "TestSMS", voiceMessageToSend: "TestVoice")
        XCTAssertNotNil(newAlert)
        let alertBody = newAlert!.postBody()
        XCTAssertNotNil(alertBody)
        let alertJsonString = String(data: alertBody!, encoding: .utf8)
        XCTAssertNotNil(alertJsonString)
        
        // Ensure the JSON data was written out correctly.
        XCTAssert(alertJsonString!.contains("\"What\":\"TestWhat\""))
        XCTAssert(alertJsonString!.contains("\"Where\":\"TestWhere\""))
        XCTAssert(alertJsonString!.contains("\"Severity\":6"))
        XCTAssert(alertJsonString!.contains("\"Identifier\":\"TestID\""))
        XCTAssert(alertJsonString!.contains("\"When\":\"1969-12-31 18:00:00\""))
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
    func testAlertPost() {
//        let newAlert = Alert(what: "TestWhat", where: "TestWhere", severity: .Fatal, id: "TestID", when: 0, type: .Problem, source: "TestSource", applicationsOrServices: ["TestApps"], URLs: [AlertURL(description: "TestDesc", URL: "TestURL")], details: [Detail(name: "TestName", value: "TestValue")], emailMessageToSend: EmailMessage(subject: "TestSubject", body: "TestBody"), smsMessageToSend: "TestSMS", voiceMessageToSend: "TestVoice")
//        XCTAssertNotNil(newAlert)
//        
//        func testCallback(data: Alert?, error: Error?) {
//            
//        }
//        
//        let testURL = URL(string: "http://localhost:3000")
//        newAlert!.post(to: testURL, callback: testCallback)
    }
    
    // Ensure that the alert class GET function works correctly.
    func testAlertGet() {
        let retrievedAlert = Alert.get(id: "foo")
        XCTAssertNil(retrievedAlert)
    }
    
    // Ensure that the alert class DELETE function works correctly.
    func testAlertDelete() {
        
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
