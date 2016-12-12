//
//  AlertService.swift
//  AlertNotifications
//
//  Created by Jim Avery on 12/7/16.
//
//

import Foundation

import LoggerAPI

class AlertService {
    class func post(_ alert: Alert, usingCredentials credentials: ServerCredentials, callback: ((Alert?, Error?) -> Void)? = nil) throws {
        guard let bluemixRequest = BluemixRequest(usingCredentials: credentials) else {
            throw AlertNotificationError.CredentialsError("Invalid URL provided.")
        }
        let errors = [208: "This error has already been reported.", 400: "The service reported an invalid request.", 401: "Authorization is invalid.", 415: "Invalid media type for alert."]
        let bluemixCallback = AlertService.alertCallbackBuilder(statusResponses: errors, withFinalCallback: callback)
        try bluemixRequest.postAlert(alert, callback: bluemixCallback)
    }
    
    class func get(shortId id: String, usingCredentials credentials: ServerCredentials, callback: (Alert?, Error?) -> Void) throws {
        guard let bluemixRequest = BluemixRequest(usingCredentials: credentials) else {
            throw AlertNotificationError.CredentialsError("Invalid URL provided.")
        }
        let errors = [401: "Authorization is invalid.", 404: "An alert matching this short ID could not be found."]
        let bluemixCallback = AlertService.alertCallbackBuilder(statusResponses: errors, withFinalCallback: callback)
        try bluemixRequest.getAlert(shortId: id, callback: bluemixCallback)
    }
    
    class func delete(shortId id: String, usingCredentials credentials: ServerCredentials, callback: ((Error?) -> Void)? = nil) throws {
        guard let bluemixRequest = BluemixRequest(usingCredentials: credentials) else {
            throw AlertNotificationError.CredentialsError("Invalid URL provided.")
        }
        try bluemixRequest.deleteAlert(shortId: id) { (data, response, error) in
            // Possible error #1: error received.
            if error != nil {
                if callback != nil {
                    callback!(error)
                }
                Log.error(error!.localizedDescription)
                return
            }
            
            // Possible error #2: bad response code from the server.
            guard let httpResponse = response as? HTTPURLResponse else {
                if callback != nil {
                    callback!(AlertNotificationError.HTTPError("Could not parse the HTTP response from the server."))
                }
                Log.error("Could not parse the HTTP response from the server.")
                return
            }
            var bluemixError: String? = nil
            switch httpResponse.statusCode {
            case 401:
                bluemixError = "Authorization is invalid."
            case 404:
                bluemixError = "The alert could not be found."
            case 500:
                bluemixError = "There was an error archiving the alert."
            default:
                break
            }
            if bluemixError != nil {
                if callback != nil {
                    callback!(AlertNotificationError.BluemixError(bluemixError!))
                }
                Log.error(bluemixError!)
                return
            }
            
            // Finally, perform the callback on the response.
            if callback != nil {
                callback!(nil)
            }
        }
    }
    
    // Create a callback function for when we are expecting an Alert object in response.
    private class func alertCallbackBuilder(statusResponses: [Int: String], withFinalCallback callback: ((Alert?, Error?) -> Void)? = nil) -> (Data?, URLResponse?, Swift.Error?) -> Void {
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
            guard let alertResponse = Alert(data: data!) else {
                if callback != nil {
                    callback!(nil, AlertNotificationError.HTTPError("Malformed response from server."))
                }
                Log.error("Malformed response from server.")
                return
            }
            
            // Finally, perform the callback on the data.
            if callback != nil {
                callback!(alertResponse, nil)
            }
        }
    }
}
