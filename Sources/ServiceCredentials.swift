//
//  ServerCredentials.swift
//  AlertNotifications
//
//  Created by Jim Avery on 11/28/16.
//
//

import Foundation

public struct ServiceCredentials {
    public let url: String
    public let name: String
    public let password: String
    var authString: String {
        get {
            let rawString = "\(name):\(password)"
            return rawString.data(using: .utf8)!.base64EncodedString()
        }
    }
    
    public init(url: String, name: String, password: String) {
        self.url = ServiceCredentials.removeTrailingSlash(from: url)
        self.name = name
        self.password = password
    }
    
    private static func removeTrailingSlash(from url: String) -> String {
        var urlCopy = url
        var lastIndex = url.index(urlCopy.startIndex, offsetBy: urlCopy.characters.count-1)
        while urlCopy.characters.count > 1 && urlCopy[lastIndex] == "/" {
            urlCopy = urlCopy.substring(to: lastIndex)
            lastIndex = url.index(urlCopy.startIndex, offsetBy: urlCopy.characters.count-1)
        }
        return urlCopy
    }
}
