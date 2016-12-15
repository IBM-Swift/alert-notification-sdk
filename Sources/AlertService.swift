//
//  AlertService.swift
//  AlertNotifications
//
//  Created by Jim Avery on 12/7/16.
//
//

import Foundation

import LoggerAPI

public class AlertService {
    public class func post(_ alert: Alert, usingCredentials credentials: ServiceCredentials, callback: ((Alert?, Error?) -> Void)? = nil) throws {
        let bluemixRequest = try BluemixRequest(usingCredentials: credentials)
        let errors = [208: "This error has already been reported.", 400: "The service reported an invalid request.", 401: "Authorization is invalid.", 415: "Invalid media type for alert."]
        let bluemixCallback = AlertService.alertCallbackBuilder(statusResponses: errors, withFinalCallback: callback)
        try bluemixRequest.postAlert(alert, callback: bluemixCallback)
    }
    
    public class func get(shortId id: String, usingCredentials credentials: ServiceCredentials, callback: @escaping (Alert?, Error?) -> Void) throws {
        let bluemixRequest = try BluemixRequest(usingCredentials: credentials)
        let errors = [401: "Authorization is invalid.", 404: "An alert matching this short ID could not be found."]
        let bluemixCallback = AlertService.alertCallbackBuilder(statusResponses: errors, withFinalCallback: callback)
        try bluemixRequest.getAlert(shortId: id, callback: bluemixCallback)
    }
    
    public class func delete(shortId id: String, usingCredentials credentials: ServiceCredentials, callback: ((Error?) -> Void)? = nil) throws {
        let bluemixRequest = try BluemixRequest(usingCredentials: credentials)
        try bluemixRequest.deleteAlert(shortId: id) { (data, response, error) in
            // Possible error #1: error received.
            if let error = error {
                callback?(error)
                Log.error(error.localizedDescription)
                return
            }
            
            // Possible error #2: bad response code from the server.
            guard let httpResponse = response as? HTTPURLResponse else {
                callback?(AlertNotificationError.HTTPError("Could not parse the HTTP response from the server."))
                Log.error("Could not parse the HTTP response from the server.")
                return
            }
            var bluemixError: String?
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
            if let bluemixError = bluemixError {
                callback?(AlertNotificationError.bluemixError(bluemixError))
                Log.error(bluemixError)
                return
            }
            
            // Finally, perform the callback on the response.
            callback?(nil)
        }
    }
    
    // Create a callback function for when we are expecting an Alert object in response.
    private class func alertCallbackBuilder(statusResponses: [Int: String], withFinalCallback callback: ((Alert?, Error?) -> Void)? = nil) -> (Data?, URLResponse?, Swift.Error?) -> Void {
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
                guard let alertResponse = Alert(data: data) else {
                    callback?(nil, AlertNotificationError.HTTPError("Malformed response from server."))
                    Log.error("Malformed response from server.")
                    return
                }
            
                // Perform the callback on the data, because we succeeded.
                callback?(alertResponse, nil)
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
