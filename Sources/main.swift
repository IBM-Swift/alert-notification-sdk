//
//  main.swift
//  AlertNotifications
//
//  Created by Jim Avery on 12/1/16.
//
//

import Foundation

import LoggerAPI

var allFinished: Bool = false

func testPostAlertCallback(alert: Alert?, error: Error?) {
    if error != nil {
        print("\(error!.localizedDescription)")
        print("\(error!)")
    } else {
        print("No error")
        print("\(alert)")
        print("\(alert?.id)")
    }
    allFinished = true
}

func testGetAlertCallback(alert: Alert?, error: Error?) {
    if error != nil {
        print("\(error!.localizedDescription)")
        print("\(error!)")
    } else {
        print("No error")
        print("\(alert)")
        print("\(alert?.id)")
    }
    allFinished = true
}

func testDeleteAlertCallback(error: Error?) {
    if error != nil {
        print("\(error!.localizedDescription)")
        print("\(error!)")
    } else {
        print("No error")
    }
    allFinished = true
}

func testPostMessageCallback(message: Message?, error: Error?) {
    if error != nil {
        print("\(error!.localizedDescription)")
        print("\(error!)")
    } else {
        print("No error")
        print("\(message)")
        print("\(message!.subject)")
        print("\(message!.shortId)")
    }
    allFinished = true
}

func testGetMessageCallback(message: Message?, error: Error?) {
    if error != nil {
        print("\(error!.localizedDescription)")
        print("\(error!)")
    } else {
        print("No error")
        print("\(message)")
        print("\(message!.subject)")
        print("\(message!.shortId)")
    }
    allFinished = true
}

print("Go")

let creds = ServerCredentials(url: "https://ibmnotifybm.mybluemix.net/api", name: "37921d79-f951-41ab-ae96-2144636d6852/0dc957dd-e500-4a27-8e45-6f856feb4d36", password: "QfkE673GZO+1X2MfUrYRdXTVenEgU2X6")

// Testing Alert.Builder

//let testAlert = Alert.Builder().setSummary("Sample").setLocation("SampleWhere").setSeverity(.Indeterminate).setID("Experimental").setURLs([AlertURL(description: "SampleDescription", URL: "SampleURL")]).build()
//print(testAlert!.summary)
//print(testAlert!.location)
//print(testAlert!.severity)
//print(testAlert!.id)
//let testAlert2 = Alert.Builder(from: testAlert).setSummary("Sample2").build()
//print(testAlert2!.summary)
//print(testAlert2!.location)
//print(testAlert2!.severity)
//print(testAlert2!.id)

// Testing the Alert flow

//let testAlert = try Alert.Builder().setSummary("Sample").setLocation("SampleWhere").setSeverity(.Indeterminate).setID("Experimental").setURLs([AlertURL(description: "SampleDescription", URL: "SampleURL"),AlertURL(description: "SampleDescription2", URL: "SampleURL2")]).build()
let testAlert = Alert.Builder().setSummary("TestWhat").setLocation("TestWhere").setSeverity(.Fatal).setID("TestID").setDate(fromIntInMilliseconds: 0).setStatus(.Problem).setSource("TestSource").setApplicationsOrServices(["TestApps"]).setURLs([AlertURL(description: "TestDesc", URL: "TestURL"),AlertURL(description: "TestDesc2", URL: "TestURL2")]).setDetails([Detail(name: "TestName", value: "TestValue"),Detail(name: "TestName2", value: "TestValue2")]).setEmailMessageToSend(EmailMessage(subject: "TestSubject", body: "TestBody")).setSMSMessageToSend("TestSMS").setVoiceMessageToSend("TestVoice").build()
print(testAlert!)

let _ = try AlertService.post(testAlert!, usingCredentials: creds, callback: testPostAlertCallback)

while allFinished != true {}

//allFinished = false
//
//let _ = try AlertService.get(shortId: "15-0", usingCredentials: creds, callback: testGetAlertCallback)
//
//while allFinished != true {}

//allFinished = false
//
//let _ = try AlertService.delete(shortId: "20-0", usingCredentials: creds, callback: testDeleteAlertCallback)
//
//while allFinished != true {}

// Testing the Message flow

//let testMessage = Message(subject: "testSubject", message: "testMessage", recipients: [Recipient(name: "testUser", type: .User)!])!
//print("\(testMessage.subject)")
//print("\(testMessage.message)")
//print("\(testMessage.recipients)")
//
//let _ = try MessageService.post(testMessage, usingCredentials: creds, callback: testPostMessageCallback)
//
//while allFinished != true {}

//allFinished = false
//
//let _ = try MessageService.get(shortId: "2-2", usingCredentials: creds, callback: testGetMessageCallback)
//
//while allFinished != true {}

print("Stop")
