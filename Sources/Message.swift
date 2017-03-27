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

public class Message {
    /*
     * Internally defined classes.
     */
    public struct Recipient {
        public let name: String
        public let type: RecipientType
        public var broadcast: String?
        public init(name: String, type: RecipientType, broadcast: String? = nil) throws {
            self.name = name
            self.type = type
            self.broadcast = broadcast
            
            // In the case of an Integration message, the broadcast is required.
            if self.type == .integration && self.broadcast == nil {
                throw AlertNotificationError.messageError("The \"broadcast\" property must be provided for recipients of type .integration.")
            }
        }
    }
    
    public enum RecipientType: String {
        case user, group, integration
    }
    
    /*
     * Instance variables.
     */
    
    // Required variables.
    public let subject: String
    public let message: String
    public let recipients: [Recipient]
    
    // Optional variables (sent from the server).
    public private(set) var shortId: String?
    public private(set) var internalTime: Date?
    
    /*
     * Initializers.
     */
    public init(subject: String, message: String, recipients: [Recipient]) throws {
        if subject.characters.count > 80 {
            throw AlertNotificationError.messageError("Message subject cannot be longer than 80 characters.")
        }
        self.subject = subject
        if message.characters.count > 1500 {
            throw AlertNotificationError.messageError("Message body cannot be longer than 1500 characters.")
        }
        self.message = message
        self.recipients = recipients
    }
    
    // Create a Message from a JSON string.
    init?(data: Data) {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = json as? [String: Any] else {
            return nil
        }
        
        // Mandatory properties.
        if let subject = dictionary["Subject"] as? String {
            self.subject = subject
        } else {
            return nil
        }
        if let message = dictionary["Message"] as? String {
            self.message = message
        } else {
            return nil
        }
        if let recipients = dictionary["Recipients"] as? [[String: String]] {
            var recipientArray = [Recipient]()
            for recipient in recipients {
                if let name = recipient["Name"], let typeValue = recipient["Type"], let type = RecipientType(rawValue: typeValue.lowercased()), let newRecipient = try? Recipient(name: name, type: type, broadcast: recipient["Broadcast"]) {
                    recipientArray.append(newRecipient)
                }
            }
            self.recipients = recipientArray
        } else {
            return nil
        }
            
        // Optional properties.
        if let shortId = dictionary["ShortId"] as? String {
            self.shortId = shortId
        }
        if let internalTime = dictionary["InternalTime"] as? Int {
            self.internalTime = Date(timeIntervalSince1970: (Double(internalTime)/1000.0) as TimeInterval)
        }
    }
    
    /*
     * Instance methods.
     */
    
    // Convert to JSON.
    func toJSONData() throws -> Data? {
        var postDict: Dictionary<String, Any> = Dictionary<String, Any>()
        postDict["Subject"] = self.subject
        postDict["Message"] = self.message
        
        var recipientArray = [Dictionary<String, String>]()
        for recipient in self.recipients {
            var recipientDict = Dictionary<String, String>()
            recipientDict["Name"] = recipient.name
            recipientDict["Type"] = recipient.type.rawValue.capitalized
            if let broadcast = recipient.broadcast {
                recipientDict["Broadcast"] = broadcast
            }
            recipientArray.append(recipientDict)
        }
        postDict["Recipients"] = recipientArray
        
        if let shortId = self.shortId {
            postDict["ShortId"] = shortId
        }
        if let internalTime = self.internalTime {
            postDict["InternalTime"] = Int(internalTime.timeIntervalSince1970 * 1000.0)
        }
        
        return try JSONSerialization.data(withJSONObject: postDict, options: [])
    }
}
