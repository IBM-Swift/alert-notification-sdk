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
