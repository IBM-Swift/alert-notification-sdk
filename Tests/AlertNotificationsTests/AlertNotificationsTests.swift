import XCTest
//import Kitura
//import KituraNet
@testable import AlertNotifications

class AlertNotificationsTests: XCTestCase {
    // Get a generic alert.
    class func getAlertForTest() throws -> Alert {
        return try Alert.Builder().setSummary("TestWhat").setLocation("TestWhere").setSeverity(.Fatal).setID("TestID").setDate(fromIntInMilliseconds: 0).setStatus(.Problem).setSource("TestSource").setApplicationsOrServices(["TestApps"]).setURLs([AlertURL(description: "TestDesc", URL: "TestURL")]).setDetails([Detail(name: "TestName", value: "TestValue")]).setEmailMessageToSend(EmailMessage(subject: "TestSubject", body: "TestBody")).setSMSMessageToSend("TestSMS").setVoiceMessageToSend("TestVoice").build()
    }
    
    // Get our credentials, which are filled in during CI testing.
    class func getCredentialsForTest() -> ServerCredentials {
        return ServerCredentials(url: "https://ibmnotifybm.mybluemix.net/api", name: "37921d79-f951-41ab-ae96-2144636d6852/0dc957dd-e500-4a27-8e45-6f856feb4d36", password: "QfkE673GZO+1X2MfUrYRdXTVenEgU2X6")
    }
    
//    override class func setUp() {
//        super.setUp()
//        
//        let router = Router()
//        router.get("/alerts/v1/:id") { req, res, next in
//            let responseAlert = try getAlertForTest()
//            try res.send(data: responseAlert.postBody()!).end()
//        }
//        router.post("/alerts/v1") { req, res, next in
//            let responseAlert = try getAlertForTest()
//            try res.send(data: responseAlert.postBody()!).end()
//        }
//        router.delete("/alerts/v1/:id") { req, res, next in
//            res.statusCode = HTTPStatusCode.noContent
//            try res.send("Successful request").end()
//        }
//        
//        Kitura.addHTTPServer(onPort: 3000, with: router)
//        
//        Kitura.start()
//    }
//    
//    override class func tearDown() {
//        super.tearDown()
//        
//        Kitura.stop()
//    }
    
