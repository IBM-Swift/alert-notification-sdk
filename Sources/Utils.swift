//
//  Utils.swift
//  AlertNotifications
//
//  Created by Jim Avery on 11/21/16.
//
//

/*
 * Generic utils.
 */

enum HTTPMethod: Int {
    case Get = 0, Post, Delete
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

enum AlertType: String {
    case Problem, Acknowledged, Resolved
}

enum NotificationState: String {
    case Unnotified, Notified, Acknowledged, Archived, Escalated
}

enum AlertNotificationError: Error {
    case AlertError(String)
    case MessageError(String)
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
