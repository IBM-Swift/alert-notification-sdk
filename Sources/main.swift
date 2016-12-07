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

func testPostCallback(alert: Alert?, error: Error?) {
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

func testGetCallback(alert: Alert?, error: Error?) {
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

func testDeleteCallback(statusCode: Int?, error: Error?) {
    if error != nil {
        print("\(error!.localizedDescription)")
        print("\(error!)")
    } else {
        print("No error")
        print("\(statusCode)")
    }
    allFinished = true
}

print("Go")

//let testAlert = try Alert.Builder().setSummary("Sample").setLocation("SampleWhere").setSeverity(.Indeterminate).setID("Experimental").build()
//print(testAlert.summary)
//print(testAlert.location)
//print(testAlert.severity)
//print(testAlert.id)
//let testAlert2 = try Alert.Builder(from: testAlert).setSummary("Sample2").build()
//print(testAlert2.summary)
//print(testAlert2.location)
//print(testAlert2.severity)
//print(testAlert2.id)

let creds = ServerCredentials(url: "https://ibmnotifybm.mybluemix.net/api", name: "37921d79-f951-41ab-ae96-2144636d6852/0dc957dd-e500-4a27-8e45-6f856feb4d36", password: "QfkE673GZO+1X2MfUrYRdXTVenEgU2X6")
//let testAlert = try Alert.Builder().setSummary("Sample").setLocation("SampleWhere").setSeverity(.Indeterminate).setID("Experimental").build()
//print(testAlert)
//
//let _ = try testAlert.post(usingCredentials: creds, callback: testPostCallback)
//
//while allFinished != true {}

//allFinished = false
//
//let _ = try Alert.get(shortId: "15-0", usingCredentials: creds, callback: testGetCallback)
//
//while allFinished != true {}

allFinished = false

let _ = try Alert.delete(shortId: "15-0", usingCredentials: creds, callback: testDeleteCallback)

while allFinished != true {}

print("Stop")
