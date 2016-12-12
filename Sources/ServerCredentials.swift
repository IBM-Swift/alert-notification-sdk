//
//  ServerCredentials.swift
//  AlertNotifications
//
//  Created by Jim Avery on 11/28/16.
//
//

import Foundation

struct ServerCredentials {
    let url: String
    let name: String
    let password: String
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
