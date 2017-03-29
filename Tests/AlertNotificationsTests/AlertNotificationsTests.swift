/**
 * Copyright IBM Corporation 2016,2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
@testable import AlertNotifications

class AlertNotificationsTests: XCTestCase {
    // Get a generic alert.
    class func getAlertForTest() throws -> Alert {
        return try Alert.Builder().setSummary("TestSummary").setLocation("TestLocation").setSeverity(.fatal).setID("TestID").setDate(fromIntInMilliseconds: 0).setStatus(.problem).setSource("TestSource").setApplicationsOrServices(["TestApps"]).setURLs([Alert.URL(description: "TestDesc", URL: "TestURL")]).setDetails([Alert.Detail(name: "TestName", value: "TestValue")]).setEmailMessageToSend(Alert.EmailMessage(subject: "TestSubject", body: "TestBody")).setSMSMessageToSend("TestSMS").setVoiceMessageToSend("TestVoice").build()
    }
    
    // Get a generic message.
    class func getMessageForTest() throws -> Message {
        return try Message(subject: "TestSubject", message: "TestMessage", recipients: [Message.Recipient(name: "TestUser", type: .user, broadcast: "TestBroadcast")])
    }
    
    // Get our credentials, which are filled in during CI testing.
    class func getCredentialsForTest() throws -> ServiceCredentials {
        let config = try Configuration(withFile: "Tests/cloud_config.json")
        return try config.getAlertNotificationService(forService: "alert-notification-sdk")
    }
    
    // Ensure that the Alert object can correctly be written out to a JSON string.
    func testAlertToJSON() throws {
        let newAlert = try AlertNotificationsTests.getAlertForTest()
        XCTAssertNotNil(newAlert)
        guard let alertBody = try newAlert.toJSONData() else {
            throw AlertNotificationError.alertError("Could not convert Alert to JSON.")
        }
        XCTAssertNotNil(alertBody)
        guard let alertJsonString = String(data: alertBody, encoding: .utf8) else {
            throw AlertNotificationError.alertError("Could not convert Alert to String.")
        }
        XCTAssertNotNil(alertJsonString)
        
        // Ensure the JSON data was written out correctly.
        XCTAssert(alertJsonString.contains("\"What\":\"TestSummary\""))
        XCTAssert(alertJsonString.contains("\"Where\":\"TestLocation\""))
        XCTAssert(alertJsonString.contains("\"Severity\":6"))
        XCTAssert(alertJsonString.contains("\"Identifier\":\"TestID\""))
        XCTAssert(alertJsonString.contains("\"When\":0"))
        XCTAssert(alertJsonString.contains("\"Type\":\"Problem\""))
        XCTAssert(alertJsonString.contains("\"Source\":\"TestSource\""))
        XCTAssert(alertJsonString.contains("\"ApplicationsOrServices\":[\"TestApps\"]"))
        XCTAssert(alertJsonString.contains("\"URLs\":[{"))
        XCTAssert(alertJsonString.contains("\"URL\":\"TestURL\""))
        XCTAssert(alertJsonString.contains("\"Description\":\"TestDesc\""))
        XCTAssert(alertJsonString.contains("\"Details\":[{"))
        XCTAssert(alertJsonString.contains("\"Name\":\"TestName\""))
        XCTAssert(alertJsonString.contains("\"Value\":\"TestValue\""))
        XCTAssert(alertJsonString.contains("\"EmailMessageToSend\":{"))
        XCTAssert(alertJsonString.contains("\"Subject\":\"TestSubject\""))
        XCTAssert(alertJsonString.contains("\"Body\":\"TestBody\""))
        XCTAssert(alertJsonString.contains("\"SMSMessageToSend\":\"TestSMS\""))
        XCTAssert(alertJsonString.contains("\"VoiceMessageToSend\":\"TestVoice\""))
    }
    
    // Run through the full POST/GET/DELETE alert suite with an actual Bluemix service.
    func testAlertServices() throws {
        let testExpectation = expectation(description: "Runs through POST, GET and DELETE for alerts on a Bluemix instance.")
        var shortId: String? = nil
        let credentials = try AlertNotificationsTests.getCredentialsForTest()
        
        func postCallback(alert: Alert?, error: Swift.Error?) {
            if let error = error {
                XCTFail("POST returned with error: \(error)")
                testExpectation.fulfill()
                return
            }
            if alert == nil {
                XCTFail("POST request returned null Alert object.")
                testExpectation.fulfill()
                return
            }
            XCTAssertEqual("TestID", alert?.id)
            guard let alertId = alert?.shortId else {
                XCTFail("POSTed Alert object has no short ID. Cannot inue with testing.")
                testExpectation.fulfill()
                return
            }
            shortId = alertId
            do {
                try AlertService.get(shortId: shortId!, usingCredentials: credentials, callback: getCallback)
            } catch {
                XCTFail("GET failed with error: \(error)")
                testExpectation.fulfill()
            }
        }
        
        func getCallback(alert: Alert?, error: Swift.Error?) {
            if let error = error {
                XCTFail("GET returned with error: \(error)")
                testExpectation.fulfill()
                return
            }
            if alert == nil {
                XCTFail("GET request returned null Alert object.")
                testExpectation.fulfill()
                return
            }
            XCTAssertEqual("TestID", alert?.id)
            if alert?.shortId == nil {
                XCTFail("Alert from GET request has no short ID for unknown reasons.")
                testExpectation.fulfill()
                return
            }
            guard shortId == alert?.shortId else {
                XCTFail("Alert from GET request has incorrect short ID for unknown reasons.")
                testExpectation.fulfill()
                return
            }
            do {
                try AlertService.delete(shortId: shortId!, usingCredentials: credentials, callback: deleteCallback)
            } catch {
                XCTFail("DELETE failed with error: \(error)")
                testExpectation.fulfill()
            }
        }
        
        func deleteCallback(error: Swift.Error?) {
            if let error = error {
                XCTFail("DELETE returned with error: \(error)")
            }
            
            testExpectation.fulfill()
        }
        
        let newAlert = try AlertNotificationsTests.getAlertForTest()
        
        do {
            try AlertService.post(newAlert, usingCredentials: credentials, callback: postCallback)
        } catch {
            XCTFail("Alert services test failed: \(error)")
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 60) { error in
            if error != nil {
                XCTFail("waitForExpectations errored: \(String(describing: error))")
            }
        }
    }
    
    // Ensure that the Message object can correctly be written out to a JSON string.
    func testMessageToJSON() throws {
        let newMessage = try AlertNotificationsTests.getMessageForTest()
        XCTAssertNotNil(newMessage)
        guard let messageBody = try newMessage.toJSONData() else {
            throw AlertNotificationError.messageError("Could not convert Message object to JSON.")
        }
        XCTAssertNotNil(messageBody)
        guard let messageJsonString = String(data: messageBody, encoding: .utf8) else {
            throw AlertNotificationError.messageError("Could not convert Message object to String.")
        }
        XCTAssertNotNil(messageJsonString)
        
        // Ensure the JSON data was written out correctly.
        XCTAssert(messageJsonString.contains("\"Message\":\"TestMessage\""))
        XCTAssert(messageJsonString.contains("\"Subject\":\"TestSubject\""))
        XCTAssert(messageJsonString.contains("\"Recipients\":[{"))
        XCTAssert(messageJsonString.contains("\"Type\":\"User\""))
        XCTAssert(messageJsonString.contains("\"Name\":\"TestUser\""))
        XCTAssert(messageJsonString.contains("\"Broadcast\":\"TestBroadcast\""))
    }
    
    // Run through the full POST/GET message suite with an actual Bluemix service.
    func testMessageServices() throws {
        let testExpectation = expectation(description: "Runs through POST and GET for messages on a Bluemix instance.")
        var shortId: String? = nil
        let credentials = try AlertNotificationsTests.getCredentialsForTest()
        
        func postCallback(message: Message?, error: Swift.Error?) {
            if let error = error {
                XCTFail("POST returned with error: \(error)")
                testExpectation.fulfill()
                return
            }
            if message == nil {
                XCTFail("POST request returned null Message object.")
                testExpectation.fulfill()
                return
            }
            XCTAssertEqual("TestSubject", message?.subject)
            guard let messageId = message?.shortId else {
                XCTFail("POSTed Message object has no short ID. Cannot continue with testing.")
                testExpectation.fulfill()
                return
            }
            shortId = messageId
            do {
                try MessageService.get(shortId: shortId!, usingCredentials: credentials, callback: getCallback)
            } catch {
                XCTFail("GET failed with error: \(error)")
                testExpectation.fulfill()
            }
        }
        
        func getCallback(message: Message?, error: Swift.Error?) {
            if let error = error {
                XCTFail("GET returned with error: \(error)")
                testExpectation.fulfill()
                return
            }
            if message == nil {
                XCTFail("GET request returned null Message object.")
                testExpectation.fulfill()
                return
            }
            XCTAssertEqual("TestSubject", message?.subject)
            guard let messageId = message?.shortId else {
                XCTFail("Message from GET request has no short ID for unknown reasons.")
                testExpectation.fulfill()
                return
            }
            if messageId != shortId {
                XCTFail("Message from GET request has incorrect short ID for unknown reasons.")
            }
            
            testExpectation.fulfill()
        }
        
        let newMessage = try AlertNotificationsTests.getMessageForTest()
        
        do {
            try MessageService.post(newMessage, usingCredentials: credentials, callback: postCallback)
        } catch {
            XCTFail("Message services test failed: \(error)")
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 60) { error in
            if error != nil {
                XCTFail("waitForExpectations errored: \(String(describing: error))")
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
