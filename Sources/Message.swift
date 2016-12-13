//
//  Messge.swift
//  AlertNotifications
//
//  Created by Jim Avery on 11/21/16.
//
//

import Foundation

public class Message {
    /*
     * Internally defined classes.
     */
    public struct Recipient {
        public let name: String
        public let type: RecipientType
        public var broadcast: String?
        public init?(name: String, type: RecipientType, broadcast: String? = nil) {
            self.name = name
            self.type = type
            self.broadcast = broadcast
            
            // In the case of an Integration message, the broadcast is required.
            if self.type == .integration && self.broadcast == nil {
                return nil
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
    public init?(subject: String, message: String, recipients: [Recipient]) {
        if subject.characters.count > 80 {
            return nil
        }
        self.subject = subject
        if message.characters.count > 1500 {
            return nil
        }
        self.message = message
        self.recipients = recipients
    }
    
    // Create a Message from a JSON string.
    internal init?(data: Data) {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let dictionary = json as? [String: Any] {
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
                    if let name = recipient["Name"], let typeValue = recipient["Type"], let type = RecipientType(rawValue: typeValue.lowercased()), let newRecipient = Recipient(name: name, type: type, broadcast: recipient["Broadcast"]) {
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
        } else {
            return nil
        }
    }
    
    /*
     * Instance methods.
     */
    
    // Convert to JSON.
    internal func toJSONData() throws -> Data? {
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
