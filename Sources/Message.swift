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
                    if let name = recipient["Name"], let type = RecipientType(rawValue: recipient["Type"]) {
                        let broadcast: String? = recipient["Broadcast"]
                        recipientArray.append(Recipient(name: name, type: type, broadcast: broadcast))
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
}
