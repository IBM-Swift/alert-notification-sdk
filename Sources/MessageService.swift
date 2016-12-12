//
//  MessageService.swift
//  AlertNotifications
//
//  Created by Jim Avery on 12/8/16.
//
//

import Foundation

import LoggerAPI

public class MessageService {
    public class func post(_ message: Message, usingCredentials credentials: ServerCredentials, callback: ((Message?, Error?) -> Void)? = nil) throws {
        guard let bluemixRequest = BluemixRequest(usingCredentials: credentials) else {
            throw AlertNotificationError.CredentialsError("Invalid URL provided.")
        }
        let errors = [400: "The service reported an invalid request.", 401: "Authorization is invalid.", 415: "Invalid media type for message."]
        let bluemixCallback = MessageService.messageCallbackBuilder(statusResponses: errors, withFinalCallback: callback)
        try bluemixRequest.postMessage(message, callback: bluemixCallback)
    }
    
    public class func get(shortId id: String, usingCredentials credentials: ServerCredentials, callback: @escaping (Message?, Error?) -> Void) throws {
        guard let bluemixRequest = BluemixRequest(usingCredentials: credentials) else {
            throw AlertNotificationError.CredentialsError("Invalid URL provided.")
        }
        let errors = [401: "Authorization is invalid.", 404: "A message matching this short ID could not be found."]
        let bluemixCallback = MessageService.messageCallbackBuilder(statusResponses: errors, withFinalCallback: callback)
        try bluemixRequest.getMessage(shortId: id, callback: bluemixCallback)
    }
    
    // Create a callback function for when we are expecting a Message object in response.
    private class func messageCallbackBuilder(statusResponses: [Int: String], withFinalCallback callback: ((Message?, Error?) -> Void)? = nil) -> (Data?, URLResponse?, Swift.Error?) -> Void {
        return { (data: Data?, response: URLResponse?, error: Swift.Error?) in
            // Possible error #1: no data received.
            if data == nil {
                if callback != nil {
                    if error == nil {
                        callback!(nil, AlertNotificationError.HTTPError("Payload from server is empty."))
                    } else {
                        callback!(nil, error)
                    }
                }
                Log.error("Payload from server is empty.")
                if error != nil {
                    Log.error(error!.localizedDescription)
                }
                return
            }
            
            // Possible error #2: error received.
            if error != nil {
                if callback != nil {
                    callback!(nil, error)
                }
                Log.error(error!.localizedDescription)
                return
            }
            
            // Possible error #3: bad response code from the server.
            if let httpResponse = response as? HTTPURLResponse, let errMessage = statusResponses[httpResponse.statusCode] {
                if callback != nil {
                    callback!(nil, AlertNotificationError.BluemixError(errMessage))
                }
                Log.error(errMessage)
                return
            }
            
            // Possible error #4: malformed response data.
            guard let messageResponse = Message(data: data!) else {
                if callback != nil {
                    callback!(nil, AlertNotificationError.HTTPError("Malformed response from server."))
                }
                Log.error("Malformed response from server.")
                return
            }
            
            // Finally, perform the callback on the data.
            if callback != nil {
                callback!(messageResponse, nil)
            }
        }
    }
}
