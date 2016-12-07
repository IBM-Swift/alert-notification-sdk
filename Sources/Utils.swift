//
//  Utils.swift
//  AlertNotifications
//
//  Created by Jim Avery on 11/21/16.
//
//

import Foundation

/*
 * Generic utils.
 */

enum RequestType: String {
    case Alert, Message
}

func createSession() -> URLSession {
    let basicConfig = URLSessionConfiguration.`default`
    return URLSession(configuration: basicConfig)
}

/*
 * Alert-related utils.
 */

struct AlertURL {
    let description: String
    let URL: String
    init(description: String, URL: String) {
        self.description = description
        self.URL = URL
    }
}

struct Detail {
    let name: String
    let value: String
    init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

struct EmailMessage {
    let subject: String
    let body: String
    init(subject: String, body: String) {
        self.subject = subject
        self.body = body
    }
}

enum Severity: Int {
    case Clear = 0, Indeterminate, Warning, Minor, Major, Critical, Fatal
}

enum AlertStatus: String {
    case Problem, Acknowledged, Resolved
}

enum NotificationState: String {
    case Unnotified, Notified, Acknowledged, Archived, Escalated
}

enum AlertNotificationError: Error, CustomStringConvertible {
    case AlertError(String)
    case MessageError(String)
    case HTTPError(String)
    case BluemixError(String)
    
    var description: String {
        switch self {
        case .AlertError(let message):
            return "Alert error: \(message)"
        case .MessageError(let message):
            return "Message error: \(message)"
        case .HTTPError(let message):
            return "HTTP error: \(message)"
        case .BluemixError(let message):
            return "Bluemix error: \(message)"
        }
    }
}

func getSeverity(from str: String) -> Severity? {
    switch str.lowercased() {
        case "fatal": return .Fatal
        case "critical": return .Critical
        case "major": return .Major
        case "minor": return .Minor
        case "warning": return .Warning
        case "indeterminate": return .Indeterminate
        case "clear": return .Clear
        default: return nil
    }
}
