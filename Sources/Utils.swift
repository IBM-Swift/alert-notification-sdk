//
//  Utils.swift
//  AlertNotifications
//
//  Created by Jim Avery on 11/21/16.
//
//

import Foundation

public enum AlertNotificationError: Error, CustomStringConvertible {
    case alertError(String)
    case messageError(String)
    case HTTPError(String)
    case bluemixError(String)
    case credentialsError(String)
    
    public var description: String {
        switch self {
        case .alertError(let message):
            return "Alert error: \(message)"
        case .messageError(let message):
            return "Message error: \(message)"
        case .HTTPError(let message):
            return "HTTP error: \(message)"
        case .bluemixError(let message):
            return "Bluemix error: \(message)"
        case .credentialsError(let message):
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
    case clear = 0, indeterminate, warning, minor, major, critical, fatal
}

public enum AlertStatus: String {
    case problem, acknowledged, resolved
}

public enum NotificationState: String {
    case unnotified, notified, acknowledged, archived, escalated
}

internal func getSeverity(from str: String) -> Severity? {
    switch str.lowercased() {
        case "fatal": return .fatal
        case "critical": return .critical
        case "major": return .major
        case "minor": return .minor
        case "warning": return .warning
        case "indeterminate": return .indeterminate
        case "clear": return .clear
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
        if self.type == .integration && self.broadcast == nil {
            return nil
        }
    }
}

public enum RecipientType: String {
    case user, group, integration
}
