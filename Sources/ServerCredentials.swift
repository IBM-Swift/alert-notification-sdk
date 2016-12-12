//
//  ServerCredentials.swift
//  AlertNotifications
//
//  Created by Jim Avery on 11/28/16.
//
//

import Foundation

public struct ServerCredentials {
    public let url: String
    public let name: String
    public let password: String
    internal var authString: String {
        get {
            let rawString = "\(name):\(password)"
            return rawString.data(using: .utf8)!.base64EncodedString()
        }
    }
    
    init(url: String, name: String, password: String) {
        self.url = url
        self.name = name
        self.password = password
    }
}
