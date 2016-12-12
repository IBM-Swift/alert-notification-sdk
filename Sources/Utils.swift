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

internal func createSession() -> URLSession {
    let basicConfig = URLSessionConfiguration.`default`
    return URLSession(configuration: basicConfig)
}

enum AlertNotificationError: Error, CustomStringConvertible {
    case AlertError(String)
    case MessageError(String)
    case HTTPError(String)
    case BluemixError(String)
    case CredentialsError(String)
    
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
        case .CredentialsError(let message):
            return "Credentials error: \(message)"
        }
    }
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

internal func getSeverity(from str: String) -> Severity? {
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

/*
 * Message-related utils.
 */

struct Recipient {
    let name: String
    let type: RecipientType
    var broadcast: String?
    init?(name: String, type: RecipientType, broadcast: String? = nil) {
        self.name = name
        self.type = type
        self.broadcast = broadcast
        
        // In the case of an Integration message, the broadcast is required.
        if self.type == .Integration && self.broadcast == nil {
            return nil
        }
    }
}

enum RecipientType: String {
    case User, Group, Integration
}