    // Ensure that the Alert object can correctly be written out to a JSON string.
    func testAlertToJSON() throws {
        let newAlert = try AlertNotificationsTests.getAlertForTest()
        XCTAssertNotNil(newAlert)
        let alertBody = try newAlert.toJSONData()
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
    
    // Run through the full POST/GET/DELETE alert suite with an actual Bluemix service.
    func testAlertServices() throws {
        let testExpectation = expectation(description: "Runs through POST, GET and DELETE on a Bluemix instance.")
        var shortId: String? = nil
        let credentials = AlertNotificationsTests.getCredentialsForTest()
        
        func postCallback(alert: Alert?, error: Swift.Error?) {
            if error != nil {
                XCTFail("POST returned with error: \(error!)")
                testExpectation.fulfill()
            } else if alert == nil {
                XCTFail("POST request returned null Alert object.")
                testExpectation.fulfill()
            } else {
                XCTAssertEqual("TestID", alert!.id)
                if alert!.shortId != nil {
                    shortId = alert!.shortId
                    do {
                        try AlertService.get(shortId: shortId!, usingCredentials: credentials, callback: getCallback)
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
                XCTFail("GET returned with error: \(error!)")
                testExpectation.fulfill()
            } else if alert == nil {
                XCTFail("GET request returned null Alert object.")
                testExpectation.fulfill()
            } else {
                XCTAssertEqual("TestID", alert!.id)
                if alert!.shortId == nil {
                    XCTFail("Alert from GET request has no short ID for unknown reasons.")
                    testExpectation.fulfill()
                } else if alert!.shortId != shortId {
                    XCTFail("Alert from GET request has incorrect short ID for unknown reasons.")
                    testExpectation.fulfill()
                } else {
                    do {
                        try AlertService.delete(shortId: shortId!, usingCredentials: credentials, callback: deleteCallback)
                    } catch {
                        XCTFail("DELETE failed with error: \(error)")
                        testExpectation.fulfill()
                    }
                }
            }
        }
        
        func deleteCallback(statusCode: Int?, error: Swift.Error?) {
            if error != nil {
                XCTFail("DELETE returned with error: \(error!)")
            } else {
                XCTAssertNotNil(statusCode)
                XCTAssertEqual(statusCode, 204)
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
    
//    // Ensure that the alert POST function works correctly.
//    func testAlertPost() throws {
//        let testExpectation = expectation(description: "Calls a POST request on our small Kitura server.")
//        
//        let newAlert = try AlertNotificationsTests.getAlertForTest()
//        XCTAssertNotNil(newAlert)
//        
//        func testCallback(alert: Alert?, error: Swift.Error?) {
//            if error != nil {
//                XCTFail("POST returned with error: \(error!)")
//            } else {
//                XCTAssertNotNil(alert)
//                XCTAssertEqual("TestID", alert!.id)
//            }
//            testExpectation.fulfill()
//        }
//        
//        let creds = ServerCredentials(url: "http://localhost:3000", name: "foo", password: "bar")
//        do {
//            let _ = try newAlert.post(usingCredentials: creds, callback: testCallback)
//        } catch AlertNotificationError.AlertError(let errorMessage) {
//            XCTFail("POST request failed: \(errorMessage)")
//        }
//        
//        waitForExpectations(timeout: 10) { error in
//            if error != nil {
//                XCTFail("waitForExpectations errored: \(error)")
//            }
//        }
//    }
//    
//    // Ensure that the alert class GET function works correctly.
//    func testAlertGet() throws {
//        let testExpectation = expectation(description: "Calls a GET request on our small Kitura server.")
//        
//        func testCallback(alert: Alert?, error: Swift.Error?) {
//            if error != nil {
//                XCTFail("GET returned with error: \(error!)")
//            } else {
//                XCTAssertNotNil(alert)
//                XCTAssertEqual("TestID", alert!.id)
//            }
//            testExpectation.fulfill()
//        }
//        
//        let creds = ServerCredentials(url: "http://localhost:3000", name: "foo", password: "bar")
//        do {
//            let _ = try Alert.get(shortId: "fooId", usingCredentials: creds, callback: testCallback)
//        } catch AlertNotificationError.AlertError(let errorMessage) {
//            XCTFail("GET request failed: \(errorMessage)")
//        }
//        
//        waitForExpectations(timeout: 10) { error in
//            if error != nil {
//                XCTFail("waitForExpectations errored: \(error)")
//            }
//        }
//    }
//    
//    // Ensure that the alert class DELETE function works correctly.
//    func testAlertDelete() throws {
//        let testExpectation = expectation(description: "Calls a DELETE request on our small Kitura server.")
//        
//        func testCallback(statusCode: Int?, error: Swift.Error?) {
//            if error != nil {
//                XCTFail("DELETE returned with error: \(error!)")
//            } else {
//                XCTAssertNotNil(statusCode)
//                XCTAssertEqual(statusCode, 204)
//            }
//            testExpectation.fulfill()
//        }
//        
//        let creds = ServerCredentials(url: "http://localhost:3000", name: "foo", password: "bar")
//        do {
//            let _ = try Alert.delete(shortId: "fooId", usingCredentials: creds, callback: testCallback)
//        } catch AlertNotificationError.AlertError(let errorMessage) {
//            XCTFail("DELETE request failed: \(errorMessage)")
//        }
//        
//        waitForExpectations(timeout: 10) { error in
//            if error != nil {
//                XCTFail("waitForExpectations errored: \(error)")
//            }
//        }
//    }
    
    // Test the entire flow actually going through Bluemix.

    static var allTests : [(String, (AlertNotificationsTests) -> () throws -> Void)] {
        return [
            ("testAlertToJSON", testAlertToJSON),
            ("testAlertServices", testAlertServices)
        ]
    }
}
