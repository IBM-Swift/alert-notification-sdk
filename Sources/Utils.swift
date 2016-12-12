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

public enum AlertNotificationError: Error, CustomStringConvertible {
    case AlertError(String)
    case MessageError(String)
    case HTTPError(String)
    case BluemixError(String)
    case CredentialsError(String)
    
    public var description: String {
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

public struct AlertURL {
    public let description: String
    public let URL: String
    public init(description: String, URL: String) {
        self.description = description
        self.URL = URL
    }
}

public struct Detail {
    public let name: String
    public let value: String
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

public struct EmailMessage {
    public let subject: String
    public let body: String
    public init(subject: String, body: String) {
        self.subject = subject
        self.body = body
    }
}

public enum Severity: Int {
    case Clear = 0, Indeterminate, Warning, Minor, Major, Critical, Fatal
}

public enum AlertStatus: String {
    case Problem, Acknowledged, Resolved
}

public enum NotificationState: String {
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

public struct Recipient {
    public let name: String
    public let type: RecipientType
    public var broadcast: String?
    public init?(name: String, type: RecipientType, broadcast: String? = nil) {
        self.name = name
        self.type = type
        self.broadcast = broadcast
        
        // In the case of an Integration message, the broadcast is required.
        if self.type == .Integration && self.broadcast == nil {
            return nil
        }
    }
}

public enum RecipientType: String {
    case User, Group, Integration
}
