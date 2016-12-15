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
    if let error = error {
        print("\(error.localizedDescription)")
        print("\(error)")
    } else {
        print("No error")
        print("\(alert)")
        print("\(alert?.id)")
        print("\(alert?.shortId)")
    }
    allFinished = true
}

func testGetAlertCallback(alert: Alert?, error: Error?) {
    if let error = error {
        print("\(error.localizedDescription)")
        print("\(error)")
    } else {
        print("No error")
        print("\(alert)")
        print("\(alert?.id)")
        print("\(alert?.shortId)")
    }
    allFinished = true
}

func testDeleteAlertCallback(error: Error?) {
    if let error = error {
        print("\(error.localizedDescription)")
        print("\(error)")
    } else {
        print("No error")
    }
    allFinished = true
}

func testPostMessageCallback(message: Message?, error: Error?) {
    if let error = error {
        print("\(error.localizedDescription)")
        print("\(error)")
    } else {
        print("No error")
        print("\(message)")
        print("\(message?.subject)")
        print("\(message?.shortId)")
    }
    allFinished = true
}

func testGetMessageCallback(message: Message?, error: Error?) {
    if let error = error {
        print("\(error.localizedDescription)")
        print("\(error)")
    } else {
        print("No error")
        print("\(message)")
        print("\(message?.subject)")
        print("\(message?.shortId)")
    }
    allFinished = true
}

print("Go")

let creds = ServiceCredentials(url: "https://ibmnotifybm.mybluemix.net/api", name: "37921d79-f951-41ab-ae96-2144636d6852/0dc957dd-e500-4a27-8e45-6f856feb4d36", password: "QfkE673GZO+1X2MfUrYRdXTVenEgU2X6")

let testAlert = try Alert.Builder().setSummary("TestWhat").setLocation("TestWhere").setSeverity(.fatal).setID("TestID").setDate(fromIntInMilliseconds: 0).setStatus(.problem).setSource("TestSource").setApplicationsOrServices(["TestApps"]).setURLs([Alert.URL(description: "TestDesc", URL: "TestURL"),Alert.URL(description: "TestDesc2", URL: "TestURL2")]).setDetails([Alert.Detail(name: "TestName", value: "TestValue"),Alert.Detail(name: "TestName2", value: "TestValue2")]).setEmailMessageToSend(Alert.EmailMessage(subject: "TestSubject", body: "TestBody")).setSMSMessageToSend("TestSMS").setVoiceMessageToSend("TestVoice").build()
print(testAlert)

//let _ = try AlertService.post(testAlert, usingCredentials: creds, callback: testPostAlertCallback)
//
//while allFinished != true {}

//allFinished = false
//
//let _ = try AlertService.get(shortId: "26-0", usingCredentials: creds, callback: testGetAlertCallback)
//
//while allFinished != true {}
//
//allFinished = false
//
//let _ = try AlertService.delete(shortId: "26-0", usingCredentials: creds, callback: testDeleteAlertCallback)
//
//while allFinished != true {}

// Testing the Message flow

//let testRecipient = Message.Recipient(name: "Jim Avery", type: .user)
//let testMessage = try Message(subject: "testSubject", message: "testMessage", recipients: [Message.Recipient(name: "Jim Avery", type: .user)])
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
