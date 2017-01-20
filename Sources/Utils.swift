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
