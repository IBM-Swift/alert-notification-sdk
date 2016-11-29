//
//  ServerCredentials.swift
//  AlertNotifications
//
//  Created by Jim Avery on 11/28/16.
//
//

import Foundation

struct ServerCredentials {
    static var host: String? = nil
    static var user: String? = nil
    static var password: String? = nil
    static var authString: String? {
        get {
            if user == nil || password == nil {
                return nil
            } else {
                let rawString = "\(user):\(password)"
                return rawString.data(using: .utf8)!.base64EncodedString()
            }
        }
    }
}
