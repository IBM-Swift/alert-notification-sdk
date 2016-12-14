import XCTest
//import Kitura
//import KituraNet
@testable import AlertNotifications

class AlertNotificationsTests: XCTestCase {
    // Get a generic alert.
    class func getAlertForTest() throws -> Alert {
        return try Alert.Builder().setSummary("TestWhat").setLocation("TestWhere").setSeverity(.fatal).setID("TestID").setDate(fromIntInMilliseconds: 0).setStatus(.problem).setSource("TestSource").setApplicationsOrServices(["TestApps"]).setURLs([Alert.URL(description: "TestDesc", URL: "TestURL")]).setDetails([Alert.Detail(name: "TestName", value: "TestValue")]).setEmailMessageToSend(Alert.EmailMessage(subject: "TestSubject", body: "TestBody")).setSMSMessageToSend("TestSMS").setVoiceMessageToSend("TestVoice").build()
    }
    
    // Get a generic message.
    class func getMessageForTest() throws -> Message {
        return try Message(subject: "TestSubject", message: "TestMessage", recipients: [Message.Recipient(name: "TestUser", type: .user, broadcast: "TestBroadcast")?])
    }
    
    // Get our credentials, which are filled in during CI testing.
    class func getCredentialsForTest() -> AlertServiceCredentials {
        return AlertServiceCredentials(url: "https://ibmnotifybm.mybluemix.net/api", name: "37921d79-f951-41ab-ae96-2144636d6852/0dc957dd-e500-4a27-8e45-6f856feb4d36", password: "QfkE673GZO+1X2MfUrYRdXTVenEgU2X6")
    }
    
    // Ensure that the Alert object can correctly be written out to a JSON string.
    func testAlertToJSON() throws {
        let newAlert = try AlertNotificationsTests.getAlertForTest()
        XCTAssertNotNil(newAlert)
        let alertBody = try newAlert.toJSONData()
        XCTAssertNotNil(alertBody)
        let alertJsonString = String(data: alertBody?, encoding: .utf8)
        XCTAssertNotNil(alertJsonString)
        
        // Ensure the JSON data was written out correctly.
        XCTAssert(alertJsonString?.contains("\"What\":\"TestWhat\""))
        XCTAssert(alertJsonString?.contains("\"Where\":\"TestWhere\""))
        XCTAssert(alertJsonString?.contains("\"Severity\":6"))
        XCTAssert(alertJsonString?.contains("\"Identifier\":\"TestID\""))
        XCTAssert(alertJsonString?.contains("\"When\":0"))
        XCTAssert(alertJsonString?.contains("\"Type\":\"Problem\""))
        XCTAssert(alertJsonString?.contains("\"Source\":\"TestSource\""))
        XCTAssert(alertJsonString?.contains("\"ApplicationsOrServices\":[\"TestApps\"]"))
        XCTAssert(alertJsonString?.contains("\"URLs\":[{"))
        XCTAssert(alertJsonString?.contains("\"URL\":\"TestURL\""))
        XCTAssert(alertJsonString?.contains("\"Description\":\"TestDesc\""))
        XCTAssert(alertJsonString?.contains("\"Details\":[{"))
        XCTAssert(alertJsonString?.contains("\"Name\":\"TestName\""))
        XCTAssert(alertJsonString?.contains("\"Value\":\"TestValue\""))
        XCTAssert(alertJsonString?.contains("\"EmailMessageToSend\":{"))
        XCTAssert(alertJsonString?.contains("\"Subject\":\"TestSubject\""))
        XCTAssert(alertJsonString?.contains("\"Body\":\"TestBody\""))
        XCTAssert(alertJsonString?.contains("\"SMSMessageToSend\":\"TestSMS\""))
        XCTAssert(alertJsonString?.contains("\"VoiceMessageToSend\":\"TestVoice\""))
    }
    
