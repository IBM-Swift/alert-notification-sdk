/**
 * Copyright IBM Corporation 2016,2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation

public struct ServiceCredentials {
    public let url: String
    public let name: String
    public let password: String
    // The string used for Basic authentication.
    var authString: String {
        get {
            let rawString = "\(name):\(password)"
            return rawString.data(using: .utf8)!.base64EncodedString()
        }
    }
    
    // Initializer.
    public init(url: String, name: String, password: String) {
        self.url = ServiceCredentials.trimURL(url)
        self.name = name
        self.password = password
    }
    
    // Remove "/alerts/v1" or "/messages/v1" from the end of the URL.
    private static func trimURL(_ url: String) -> String {
        let trimmedURL = ServiceCredentials.removeTrailingSlash(from: url)
        
        if trimmedURL.characters.count < 10 {
            return trimmedURL
        }
        
        let alertIndex = trimmedURL.index(trimmedURL.startIndex, offsetBy: trimmedURL.characters.count-10)
        if trimmedURL.substring(from: alertIndex) == "/alerts/v1" {
            return trimmedURL.substring(to: alertIndex)
        }
        
        if trimmedURL.characters.count < 12 {
            return trimmedURL
        }
        
        let messageIndex = trimmedURL.index(trimmedURL.startIndex, offsetBy: trimmedURL.characters.count-12)
        if trimmedURL.substring(from: messageIndex) == "/messages/v1" {
            return trimmedURL.substring(to: messageIndex)
        }
        
        return url
    }
    
    // Trim off a trailing slash from the URL.
    private static func removeTrailingSlash(from url: String) -> String {
        if url.characters.count < 1 {
            return url
        }
        
        var urlCopy = url
        var lastIndex = urlCopy.index(urlCopy.startIndex, offsetBy: urlCopy.characters.count-1)
        while urlCopy.characters.count > 1 && urlCopy[lastIndex] == "/" {
            urlCopy = urlCopy.substring(to: lastIndex)
            lastIndex = urlCopy.index(urlCopy.startIndex, offsetBy: urlCopy.characters.count-1)
        }
        return urlCopy
    }
}
