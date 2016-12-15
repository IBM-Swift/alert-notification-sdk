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
    public class func post(_ message: Message, usingCredentials credentials: ServiceCredentials, callback: ((Message?, Error?) -> Void)? = nil) throws {
        let bluemixRequest = try BluemixRequest(usingCredentials: credentials)
        let errors = [400: "The service reported an invalid request.", 401: "Authorization is invalid.", 415: "Invalid media type for message."]
        let bluemixCallback = MessageService.messageCallbackBuilder(statusResponses: errors, withFinalCallback: callback)
        try bluemixRequest.postMessage(message, callback: bluemixCallback)
    }
    
    public class func get(shortId id: String, usingCredentials credentials: ServiceCredentials, callback: @escaping (Message?, Error?) -> Void) throws {
        let bluemixRequest = try BluemixRequest(usingCredentials: credentials)
        let errors = [401: "Authorization is invalid.", 404: "A message matching this short ID could not be found."]
        let bluemixCallback = MessageService.messageCallbackBuilder(statusResponses: errors, withFinalCallback: callback)
        try bluemixRequest.getMessage(shortId: id, callback: bluemixCallback)
    }
    
    // Create a callback function for when we are expecting a Message object in response.
    private class func messageCallbackBuilder(statusResponses: [Int: String], withFinalCallback callback: ((Message?, Error?) -> Void)? = nil) -> (Data?, URLResponse?, Swift.Error?) -> Void {
        return { (data: Data?, response: URLResponse?, error: Swift.Error?) in
            // Possible error #1: error received.
            if let error = error {
                callback?(nil, error)
                Log.error(error.localizedDescription)
                return
            }
            
            // Possible error #2: bad response code from the server.
            if let httpResponse = response as? HTTPURLResponse, let errMessage = statusResponses[httpResponse.statusCode] {
                callback?(nil, AlertNotificationError.bluemixError(errMessage))
                Log.error(errMessage)
                return
            }
            
            if let data = data {
                // Possible error #3: malformed response data.
                guard let messageResponse = Message(data: data) else {
                    callback?(nil, AlertNotificationError.HTTPError("Malformed response from server."))
                    Log.error("Malformed response from server.")
                    return
                }
                
                // Perform the callback on the data.
                callback?(messageResponse, nil)
            } else {
                // Possible error #4: no data received.
                if let error = error {
                    callback?(nil, error)
                    Log.error(error.localizedDescription)
                } else {
                    callback?(nil, AlertNotificationError.HTTPError("Payload from server is empty."))
                }
                Log.error("Payload from server is empty.")
                return
            }
        }
    }
}
