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
        self.url = ServiceCredentials.removeTrailingSlash(from: url)
        self.name = name
        self.password = password
    }
    
    // Trim off a trailing slash from the URL.
    private static func removeTrailingSlash(from url: String) -> String {
        var urlCopy = url
        var lastIndex = urlCopy.index(urlCopy.startIndex, offsetBy: urlCopy.characters.count-1)
        while urlCopy.characters.count > 1 && urlCopy[lastIndex] == "/" {
            urlCopy = urlCopy.substring(to: lastIndex)
            lastIndex = urlCopy.index(urlCopy.startIndex, offsetBy: urlCopy.characters.count-1)
        }
        return urlCopy
    }
}