    // Run through the full POST/GET/DELETE alert suite with an actual Bluemix service.
    func testAlertServices() throws {
        let testExpectation = expectation(description: "Runs through POST, GET and DELETE for alerts on a Bluemix instance.")
        var shortId: String? = nil
        let credentials = AlertNotificationsTests.getCredentialsForTest()
        
        func postCallback(alert: Alert?, error: Swift.Error?) {
            if error != nil {
                XCTFail("POST returned with error: \(error?)")
                testExpectation.fulfill()
            } else if alert == nil {
                XCTFail("POST request returned null Alert object.")
                testExpectation.fulfill()
            } else {
                XCTAssertEqual("TestID", alert?.id)
                if alert?.shortId != nil {
                    shortId = alert?.shortId
                    do {
                        try AlertService.get(shortId: shortId?, usingCredentials: credentials, callback: getCallback)
                    } catch {
                        XCTFail("GET failed with error: \(error)")
                        testExpectation.fulfill()
                    }
                } else {
                    XCTFail("POSTed Alert object has no short ID. Cannot continue with testing.")
                    testExpectation.fulfill()
                }
            }
        }
        
        func getCallback(alert: Alert?, error: Swift.Error?) {
            if error != nil {
                XCTFail("GET returned with error: \(error?)")
                testExpectation.fulfill()
            } else if alert == nil {
                XCTFail("GET request returned null Alert object.")
                testExpectation.fulfill()
            } else {
                XCTAssertEqual("TestID", alert?.id)
                if alert?.shortId == nil {
                    XCTFail("Alert from GET request has no short ID for unknown reasons.")
                    testExpectation.fulfill()
                } else if alert?.shortId != shortId {
                    XCTFail("Alert from GET request has incorrect short ID for unknown reasons.")
                    testExpectation.fulfill()
                } else {
                    do {
                        try AlertService.delete(shortId: shortId?, usingCredentials: credentials, callback: deleteCallback)
                    } catch {
                        XCTFail("DELETE failed with error: \(error)")
                        testExpectation.fulfill()
                    }
                }
            }
        }
        
        func deleteCallback(error: Swift.Error?) {
            if error != nil {
                XCTFail("DELETE returned with error: \(error?)")
            }
            
            testExpectation.fulfill()
        }
        
        let newAlert = try AlertNotificationsTests.getAlertForTest()
        
        do {
            let _ = try AlertService.post(newAlert, usingCredentials: credentials, callback: postCallback)
        } catch {
            XCTFail("Alert services test failed: \(error)")
        }
        
        waitForExpectations(timeout: 60) { error in
            if error != nil {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
    }
    
    // Ensure that the Message object can correctly be written out to a JSON string.
    func testMessageToJSON() throws {
        let newMessage = try AlertNotificationsTests.getMessageForTest()
        XCTAssertNotNil(newMessage)
        let messageBody = try newMessage.toJSONData()
        XCTAssertNotNil(messageBody)
        let messageJsonString = String(data: messageBody?, encoding: .utf8)
        XCTAssertNotNil(messageJsonString)
        
        // Ensure the JSON data was written out correctly.
        XCTAssert(messageJsonString?.contains("\"Message\":\"TestMessage\""))
        XCTAssert(messageJsonString?.contains("\"Subject\":\"TestSubject\""))
        XCTAssert(messageJsonString?.contains("\"Recipients\":[{"))
        XCTAssert(messageJsonString?.contains("\"Type\":\"User\""))
        XCTAssert(messageJsonString?.contains("\"Name\":\"TestUser\""))
        XCTAssert(messageJsonString?.contains("\"Broadcast\":\"TestBroadcast\""))
    }
    
    // Run through the full POST/GET message suite with an actual Bluemix service.
    func testMessageServices() throws {
        let testExpectation = expectation(description: "Runs through POST and GET for messages on a Bluemix instance.")
        var shortId: String? = nil
        let credentials = AlertNotificationsTests.getCredentialsForTest()
        
        func postCallback(message: Message?, error: Swift.Error?) {
            if error != nil {
                XCTFail("POST returned with error: \(error?)")
                testExpectation.fulfill()
            } else if message == nil {
                XCTFail("POST request returned null Message object.")
                testExpectation.fulfill()
            } else {
                XCTAssertEqual("TestSubject", message?.subject)
                if message?.shortId != nil {
                    shortId = message?.shortId
                    do {
                        try MessageService.get(shortId: shortId?, usingCredentials: credentials, callback: getCallback)
                    } catch {
                        XCTFail("GET failed with error: \(error)")
                        testExpectation.fulfill()
                    }
                } else {
                    XCTFail("POSTed Message object has no short ID. Cannot continue with testing.")
                    testExpectation.fulfill()
                }
            }
        }
        
        func getCallback(message: Message?, error: Swift.Error?) {
            if error != nil {
                XCTFail("GET returned with error: \(error?)")
            } else if message == nil {
                XCTFail("GET request returned null Message object.")
            } else {
                XCTAssertEqual("TestSubject", message?.subject)
                if message?.shortId == nil {
                    XCTFail("Message from GET request has no short ID for unknown reasons.")
                } else if message?.shortId != shortId {
                    XCTFail("Message from GET request has incorrect short ID for unknown reasons.")
                }
            }
            
            testExpectation.fulfill()
        }
        
        let newMessage = try AlertNotificationsTests.getMessageForTest()
        
        do {
            let _ = try MessageService.post(newMessage, usingCredentials: credentials, callback: postCallback)
        } catch {
            XCTFail("Message services test failed: \(error)")
        }
        
        waitForExpectations(timeout: 60) { error in
            if error != nil {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
    }
    
    // Test the entire flow actually going through Bluemix.

    static var allTests : [(String, (AlertNotificationsTests) -> () throws -> Void)] {
        return [
            ("testAlertToJSON", testAlertToJSON),
            ("testAlertServices", testAlertServices),
            ("testMessageToJSON", testMessageToJSON),
            ("testMessageServices", testMessageServices)
        ]
    }
}
