//
//  Messge.swift
//  AlertNotifications
//
//  Created by Jim Avery on 11/21/16.
//
//

import Foundation

class Message {
    /*
     * Instance variables.
     */
    
    // Required variables.
    let subject: String
    let message: String
    let recipients: [Recipient]
    
    // Optional variables (sent from the server).
    private(set) var shortId: String?
    private(set) var internalTime: Date?
    
    /*
     * Initializers.
     */
    init(subject: String, message: String, recipients: [Recipient]) {
        self.subject = subject
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
                    if let name = recipient["Name"], let typeValue = recipient["Type"], let type = RecipientType(rawValue: typeValue), let newRecipient = Recipient(name: name, type: type, broadcast: recipient["Broadcast"]) {
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
    func toJSONData() throws -> Data? {
        var postDict: Dictionary<String, Any> = Dictionary<String, Any>()
        postDict["Subject"] = self.subject
        postDict["Message"] = self.message
        
        var recipientArray = [Dictionary<String, String>]()
        for recipient in self.recipients {
            var recipientDict = Dictionary<String, String>()
            recipientDict["Name"] = recipient.name
            recipientDict["Type"] = recipient.type.rawValue
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
